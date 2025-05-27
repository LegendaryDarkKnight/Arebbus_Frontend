import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _userIdKey = 'user_id'; // Key for secure storage

  String? _userId;
  bool _isAuthenticated = false;

  String? get userId => _userId;
  bool get isAuthenticated => _isAuthenticated;

  AuthService() {
    _tryAutoLogin(); 
  }

  Future<void> _tryAutoLogin() async {
    final storedUserId = await _storage.read(key: _userIdKey);
    if (storedUserId != null && storedUserId.isNotEmpty) {
      _userId = storedUserId;
      _isAuthenticated = true;
      notifyListeners(); 
      debugPrint("AuthService: Auto login successful. UserID: $_userId");
    } else {
      debugPrint("AuthService: No stored UserID found for auto-login.");
    }
  }

  Future<void> login(String userIdFromResponse) async {
    if (userIdFromResponse.isEmpty) {
      debugPrint("AuthService: Login attempt with empty UserID.");
      return; 
    }
    _userId = userIdFromResponse;
    _isAuthenticated = true;
    await _storage.write(key: _userIdKey, value: _userId);
    notifyListeners(); 
    debugPrint("AuthService: Login successful. UserID stored: $_userId");
  }

  Future<void> logout() async {
    _userId = null;
    _isAuthenticated = false;
    await _storage.delete(key: _userIdKey);
    notifyListeners(); 
    debugPrint("AuthService: User logged out.");
  }
}