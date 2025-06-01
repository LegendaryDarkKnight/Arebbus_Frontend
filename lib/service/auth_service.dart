// auth_service.dart
import 'dart:convert';
import 'package:arebbus/config/app_config.dart';
import 'package:arebbus/models/auth_response.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static final String _baseUrl = AppConfig.instance.apiBaseUrl; // Replace with your API URL

  // Store authentication data
  Future<void> saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, authResponse.token);
    await prefs.setString(_userDataKey, jsonEncode(authResponse.toJson()));
  }

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get stored user data
  Future<AuthResponse?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userDataKey);
    if (userData != null) {
      return AuthResponse.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Login method
  Future<AuthResponse?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'), // Replace with your login endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
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
    return await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
    );
  }

  Future<http.Response> authenticatedPost(String endpoint, Map<String, dynamic> body) async {
    final headers = await getAuthHeaders();
    return await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }
}