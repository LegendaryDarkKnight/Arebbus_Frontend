import 'package:arebbus/models/bus.dart';
import 'package:arebbus/models/location_status.dart';
import 'package:arebbus/models/user.dart';

/// Represents a location record in the Arebbus tracking system.
/// 
/// This model captures the relationship between a user, a bus, and a specific
/// location at a point in time. It's used for tracking user movements,
/// bus passenger counts, and route optimization. Each location record
/// includes coordinates, timing, and status information that helps with
/// real-time tracking and analytics.
class Location {
  /// ID of the bus associated with this location record
  final int busId;
  
  /// ID of the user whose location is being tracked
  final int userId;
  
  /// Latitude coordinate of the recorded location
  final double latitude;
  
  /// Longitude coordinate of the recorded location
  final double longitude;
  
  /// Timestamp when this location was recorded
  final DateTime time;
  
  /// Current status of the user at this location (waiting, on bus, etc.)
  final LocationStatus status;
  
  /// Optional bus object containing detailed bus information
  final Bus? bus;
  
  /// Optional user object containing detailed user information
  final User? user;

  /// Creates a new Location instance.
  /// 
  /// Required parameters:
  /// - [busId]: ID of the associated bus
  /// - [userId]: ID of the user being tracked
  /// - [latitude]: Latitude coordinate
  /// - [longitude]: Longitude coordinate
  /// - [time]: Timestamp of the location record
  /// - [status]: Current user status at this location
  /// 
  /// Optional parameters:
  /// - [bus]: Detailed bus information
  /// - [user]: Detailed user information
  Location({
    required this.busId,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.time,
    required this.status,
    this.bus,
    this.user,
  });

  /// Creates a Location instance from a JSON map.
  /// 
  /// This factory constructor handles deserialization of location data from API responses.
  /// It properly handles different field naming conventions (snake_case vs camelCase)
  /// and provides safe defaults for coordinate values.
  /// 
  /// Parameters:
  /// - [json]: Map containing location data from API response
  /// 
  /// Returns a new Location instance populated from JSON data.
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      busId: json['bus_id'] ?? json['busId'],
      userId: json['user_id'] ?? json['userId'],
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      time: DateTime.parse(json['time']),
      status: LocationStatus.fromString(json['status'] ?? 'WAITING'),
      bus: json['bus'] != null ? Bus.fromJson(json['bus']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  /// Converts the Location instance to a JSON map.
  /// 
  /// This method is used when sending location data to the API or storing locally.
  /// It uses snake_case field names for API compatibility and converts
  /// DateTime to ISO 8601 string format.
  /// 
  /// Returns a Map<String, dynamic> representing the location data.
  Map<String, dynamic> toJson() {
    return {
      'bus_id': busId,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'time': time.toIso8601String(),
      'status': status.value,
      'bus': bus?.toJson(),
      'user': user?.toJson(),
    };
  }

  Location copyWith({
    int? busId,
    int? userId,
    double? latitude,
    double? longitude,
    DateTime? time,
    LocationStatus? status,
    Bus? bus,
    User? user,
  }) {
    return Location(
      busId: busId ?? this.busId,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      time: time ?? this.time,
      status: status ?? this.status,
      bus: bus ?? this.bus,
      user: user ?? this.user,
    );
  }

  @override
  String toString() {
    return 'Location{busId: $busId, userId: $userId, status: ${status.value}}';
  }
}
