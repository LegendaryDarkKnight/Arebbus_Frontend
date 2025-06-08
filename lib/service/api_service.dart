import 'package:arebbus/config/app_config.dart' show AppConfig;
import 'package:arebbus/models/auth_response.dart' show AuthResponse;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:arebbus/models/comment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;
  static final String _baseUrl = AppConfig.instance.apiBaseUrl;
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  ApiService._internal(){
    _initializeDio();
  }

  static ApiService get instance => _instance;

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
            // You might want to navigate to login screen here
            // or emit an event that the auth provider can listen to
          }
          handler.next(error);
        },
      ),
    );
  }

  void _initializeDio() {
    _dio = Dio();
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.sendTimeout = const Duration(seconds: 10);

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

  Future<AuthResponse> registerUser(String name, String email, String password) async {
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

      final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);

      if (authResponse.success) {
        await saveAuthData(authResponse); // optional if you want to persist session
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

  Future<Map<String, dynamic>> createPost(String content, List<String> tags) async {
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
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
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
        '/post/$postId/comment/create',
        data: {'content': content},
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

}
