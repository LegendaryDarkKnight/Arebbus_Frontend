import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _authDataKey = 'auth_data';
  static const String _loginTimeKey = 'login_time';
  
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  
  AuthService._();
  
  AuthResponse? _currentUser;
  DateTime? _loginTime;
  
  AuthResponse? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String? get userId => _currentUser?.userId?.toString();
  String? get username => _currentUser?.username;
  String? get imageUrl => _currentUser?.imageUrl;
  String? get token => _currentUser?.token;
  
  /// Initialize auth service and restore session if available
  Future<void> initialize() async {
    await _loadStoredAuthData();
  }
  
  /// Store authentication data after successful login
  Future<void> setAuthData(AuthResponse authResponse) async {
    _currentUser = authResponse;
    _loginTime = DateTime.now();
    
    await _saveAuthData();
    debugPrint('Auth data stored for user: ${authResponse.username}');
  }
  
  /// Clear authentication data on logout
  Future<void> clearAuthData() async {
    _currentUser = null;
    _loginTime = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authDataKey);
    await prefs.remove(_loginTimeKey);
    
    debugPrint('Auth data cleared');
  }
  
  /// Check if the session is still valid (you can add cookie expiration logic here)
  bool isSessionValid() {
    if (_currentUser == null || _loginTime == null) return false;
    
    // You can add additional session validation logic here
    // For example, check if cookie has expired based on server response
    // or implement a time-based session timeout
    
    return true;
  }
  
  /// Save auth data to local storage
  Future<void> _saveAuthData() async {
    if (_currentUser == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final authDataJson = jsonEncode(_currentUser!.toJson());
    
    await prefs.setString(_authDataKey, authDataJson);
    await prefs.setString(_loginTimeKey, _loginTime!.toIso8601String());
  }
  
  /// Load stored auth data from local storage
  Future<void> _loadStoredAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authDataJson = prefs.getString(_authDataKey);
      final loginTimeString = prefs.getString(_loginTimeKey);
      
      if (authDataJson != null && loginTimeString != null) {
        final authDataMap = jsonDecode(authDataJson) as Map<String, dynamic>;
        _currentUser = AuthResponse.fromJson(authDataMap);
        _loginTime = DateTime.parse(loginTimeString);
        
        debugPrint('Restored auth data for user: ${_currentUser!.username}');
      }
    } catch (e) {
      debugPrint('Error loading stored auth data: $e');
      await clearAuthData(); // Clear corrupted data
    }
  }
  
  /// Update user profile data (for profile updates)
  Future<void> updateUserData({
    String? username,
    String? imageUrl,
  }) async {
    if (_currentUser == null) return;
    
    _currentUser = AuthResponse(
      userId: _currentUser!.userId,
      message: _currentUser!.message,
      success: _currentUser!.success,
      token: _currentUser!.token,
      username: username ?? _currentUser!.username,
      imageUrl: imageUrl ?? _currentUser!.imageUrl,
    );
    
    await _saveAuthData();
  }
}

/// Auth response model class
class AuthResponse {
  final int? userId;
  final String? message;
  final bool success;
  final String? token;
  final String? username;
  final String? imageUrl;
  
  AuthResponse({
    this.userId,
    this.message,
    required this.success,
    this.token,
    this.username,
    this.imageUrl,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'] as int?,
      message: json['message'] as String?,
      success: json['success'] as bool? ?? false,
      token: json['token'] as String?,
      username: json['username'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'message': message,
      'success': success,
      'token': token,
      'username': username,
      'imageUrl': imageUrl,
    };
  }
}