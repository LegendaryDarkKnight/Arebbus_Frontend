import 'package:arebbus/models/user.dart';

class Stop {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final int authorId;
  final String? authorName;
  final User? author;

  Stop({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.authorId,
    this.authorName,
    this.author,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['id'],
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      authorId: json['authorId'] ?? json['author_id'] ?? 0,
      authorName: json['authorName'],
      author: json['author'] != null ? User.fromJson(json['author']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'author_id': authorId,
      'authorName': authorName,
      'author': author?.toJson(),
    };
  }

  Stop copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    int? authorId,
    String? authorName,
    User? author,
  }) {
    return Stop(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      author: author ?? this.author,
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
