/// Represents a user in the Arebbus platform.
/// 
/// This model contains comprehensive user information including profile data,
/// reputation metrics, validation status, and location coordinates.
/// Users can create posts, comments, buses, and interact with the community.
/// The location data is used for location-based features and services.
class User {
  /// Display name of the user
  final String name;
  
  /// Email address of the user (optional for privacy)
  final String? email;
  
  /// Profile image URL for the user
  final String image;
  
  /// User's reputation score based on community interactions
  final int? reputation;
  
  /// Whether the user account is validated/verified
  final bool? valid;
  
  /// Latitude coordinate of the user's location
  final double? latitude;
  
  /// Longitude coordinate of the user's location
  final double? longitude;

  /// Creates a new User instance.
  /// 
  /// Required parameters:
  /// - [name]: Display name of the user
  /// - [image]: Profile image URL
  /// 
  /// Optional parameters:
  /// - [email]: Email address (may be null for privacy)
  /// - [reputation]: User's reputation score from community interactions
  /// - [valid]: Whether the user account is validated
  /// - [latitude]: Latitude coordinate for location services
  /// - [longitude]: Longitude coordinate for location services
  User({
    required this.name,
    this.email,
    required this.image,
    this.reputation,
    this.valid,
    this.latitude,
    this.longitude,
  });

  /// Creates a User instance from a JSON map.
  /// 
  /// This factory constructor handles deserialization of user data from API responses.
  /// It provides safe defaults for optional fields and properly converts
  /// numeric coordinates to double precision.
  /// 
  /// Parameters:
  /// - [json]: Map containing user data from API response
  /// 
  /// Returns a new User instance populated from JSON data.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      reputation: json['reputation'] ?? 0,
      valid: json['valid'] ?? true,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  /// Converts the User instance to a JSON map.
  /// 
  /// This method is used when sending user data to the API or storing locally.
  /// All user information including optional location data is included.
  /// 
  /// Returns a Map<String, dynamic> representing the user data.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'image': image,
      'reputation': reputation,
      'valid': valid,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? image,
    int? reputation,
    bool? valid,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      reputation: reputation ?? this.reputation,
      valid: valid ?? this.valid,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() {
    return 'User{name: $name, email: $email, reputation: $reputation}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.email == email;
  }

  @override
  int get hashCode => email.hashCode;
}
