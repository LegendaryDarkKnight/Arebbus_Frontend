import 'package:arebbus/models/auth_response.dart';
import 'package:arebbus/service/api_service.dart' show ApiService;
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  AuthResponse? _currentUser;
  bool _isLoading = false;

  AuthResponse? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  // Initialize - check if user is already logged in
  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (await ApiService.instance.isLoggedIn()) {
        _currentUser = await ApiService.instance.getUserData();
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authResponse = await ApiService.instance.loginUser(email, password);
      if (authResponse.success) {
        _currentUser = authResponse;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Logout
  Future<void> logout() async {
    await ApiService.instance.logout();
    _currentUser = null;
    notifyListeners();
  }

  // Get error message from last login attempt
  String? getLastLoginError() {
    return _currentUser?.success == false ? _currentUser?.message : null;
  }
  
}