import 'package:arebbus/models/auth_response.dart';
import 'package:arebbus/service/api_service.dart' show ApiService;
import 'package:flutter/foundation.dart';

/// Authentication state management provider for the Arebbus application.
/// 
/// This class manages user authentication state throughout the application using
/// the Provider pattern with ChangeNotifier. It serves as the central point for:
/// 
/// - User login and logout operations
/// - Authentication state persistence and retrieval
/// - Loading state management during authentication operations
/// - User session validation and management
/// - Automatic authentication restoration on app startup
/// - Notification of authentication state changes to UI components
/// 
/// The provider integrates with ApiService for backend authentication and
/// uses SharedPreferences for local storage of authentication data.
/// It implements ChangeNotifier to automatically update UI components
/// when authentication state changes.
class AuthProvider with ChangeNotifier {
  /// Current authenticated user data, null if not logged in
  AuthResponse? _currentUser;
  
  /// Loading state indicator for authentication operations
  bool _isLoading = false;

  /// Getter for accessing current user data
  AuthResponse? get currentUser => _currentUser;
  
  /// Getter for checking if authentication operations are in progress
  bool get isLoading => _isLoading;
  
  /// Getter for checking if a user is currently logged in
  bool get isLoggedIn => _currentUser != null;

  /// Initializes authentication state by checking for existing user session.
  /// 
  /// This method is called on app startup to restore authentication state
  /// from local storage. It checks if the user has a valid stored session
  /// and restores the user data if available. Handles errors gracefully
  /// and updates loading state appropriately.
  /// 
  /// Should be called during app initialization to maintain user sessions
  /// across app restarts.
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

  /// Authenticates a user with email and password credentials.
  /// 
  /// This method handles the login process by:
  /// - Setting loading state and notifying listeners
  /// - Making API call to authenticate user credentials
  /// - Storing user data locally on successful authentication
  /// - Updating authentication state and notifying UI components
  /// - Handling errors and providing appropriate feedback
  /// 
  /// Parameters:
  /// - [email]: User's email address for authentication
  /// - [password]: User's password for authentication
  /// 
  /// Returns: true if login successful, false otherwise
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
