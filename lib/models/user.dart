class User {
  final String name;
  final String? email;
  final String image;
  final int? reputation;
  final bool? valid;
  final double? latitude;
  final double? longitude;

  User({
    required this.name,
    this.email,
    required this.image,
    this.reputation,
    this.valid,
    this.latitude,
    this.longitude,
  });

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
