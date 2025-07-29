// lib/models/route_model.dart
import 'package:arebbus/models/stop.dart';

/// Represents a bus route with its associated stops in the Arebbus system.
/// 
/// This model provides a simplified representation of a route, focusing
/// on the essential information needed for route display and navigation.
/// It contains the route identifier, name, and the ordered list of stops
/// that buses follow along this route.
/// 
/// This model is typically used in contexts where detailed route information
/// (like schedules, directions, etc.) is not needed, such as quick route
/// selection or basic route listing.
class RouteModel {
  /// Unique identifier for the route
  final String id;
  
  /// Display name of the route (e.g., "Downtown Express", "Route 42")
  final String name;
  
  /// Ordered list of stops along this route
  /// The order represents the sequence buses follow when traveling the route
  final List<Stop> stops;

  /// Creates a new RouteModel instance.
  /// 
  /// Parameters:
  /// - [id]: Unique identifier for the route
  /// - [name]: Display name of the route
  /// - [stops]: Ordered list of stops along the route
  RouteModel({
    required this.id,
    required this.name,
    required this.stops,
  });

  /// Creates a RouteModel instance from a JSON map.
  /// 
  /// This factory constructor deserializes JSON data into a RouteModel
  /// object, including parsing the list of stops from nested JSON objects.
  /// 
  /// Parameter:
  /// - [json]: JSON map containing the route data
  /// 
  /// Returns: A new RouteModel instance with data populated from JSON
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      stops: (json['stops'] as List<dynamic>?)
              ?.map((stopJson) => Stop.fromJson(stopJson as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Converts this RouteModel instance to a JSON map.
  /// 
  /// This method serializes the RouteModel object to a JSON-compatible map,
  /// including serializing the list of stops to nested JSON objects.
  /// 
  /// Returns: A JSON map representation of this RouteModel
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stops': stops.map((stop) => stop.toJson()).toList(),
    };
  }

  /// Returns the number of stops on this route.
  /// 
  /// Returns: Count of stops in the route
  int get stopCount => stops.length;

  /// Checks if this route contains a specific stop.
  /// 
  /// Parameter:
  /// - [stopId]: ID of the stop to search for
  /// 
  /// Returns: `true` if the stop exists on this route, `false` otherwise
  bool containsStop(String stopId) {
    return stops.any((stop) => stop.id == stopId);
  }

  /// Gets the index of a stop in the route sequence.
  /// 
  /// Parameter:
  /// - [stopId]: ID of the stop to find
  /// 
  /// Returns: Zero-based index of the stop, or -1 if not found
  int getStopIndex(String stopId) {
    return stops.indexWhere((stop) => stop.id == stopId);
  }
}