/// Represents the response from authentication operations (login/register).
/// 
/// This model contains all the essential information returned by the authentication
/// service including user credentials, success status, and any messages.
/// It serves as the primary data structure for managing user authentication state
/// throughout the application.
class AuthResponse {
  /// Unique identifier for the authenticated user
  final int userId;
  
  /// Response message from the authentication service (success/error message)
  final String message;
  
  /// Indicates whether the authentication operation was successful
  final bool success;
  
  /// JWT token for authenticating subsequent API requests
  final String token;
  
  /// Display username of the authenticated user
  final String username;
  
  /// Optional profile image URL for the authenticated user
  final String? imageUrl;

  /// Creates a new AuthResponse instance.
  /// 
  /// All parameters except [imageUrl] are required as they contain
  /// essential authentication information.
  /// 
  /// Parameters:
  /// - [userId]: Unique identifier for the user
  /// - [message]: Response message from authentication service
  /// - [success]: Whether the operation succeeded
  /// - [token]: JWT token for API authentication
  /// - [username]: Display username
  /// - [imageUrl]: Optional profile image URL
  AuthResponse({
    required this.userId,
    required this.message,
    required this.success,
    required this.token,
    required this.username,
    this.imageUrl,
  });

  /// Creates an AuthResponse instance from a JSON map.
  /// 
  /// This factory constructor is used when deserializing authentication
  /// responses from the API. It expects all required fields to be present
  /// in the JSON response.
  /// 
  /// Parameters:
  /// - [json]: Map containing authentication response data from API
  /// 
  /// Returns a new AuthResponse instance populated from JSON data.
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'],
      message: json['message'],
      success: json['success'],
      token: json['token'],
      username: json['username'],
      imageUrl: json['imageUrl'],
    );
  }

  /// Converts the AuthResponse instance to a JSON map.
  /// 
  /// This method is used when storing authentication data locally
  /// or sending it in API requests that require user credentials.
  /// 
  /// Returns a Map<String, dynamic> representing the auth response data.
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
