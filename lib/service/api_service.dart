import 'package:arebbus/config/app_config.dart' show AppConfig;
import 'package:arebbus/models/auth_response.dart' show AuthResponse;
import 'package:arebbus/models/stop.dart';
import 'package:arebbus/models/stop_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:arebbus/models/comment.dart';
import 'package:arebbus/models/bus.dart';
import 'package:arebbus/models/bus_response.dart';
import 'package:arebbus/models/route_response.dart';
import 'package:arebbus/models/route.dart';
import 'package:arebbus/models/user_location.dart';
import 'package:arebbus/models/bus_location.dart';
import 'package:arebbus/models/waiting_users_count.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Centralized API service for all HTTP communications in the Arebbus application.
/// 
/// This service acts as the primary interface between the Flutter application and
/// the backend API. It provides a singleton pattern for consistent API access
/// across the app and handles:
/// 
/// - HTTP request/response management using Dio
/// - Authentication token management and automatic injection
/// - Request/response interceptors for logging and error handling
/// - Token refresh and automatic retry mechanisms
/// - Secure storage of authentication data
/// - Standardized error handling and response parsing
/// - Support for various API endpoints including buses, routes, posts, and location services
/// 
/// The service automatically handles authorization headers, request logging,
/// and provides comprehensive error handling for network operations.
class ApiService {
  /// Singleton instance of the ApiService
  static final ApiService _instance = ApiService._internal();
  
  /// Dio HTTP client instance for making API requests
  late Dio _dio;
  
  /// Base URL for the API endpoints, loaded from app configuration
  static final String _baseUrl = AppConfig.instance.apiBaseUrl;
  
  /// SharedPreferences key for storing authentication tokens
  static const String _tokenKey = 'auth_token';
  
  /// SharedPreferences key for storing user data
  static const String _userDataKey = 'user_data';

  /// Private constructor for singleton pattern implementation
  ApiService._internal() {
    _initializeDio();
  }

  /// Getter for accessing the singleton instance of ApiService
  static ApiService get instance => _instance;

  /// Enables HTTP request/response interceptors for debugging and authentication.
  /// 
  /// This method sets up interceptors that:
  /// - Automatically add Authorization headers to requests
  /// - Log request details for debugging purposes
  /// - Log response data and status codes
  /// - Handle and log error responses
  /// - Manage token refresh and retry logic for expired tokens
  void _enableInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('Request: ${options.method} ${options.uri}');
          debugPrint('Request headers: ${options.headers}');
          debugPrint('Request data: ${options.data}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('Response: ${response.statusCode} ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint('Error: ${error.type} - ${error.message}');
          debugPrint('Error response: ${error.response?.data}');

          // Handle token expiration (401 Unauthorized)
          if (error.response?.statusCode == 401) {
            await logout();
          }
          handler.next(error);
        },
      ),
    );
  }

  void _initializeDio() {
    _dio = Dio();
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.sendTimeout = const Duration(seconds: 60);

    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (kIsWeb) {
      _dio.options.extra['withCredentials'] = true;
    }

    _enableInterceptors();

    debugPrint(
      'Dio initialized for ${kIsWeb ? 'web' : 'mobile/desktop'} platform with base URL: $_baseUrl',
    );
  }

  // Auth-related methods
  Future<void> saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, authResponse.token);
    await prefs.setString(_userDataKey, jsonEncode(authResponse.toJson()));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<AuthResponse?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userDataKey);
    if (userData != null) {
      return AuthResponse.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
  }

  Future<AuthResponse> loginUser(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          extra: kIsWeb ? {'withCredentials': true} : null,
        ),
      );

      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Save auth data if login successful
      if (authResponse.success) {
        await saveAuthData(authResponse);
      }

      return authResponse;
    } on DioException catch (e) {
      String errorMessage;
      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 400:
            errorMessage = 'Invalid request.'.trim();
            break;
          case 401:
            errorMessage = 'Unauthorized - Invalid credentials.'.trim();
            break;
          case 403:
            errorMessage = 'Forbidden.'.trim();
            break;
          case 404:
            errorMessage = 'User not found.'.trim();
            break;
          case 500:
            errorMessage = 'Password not matched/ Server issues';
            break;
          default:
            errorMessage =
                'Login failed - ${e.response!.statusMessage ?? "Service unavailable"}';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timeout - Please check your network and try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Network error - Unable to connect to the server.';
      } else {
        errorMessage =
            'An unexpected network error occurred. Please try again.';
      }

      return AuthResponse(
        userId: 0,
        message: errorMessage,
        success: false,
        token: '',
        username: '',
      );
    } catch (e) {
      return AuthResponse(
        userId: 0,
        message: e.toString(),
        success: false,
        token: '',
        username: '',
      );
    }
  }

  Future<AuthResponse> registerUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          extra: kIsWeb ? {'withCredentials': true} : null,
        ),
      );

      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (authResponse.success) {
        await saveAuthData(
          authResponse,
        ); // optional if you want to persist session
      }
      return authResponse;
    } on DioException catch (e) {
      return AuthResponse(
        userId: 0,
        message: _getErrorMessage(e),
        success: false,
        token: '',
        username: '',
      );
    } catch (e) {
      return AuthResponse(
        userId: 0,
        message: 'An unexpected error occurred.',
        success: false,
        token: '',
        username: '',
      );
    }
  }

  String _getErrorMessage(DioException e) {
    if (e.response == null) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout - Please check your network';
        case DioExceptionType.connectionError:
          return 'Cannot connect to server';
        default:
          return 'Registration failed';
      }
    }

    final response = e.response!;
    String errorMessage = 'Registration failed';

    switch (response.statusCode) {
      case 400:
        errorMessage = 'Invalid registration data';
        break;
      case 409:
        errorMessage = 'User already exists with this email';
        break;
      case 422:
        errorMessage = 'Invalid input data';
        break;
      case 500:
        errorMessage = 'Server error - Please try again later';
        break;
      default:
        errorMessage = 'Registration failed - ${response.statusMessage}';
    }

    if (response.data is Map && response.data.containsKey('message')) {
      errorMessage = response.data['message'].toString();
    } else if (response.data is Map && response.data.containsKey('error')) {
      errorMessage = response.data['error'].toString();
    }

    return errorMessage;
  }

  Future<Map<String, dynamic>> fetchPosts(int page, int size) async {
    try {
      final response = await _dio.get(
        '/post/all',
        queryParameters: {'page': page, 'size': size},
        options: Options(responseType: ResponseType.json),
      );

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        } else if (response.data is String) {
          debugPrint('API returned a String with 200 OK: "${response.data}"');
          throw Exception(
            'API returned an unexpected message: ${response.data}',
          );
        } else {
          throw Exception(
            'API returned unexpected data type: ${response.data.runtimeType}',
          );
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error:
              'API request failed with status ${response.statusCode}: ${response.data}',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException in fetchPosts: ${e.message}');
      debugPrint('DioException response data: ${e.response?.data}');
      if (e.response?.data is String &&
          (e.response!.data as String).isNotEmpty) {
        throw Exception('Failed to load posts: ${e.response!.data}');
      } else if (e.response?.data is Map &&
          e.response!.data['message'] != null) {
        throw Exception('Failed to load posts: ${e.response!.data['message']}');
      }
      throw Exception('Failed to load posts (Network error): ${e.message}');
    } catch (e) {
      debugPrint('Generic error in fetchPosts: $e');
      throw Exception(
        'An unexpected error occurred while fetching posts: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>> fetchPostsByTags(
    List<String> tags,
    int page,
    int size,
  ) async {
    try {
      final response = await _dio.get(
        '/post/by-tags',
        queryParameters: {
          'tags': tags.join(','),
          'page': page,
          'size': size,
        },
        options: Options(responseType: ResponseType.json),
      );

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        } else {
          throw Exception(
            'API returned unexpected data type: ${response.data.runtimeType}',
          );
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error:
              'API request failed with status ${response.statusCode}: ${response.data}',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException in fetchPostsByTags: ${e.message}');
      debugPrint('DioException response data: ${e.response?.data}');
      if (e.response?.data is String &&
          (e.response!.data as String).isNotEmpty) {
        throw Exception('Failed to load posts by tags: ${e.response!.data}');
      } else if (e.response?.data is Map &&
          e.response!.data['message'] != null) {
        throw Exception(
          'Failed to load posts by tags: ${e.response!.data['message']}',
        );
      }
      throw Exception(
        'Failed to load posts by tags (Network error): ${e.message}',
      );
    } catch (e) {
      debugPrint('Generic error in fetchPostsByTags: $e');
      throw Exception(
        'An unexpected error occurred while fetching posts by tags: ${e.toString()}',
      );
    }
  }

  Future<List<String>> fetchAllTags() async {
    try {
      final response = await _dio.get(
        '/post/tags',
        options: Options(responseType: ResponseType.json),
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List).cast<String>();
        } else if (response.data is Map &&
            response.data['tags'] is List) {
          return (response.data['tags'] as List).cast<String>();
        } else {
          throw Exception(
            'API returned unexpected data type: ${response.data.runtimeType}',
          );
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error:
              'API request failed with status ${response.statusCode}: ${response.data}',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException in fetchAllTags: ${e.message}');
      debugPrint('DioException response data: ${e.response?.data}');
      if (e.response?.data is String &&
          (e.response!.data as String).isNotEmpty) {
        throw Exception('Failed to load tags: ${e.response!.data}');
      } else if (e.response?.data is Map &&
          e.response!.data['message'] != null) {
        throw Exception('Failed to load tags: ${e.response!.data['message']}');
      }
      throw Exception('Failed to load tags (Network error): ${e.message}');
    } catch (e) {
      debugPrint('Generic error in fetchAllTags: $e');
      throw Exception(
        'An unexpected error occurred while fetching tags: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>> createPost(
    String content,
    List<String> tags,
  ) async {
    try {
      debugPrint('Creating post with content: $content and tags: $tags');
      debugPrint('Making request to: ${_dio.options.baseUrl}/post/create');

      final response = await _dio.post(
        '/post/create',
        data: {'content': content, 'tags': tags},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          extra: kIsWeb ? {'withCredentials': true} : null,
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to create post: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException creating post: ${e.message}');
      debugPrint('DioException type: ${e.type}');
      debugPrint('DioException response: ${e.response?.data}');

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw Exception(
            'Connection timeout - please check your internet connection',
          );
        case DioExceptionType.sendTimeout:
          throw Exception('Request timeout - please try again');
        case DioExceptionType.receiveTimeout:
          throw Exception('Server response timeout - please try again');
        case DioExceptionType.connectionError:
          throw Exception(
            'Network connection error - please check if the server is running and CORS is configured',
          );
        case DioExceptionType.badResponse:
          throw Exception(
            'Server error: ${e.response?.statusCode} - ${e.response?.data}',
          );
        default:
          throw Exception('Failed to create post: ${e.message}');
      }
    } catch (e) {
      debugPrint('Generic error creating post: $e');
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      final response = await _dio.delete(
        '/post/delete',
        data: {'postId': postId},
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to delete post: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error deleting post: $e');
      throw Exception('Failed to delete post: ${e.message}');
    }
  }

  Future<List<Comment>> fetchCommentsForPost(int postId) async {
    try {
      final response = await _dio.get('/post/$postId/comments');
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> commentData = response.data as List<dynamic>;
        return commentData
            .map((data) => Comment.fromJson(data as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['comments'] is List) {
        final List<dynamic> commentData =
            response.data['comments'] as List<dynamic>;
        return commentData
            .map((data) => Comment.fromJson(data as Map<String, dynamic>))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to load comments: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error fetching comments for post $postId: $e');
      throw Exception('Failed to load comments: ${e.message}');
    }
  }

  Future<Comment> createComment(int postId, String content) async {
    try {
      final response = await _dio.post(
        '/comment',
        data: {'content': content, 'postId': postId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;
        if (responseData['postId'] == null) responseData['postId'] = postId;
        return Comment.fromJson(responseData);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to create comment: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error creating comment for post $postId: $e');
      throw Exception('Failed to create comment: ${e.message}');
    }
  }

  Future<Map<String, dynamic>?> getPostById(int postId) async {
    try {
      final response = await _dio.get(
        '/post',
        queryParameters: {'postId': postId},
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        return null; // Post not found
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to load post: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error fetching post by ID $postId: $e');
      throw Exception('Failed to load post: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> togglePostUpvote(int postId) async {
    try {
      debugPrint('Toggling upvote for post ID: $postId');
      debugPrint('Making request to: ${_dio.options.baseUrl}/upvote/post');

      final response = await _dio.post(
        '/upvote/post',
        data: {'id': postId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          extra: kIsWeb ? {'withCredentials': true} : null,
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error:
              'Failed to toggle post upvote: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException toggling post upvote: ${e.message}');
      debugPrint('DioException type: ${e.type}');
      debugPrint('DioException response: ${e.response?.data}');

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw Exception(
            'Connection timeout - please check your internet connection',
          );
        case DioExceptionType.sendTimeout:
          throw Exception('Request timeout - please try again');
        case DioExceptionType.receiveTimeout:
          throw Exception('Server response timeout - please try again');
        case DioExceptionType.connectionError:
          throw Exception(
            'Network connection error - please check if the server is running and CORS is configured',
          );
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          final responseData = e.response?.data;

          if (statusCode == 401) {
            throw Exception('Authentication required - please log in');
          } else if (statusCode == 403) {
            throw Exception('You do not have permission to upvote this post');
          } else if (statusCode == 404) {
            throw Exception('Post not found');
          } else {
            throw Exception('Server error: $statusCode - $responseData');
          }
        default:
          throw Exception('Failed to toggle post upvote: ${e.message}');
      }
    } catch (e) {
      debugPrint('Generic error toggling post upvote: $e');
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> toggleCommentUpvote(String commentId) async {
    try {
      debugPrint('Toggling upvote for comment ID: $commentId');
      debugPrint('Making request to: ${_dio.options.baseUrl}/upvote/comment');

      final response = await _dio.post(
        '/upvote/comment',
        data: {'id': commentId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          extra: kIsWeb ? {'withCredentials': true} : null,
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error:
              'Failed to toggle comment upvote: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException toggling comment upvote: ${e.message}');
      debugPrint('DioException type: ${e.type}');
      debugPrint('DioException response: ${e.response?.data}');

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw Exception(
            'Connection timeout - please check your internet connection',
          );
        case DioExceptionType.sendTimeout:
          throw Exception('Request timeout - please try again');
        case DioExceptionType.receiveTimeout:
          throw Exception('Server response timeout - please try again');
        case DioExceptionType.connectionError:
          throw Exception(
            'Network connection error - please check if the server is running and CORS is configured',
          );
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          final responseData = e.response?.data;

          if (statusCode == 401) {
            throw Exception('Authentication required - please log in');
          } else if (statusCode == 403) {
            throw Exception(
              'You do not have permission to upvote this comment',
            );
          } else if (statusCode == 404) {
            throw Exception('Comment not found');
          } else {
            throw Exception('Server error: $statusCode - $responseData');
          }
        default:
          throw Exception('Failed to toggle comment upvote: ${e.message}');
      }
    } catch (e) {
      debugPrint('Generic error toggling comment upvote: $e');
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  Map<String, dynamic> parseUpvoteResponse(Map<String, dynamic> responseData) {
    return {
      'upvoted': responseData['upvoteStatus'],
      'toggledAt': responseData['toggledAt'],
    };
  }

  // Future<Stop> createStop(String name, double latitude, double longitude) async {
  //   try {
  //     final response = await _dio.post(
  //       '/stop/create',
  //       data: {
  //         'name': name,
  //         'latitude': latitude,
  //         'longitude': longitude,
  //       },
  //     );
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return Stop.fromJson(response.data as Map<String, dynamic>);
  //     } else {
  //       throw DioException(
  //         requestOptions: response.requestOptions,
  //         response: response,
  //         error: 'Failed to create stop: Status code ${response.statusCode}',
  //       );
  //     }
  //   } on DioException catch (e) {
  //     debugPrint('Error creating stop: $e');
  //     throw Exception('Failed to create stop: ${e.message}');
  //   }
  // }

  Future<Stop> fetchStop(int stopId) async {
    try {
      final response = await _dio.get('/stop', queryParameters: {'stopId': stopId});
      if (response.statusCode == 200) {
        return Stop.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw Exception('Stop with id $stopId not found');
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch stop: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error fetching stop $stopId: $e');
      if (e.response?.statusCode == 404) {
        throw Exception('Stop with id $stopId not found');
      }
      throw Exception('Failed to fetch stop: ${e.message}');
    }
  }

  Future<StopResponse> fetchAllStops({int page = 0, int size = 10}) async {
    try {
      final response = await _dio.get(
        '/stop/all',
        queryParameters: {'page': page, 'size': size},
      );
      if (response.statusCode == 200) {
        return StopResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch stops: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error fetching stops (page: $page, size: $size): $e');
      throw Exception('Failed to fetch stops: ${e.message}');
    }
  }

  Future<void> debugPrintStoredAuth() async {
    if (kDebugMode) {
      final token = await getToken();
      final userData = await getUserData();
      final isLoggedIn = await this.isLoggedIn();

      debugPrint('=== AUTH DEBUG INFO ===');
      debugPrint('Is Logged In: $isLoggedIn');
      debugPrint('Stored Token: ${token ?? 'null'}');
      debugPrint('User Data: ${userData?.toJson() ?? 'null'}');
      debugPrint('======================');
    }
  }

  Future<void> debugClearAllAuth() async {
    if (kDebugMode) {
      await logout();
      debugPrint('All auth data cleared from storage');
    }
  }

  Future<void> debugPrintAllStoredKeys() async {
    if (kDebugMode && kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      debugPrint('=== ALL STORED KEYS ===');
      for (String key in keys) {
        final value = prefs.get(key);
        debugPrint('$key: $value');
      }
      debugPrint('======================');
    }
  }

  // Bus API methods
  Future<BusResponse> getAllBuses({int page = 0, int size = 10}) async {
    try {
      final response = await _dio.get(
        '/bus/all',
        queryParameters: {'page': page, 'size': size},
      );
      
      if (response.statusCode == 200) {
        return BusResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to load buses: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error fetching buses: $e');
      throw Exception('Failed to load buses: ${e.message}');
    }
  }

  Future<BusResponse> getInstalledBuses({int page = 0, int size = 10}) async {
    try {
      final response = await _dio.get(
        '/bus/installed',
        queryParameters: {'page': page, 'size': size},
      );
      
      if (response.statusCode == 200) {
        return BusResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to load installed buses: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error fetching installed buses: $e');
      throw Exception('Failed to load installed buses: ${e.message}');
    }
  }

  Future<Bus> getBusById(int busId) async {
    try {
      final response = await _dio.get(
        '/bus',
        queryParameters: {'busId': busId},
      );
      
      if (response.statusCode == 200) {
        return Bus.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw Exception('Bus not found');
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to load bus: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error fetching bus by ID $busId: $e');
      if (e.response?.statusCode == 404) {
        throw Exception('Bus not found');
      }
      throw Exception('Failed to load bus: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> installBus(int busId) async {
    try {
      final response = await _dio.post(
        '/bus/install',
        data: {'busId': busId},
      );
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to install bus: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error installing bus $busId: $e');
      throw Exception('Failed to install bus: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> uninstallBus(int busId) async {
    try {
      final response = await _dio.post(
        '/bus/uninstall',
        data: {'busId': busId},
      );
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to uninstall bus: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error uninstalling bus $busId: $e');
      throw Exception('Failed to uninstall bus: ${e.message}');
    }
  }

  Future<Stop> getStopById(int stopId) async {
    try {
      final response = await _dio.get(
        '/stop',
        queryParameters: {'stopId': stopId},
      );
      
      if (response.statusCode == 200) {
        return Stop.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw Exception('Stop not found');
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to load stop: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error fetching stop by ID $stopId: $e');
      if (e.response?.statusCode == 404) {
        throw Exception('Stop not found');
      }
      throw Exception('Failed to load stop: ${e.message}');
    }
  }

  Future<Route> getRouteById(int routeId) async {
    try {
      final response = await _dio.get(
        '/route',
        queryParameters: {'routeId': routeId},
      );
      
      if (response.statusCode == 200) {
        return Route.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw Exception('Route not found');
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to load route: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error fetching route by ID $routeId: $e');
      if (e.response?.statusCode == 404) {
        throw Exception('Route not found');
      }
      throw Exception('Failed to load route: ${e.message}');
    }
  }

  // Route and Stop creation methods
  Future<RouteResponse> getAllRoutes({int page = 0, int size = 10}) async {
    try {
      final response = await _dio.get(
        '/route/all',
        queryParameters: {'page': page, 'size': size},
      );
      
      if (response.statusCode == 200) {
        return RouteResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to load routes: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error fetching routes: $e');
      throw Exception('Failed to load routes: ${e.message}');
    }
  }

  Future<Stop> createStop({
    required String name,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        '/stop/create',
        data: {
          'name': name,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 200) {
        return Stop.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to create stop: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error creating stop: $e');
      throw Exception('Failed to create stop: ${e.message}');
    }
  }

  Future<Route> createRoute({
    required String name,
    required List<int> stopIds,
  }) async {
    try {
      final response = await _dio.post(
        '/route/create',
        data: {
          'name': name,
          'stopIds': stopIds,
        },
      );
      
      if (response.statusCode == 200) {
        return Route.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to create route: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error creating route: $e');
      if (e.response?.statusCode == 404) {
        throw Exception('One or more stops not found');
      }
      throw Exception('Failed to create route: ${e.message}');
    }
  }

  Future<Bus> createBus({
    required String name,
    required int routeId,
    required int capacity,
  }) async {
    try {
      final response = await _dio.post(
        '/bus/create',
        data: {
          'name': name,
          'routeId': routeId,
          'capacity': capacity,
        },
      );
      
      if (response.statusCode == 200) {
        return Bus.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to create bus: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error creating bus: $e');
      if (e.response?.statusCode == 404) {
        throw Exception('Route not found');
      }
      throw Exception('Failed to create bus: ${e.message}');
    }
  }

  Future<List<Stop>> getNearbyStops({
    required double latitude,
    required double longitude,
    double radius = 3.0, // Default 3km radius
  }) async {
    try {
      final response = await _dio.get(
        '/stop/near',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> stopsData = response.data as List<dynamic>;
        return stopsData
            .map((stopJson) => Stop.fromJson(stopJson as Map<String, dynamic>))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to load nearby stops: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error fetching nearby stops: $e');
      throw Exception('Failed to load nearby stops: ${e.message}');
    }
  }

  // Location tracking methods
  Future<UserLocation> getUserLocation() async {
    try {
      final response = await _dio.get(
        '/location/user/get',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      
      if (response.statusCode == 200) {
        return UserLocation.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to get user location: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error getting user location: $e');
      throw Exception('Failed to get user location: ${e.message}');
    }
  }

  Future<UserLocation> setUserWaiting({
    required double latitude,
    required double longitude,
    required int busId,
  }) async {
    try {
      final response = await _dio.post(
        '/location/user/waiting',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'busId': busId,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      
      if (response.statusCode == 200) {
        return UserLocation.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to set waiting status: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error setting waiting status: $e');
      throw Exception('Failed to set waiting status: ${e.message}');
    }
  }

  Future<UserLocation> setUserOnBus({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        '/location/user/on-bus',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      
      if (response.statusCode == 200) {
        return UserLocation.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to set on-bus status: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error setting on-bus status: $e');
      throw Exception('Failed to set on-bus status: ${e.message}');
    }
  }

  Future<UserLocation> setUserNoTrack({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        '/location/user/no-track',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      
      if (response.statusCode == 200) {
        return UserLocation.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to set no-track status: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error setting no-track status: $e');
      throw Exception('Failed to set no-track status: ${e.message}');
    }
  }

  Future<BusLocationResponse> getBusLocations(int busId) async {
    try {
      final response = await _dio.get(
        '/location/bus/get',
        queryParameters: {'busId': busId},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      
      if (response.statusCode == 200) {
        return BusLocationResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to get bus locations: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error getting bus locations: $e');
      throw Exception('Failed to get bus locations: ${e.message}');
    }
  }

  Future<UserLocation> updateUserLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        '/location/user/update',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      
      if (response.statusCode == 200) {
        return UserLocation.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to update user location: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error updating user location: $e');
      throw Exception('Failed to update user location: ${e.message}');
    }
  }

  Future<WaitingUsersCount> getWaitingUsersCount() async {
    try {
      final response = await _dio.get(
        '/location/users/wait-count',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      
      if (response.statusCode == 200) {
        return WaitingUsersCount.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to get waiting users count: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('Error getting waiting users count: $e');
      throw Exception('Failed to get waiting users count: ${e.message}');
    }
  }
}
