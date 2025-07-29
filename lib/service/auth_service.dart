// auth_service.dart
import 'dart:convert';
import 'package:arebbus/config/app_config.dart';
import 'package:arebbus/models/auth_response.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Authentication service for managing user authentication operations.
/// 
/// This service provides a focused interface for authentication-related operations
/// including login, token management, and user session persistence. It serves as
/// an alternative or complement to the ApiService for authentication-specific tasks.
/// 
/// Key responsibilities include:
/// - User login and authentication with the backend
/// - Secure storage and retrieval of authentication tokens
/// - User data persistence using SharedPreferences
/// - Session validation and management
/// - Logout and session cleanup operations
/// 
/// The service uses HTTP for API communications and SharedPreferences for
/// local storage of authentication data, providing a complete authentication
/// solution for the Arebbus application.
class AuthService {
  /// SharedPreferences key for storing authentication tokens
  static const String _tokenKey = 'auth_token';
  
  /// SharedPreferences key for storing user data
  static const String _userDataKey = 'user_data';
  
  /// Base URL for authentication API endpoints
  static final String _baseUrl = AppConfig.instance.apiBaseUrl;

  /// Stores authentication data locally after successful login.
  /// 
  /// This method persists both the authentication token and complete user data
  /// to SharedPreferences for future app sessions. The data is stored securely
  /// and can be retrieved across app restarts to maintain user sessions.
  /// 
  /// Parameter:
  /// - [authResponse]: Complete authentication response containing token and user data
  Future<void> saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, authResponse.token);
    await prefs.setString(_userDataKey, jsonEncode(authResponse.toJson()));
  }

  /// Retrieves the stored authentication token from local storage.
  /// 
  /// This method fetches the authentication token from SharedPreferences
  /// that was previously stored during login. The token is used for
  /// authorizing API requests and maintaining user sessions.
  /// 
  /// Returns: The stored authentication token, or null if not found
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Retrieves the stored user data from local storage.
  /// 
  /// This method fetches the complete user authentication data from
  /// SharedPreferences and deserializes it back into an AuthResponse object.
  /// This allows the app to restore user session data across app restarts.
  /// 
  /// Returns: The stored AuthResponse object, or null if not found
  Future<AuthResponse?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userDataKey);
    if (userData != null) {
      return AuthResponse.fromJson(jsonDecode(userData));
    }
    return null;
  }

  /// Checks if a user is currently logged in by validating stored token.
  /// 
  /// This method determines authentication status by checking for the
  /// presence of a valid authentication token in local storage. It's used
  /// throughout the app to determine if authentication is required.
  /// 
  /// Returns: true if user is logged in (has valid token), false otherwise
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Authenticates a user with username and password credentials.
  /// 
  /// This method handles the login process by making an HTTP POST request
  /// to the authentication endpoint with user credentials. It processes
  /// the response and returns the authentication data on success.
  /// 
  /// Parameters:
  /// - [username]: User's username or email for authentication
  /// - [password]: User's password for authentication
  /// 
  /// Returns: AuthResponse object on successful login, null on failure
  Future<AuthResponse?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'), // Replace with your login endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));

        if (authResponse.success) {
          await saveAuthData(authResponse);
          return authResponse;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  // Logout method
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
  }

  // Get authorization headers
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Make authenticated API calls
  Future<http.Response> authenticatedGet(String endpoint) async {
    final headers = await getAuthHeaders();
    return await http.get(Uri.parse('$_baseUrl$endpoint'), headers: headers);
  }

  Future<http.Response> authenticatedPost(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await getAuthHeaders();
    return await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }
}
