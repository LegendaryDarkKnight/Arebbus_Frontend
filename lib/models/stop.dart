class Stop {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final String authorName;

  Stop({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.authorName,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['id'],
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      authorName: json['authorName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'authorName': authorName,
    };
  }

  Stop copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    String? authorName,
  }) {
    return Stop(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      authorName: authorName ?? this.authorName,
    );
  }

  @override
  String toString() {
    return 'Stop{id: $id, name: $name, lat: $latitude, lon: $longitude}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Stop && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
