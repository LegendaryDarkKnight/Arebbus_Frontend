import 'package:arebbus/models/route.dart';
import 'package:arebbus/models/stop.dart';
import 'package:arebbus/models/user.dart';

/// Represents the relationship between a route and a stop in the Arebbus system.
/// 
/// This model defines the association between routes and stops, including the
/// order/sequence of stops along a route. It tracks which user created this
/// route-stop relationship and can optionally include the full route, stop,
/// and user objects for detailed information.
/// 
/// The stopIndex field is crucial for maintaining the correct order of stops
/// along a route, ensuring buses follow the intended path.
class RouteStop {
  /// ID of the route this stop belongs to
  final int routeId;
  
  /// ID of the stop on this route
  final int stopId;
  
  /// Sequential index/order of this stop on the route (0-based)
  final int stopIndex;
  
  /// ID of the user who created/added this route-stop relationship
  final int authorId;
  
  /// Optional detailed route information (populated when needed)
  final Route? route;
  
  /// Optional detailed stop information (populated when needed)
  final Stop? stop;
  
  /// Optional detailed author information (populated when needed)
  final User? author;

  /// Creates a new RouteStop instance.
  /// 
  /// The route, stop, and author objects are optional and typically
  /// populated when detailed information is needed for display.
  RouteStop({
    required this.routeId,
    required this.stopId,
    required this.stopIndex,
    required this.authorId,
    this.route,
    this.stop,
    this.author,
  });

  /// Creates a RouteStop instance from a JSON map.
  /// 
  /// This factory constructor deserializes JSON data into a RouteStop object,
  /// handling both snake_case and camelCase field names for API compatibility.
  /// Nested objects (route, stop, author) are parsed when present.
  /// 
  /// Parameter:
  /// - [json]: JSON map containing the route-stop relationship data
  /// 
  /// Returns: A new RouteStop instance with data populated from JSON
  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      routeId: json['route_id'] ?? json['routeId'],
      stopId: json['stop_id'] ?? json['stopId'],
      stopIndex: json['stop_index'] ?? json['stopIndex'],
      authorId: json['author_id'] ?? json['authorId'],
      route: json['route'] != null ? Route.fromJson(json['route']) : null,
      stop: json['stop'] != null ? Stop.fromJson(json['stop']) : null,
      author: json['author'] != null ? User.fromJson(json['author']) : null,
    );
  }

  /// Converts this RouteStop instance to a JSON map.
  /// 
  /// This method serializes the RouteStop object to a JSON-compatible map
  /// using snake_case field names. Nested objects are included when present.
  /// 
  /// Returns: A JSON map representation of this RouteStop
  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'stop_id': stopId,
      'stop_index': stopIndex,
      'author_id': authorId,
      'route': route?.toJson(),
      'stop': stop?.toJson(),
      'author': author?.toJson(),
    };
  }

  /// Creates a copy of this RouteStop with optionally updated values.
  /// 
  /// This method is useful for updating specific fields while preserving
  /// the rest of the route-stop relationship data.
  /// 
  /// Returns: A new RouteStop instance with updated values
  RouteStop copyWith({
    int? routeId,
    int? stopId,
    int? stopIndex,
    int? authorId,
    Route? route,
    Stop? stop,
    User? author,
  }) {
    return RouteStop(
      routeId: routeId ?? this.routeId,
      stopId: stopId ?? this.stopId,
      stopIndex: stopIndex ?? this.stopIndex,
      authorId: authorId ?? this.authorId,
      route: route ?? this.route,
      stop: stop ?? this.stop,
      author: author ?? this.author,
    );
  }

  /// Returns a string representation of this RouteStop.
  /// 
  /// Useful for debugging and logging purposes, showing the key identifiers
  /// and stop position in the route sequence.
  /// 
  /// Returns: A formatted string with route ID, stop ID, and stop index
  @override
  String toString() {
    return 'RouteStop{routeId: $routeId, stopId: $stopId, index: $stopIndex}';
  }
}
