import 'package:arebbus/models/stop.dart';

/// Represents a bus route in the Arebbus transportation system.
/// 
/// A route defines the path that a bus follows, consisting of an ordered
/// sequence of stops. Routes are created by users and can be associated
/// with multiple buses. Each route has metadata including its name,
/// creator information, and the complete list of stops along the path.
class Route {
  /// Unique identifier for the route (nullable for new routes not yet saved)
  final int? id;
  
  /// Display name of the route
  final String name;
  
  /// Name of the user who created this route
  final String authorName;
  
  /// Ordered list of stops that define the route path
  final List<Stop> stops;

  /// Creates a new Route instance.
  /// 
  /// Required parameters:
  /// - [name]: Display name of the route
  /// - [authorName]: Name of the user who created this route
  /// - [stops]: Ordered list of stops along the route
  /// 
  /// Optional parameters:
  /// - [id]: Unique identifier (null for new routes)
  Route({this.id, required this.name, required this.authorName, required this.stops});

  /// Creates a Route instance from a JSON map.
  /// 
  /// This factory constructor handles deserialization of route data from API responses.
  /// It properly deserializes the nested list of stops and provides safe defaults.
  /// 
  /// Parameters:
  /// - [json]: Map containing route data from API response
  /// 
  /// Returns a new Route instance populated from JSON data.
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

  /// Converts the Route instance to a JSON map.
  /// 
  /// This method is used when sending route data to the API or storing locally.
  /// It properly serializes the nested list of stops.
  /// 
  /// Returns a Map<String, dynamic> representing the route data.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'authorName': authorName,
      'stops': stops.map((stop) => stop.toJson()).toList(),
    };
  }

  /// Creates a copy of this Route with the given fields replaced with new values.
  /// 
  /// This method is useful for updating specific fields of a route without
  /// modifying the original instance.
  /// 
  /// Parameters (all optional):
  /// - [id]: New route ID
  /// - [name]: New route name
  /// - [authorName]: New author name
  /// - [stops]: New list of stops
  /// 
  /// Returns a new Route instance with updated values.
  Route copyWith({int? id, String? name, String? authorName, List<Stop>? stops}) {
    return Route(
      id: id ?? this.id,
      name: name ?? this.name,
      authorName: authorName ?? this.authorName,
      stops: stops ?? this.stops,
    );
  }

  /// Returns a string representation of the Route for debugging purposes.
  /// 
  /// Includes the route ID, name, author, and number of stops for easy identification.
  @override
  String toString() {
    return 'Route{id: $id, name: $name, authorName: $authorName, stops: ${stops.length}}';
  }

  /// Determines whether two Route instances are equal based on their ID.
  /// 
  /// Two routes are considered equal if they have the same ID, regardless
  /// of other field values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Route && other.id == id;
  }

  /// Returns the hash code for this Route instance.
  /// 
  /// The hash code is based solely on the route ID to maintain consistency
  /// with the equality operator.
  @override
  int get hashCode => id.hashCode;
}
