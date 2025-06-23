class AuthResponse {
  final int userId;
  final String message;
  final bool success;
  final String token;
  final String username;
  final String? imageUrl;

  AuthResponse({
    required this.userId,
    required this.message,
    required this.success,
    required this.token,
    required this.username,
    this.imageUrl,
  });

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
