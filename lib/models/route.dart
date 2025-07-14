import 'package:arebbus/models/stop.dart';

class Route {
  final int? id;
  final String name;
  final String authorName;
  final List<Stop> stops;

  Route({this.id, required this.name, required this.authorName, required this.stops});

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['id'],
      name: json['name'] ?? '',
      authorName: json['authorName'] ?? '',
      stops: (json['stops'] as List<dynamic>?)
          ?.map((stopJson) => Stop.fromJson(stopJson as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'authorName': authorName,
      'stops': stops.map((stop) => stop.toJson()).toList(),
    };
  }

  Route copyWith({int? id, String? name, String? authorName, List<Stop>? stops}) {
    return Route(
      id: id ?? this.id,
      name: name ?? this.name,
      authorName: authorName ?? this.authorName,
      stops: stops ?? this.stops,
    );
  }

  @override
  String toString() {
    return 'Route{id: $id, name: $name, authorName: $authorName, stops: ${stops.length}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Route && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
