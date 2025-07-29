import 'package:arebbus/models/route.dart';
import 'package:arebbus/models/stop.dart';
import 'package:arebbus/models/user.dart';

/// Represents a user's subscription to a specific route for notifications and tracking.
/// 
/// Route subscriptions allow users to receive updates about buses on particular routes,
/// get notifications about delays or changes, and track route-specific information.
/// This enables personalized transportation experiences based on user preferences.
class RouteSubscription {
  /// ID of the user who subscribed to the route
  final int userId;
  
  /// ID of the route being subscribed to
  final int routeId;
  
  /// Optional detailed user information
  final User? user;
  
  /// Optional detailed route information
  final Route? route;

  /// Creates a new RouteSubscription instance.
  /// 
  /// Required parameters:
  /// - [userId]: ID of the subscribing user
  /// - [routeId]: ID of the route being subscribed to
  /// 
  /// Optional parameters:
  /// - [user]: Detailed user information
  /// - [route]: Detailed route information
  RouteSubscription({
    required this.userId,
    required this.routeId,
    this.user,
    this.route,
  });

  /// Creates a RouteSubscription instance from a JSON map.
  /// 
  /// This factory constructor handles deserialization of subscription data from API responses.
  /// It supports both snake_case and camelCase field naming conventions.
  /// 
  /// Parameters:
  /// - [json]: Map containing route subscription data from API response
  /// 
  /// Returns a new RouteSubscription instance populated from JSON data.
  factory RouteSubscription.fromJson(Map<String, dynamic> json) {
    return RouteSubscription(
      userId: json['user_id'] ?? json['userId'],
      routeId: json['route_id'] ?? json['routeId'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      route: json['route'] != null ? Route.fromJson(json['route']) : null,
    );
  }

  /// Converts the RouteSubscription instance to a JSON map.
  /// 
  /// This method is used when sending subscription data to the API or storing locally.
  /// It uses snake_case field names for API compatibility.
  /// 
  /// Returns a Map<String, dynamic> representing the route subscription data.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'route_id': routeId,
      'user': user?.toJson(),
      'route': route?.toJson(),
    };
  }

  /// Returns a string representation of the RouteSubscription for debugging purposes.
  @override
  String toString() {
    return 'RouteSubscription{userId: $userId, routeId: $routeId}';
  }
}

/// Represents a user's subscription to a specific stop for notifications and tracking.
/// 
/// Stop subscriptions allow users to receive updates about buses arriving at
/// particular stops, get notifications about delays, and track stop-specific
/// information. This enables location-based notifications and personalized
/// transportation alerts.
class StopSubscription {
  /// ID of the user who subscribed to the stop
  final int userId;
  
  /// ID of the stop being subscribed to
  final int stopId;
  
  /// Optional detailed user information
  final User? user;
  
  /// Optional detailed stop information
  final Stop? stop;

  /// Creates a new StopSubscription instance.
  /// 
  /// Required parameters:
  /// - [userId]: ID of the subscribing user
  /// - [stopId]: ID of the stop being subscribed to
  /// 
  /// Optional parameters:
  /// - [user]: Detailed user information
  /// - [stop]: Detailed stop information
  StopSubscription({
    required this.userId,
    required this.stopId,
    this.user,
    this.stop,
  });

  /// Creates a StopSubscription instance from a JSON map.
  /// 
  /// This factory constructor handles deserialization of stop subscription data from API responses.
  /// It supports both snake_case and camelCase field naming conventions.
  /// 
  /// Parameters:
  /// - [json]: Map containing stop subscription data from API response
  /// 
  /// Returns a new StopSubscription instance populated from JSON data.
  factory StopSubscription.fromJson(Map<String, dynamic> json) {
    return StopSubscription(
      userId: json['user_id'] ?? json['userId'],
      stopId: json['stop_id'] ?? json['stopId'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      stop: json['stop'] != null ? Stop.fromJson(json['stop']) : null,
    );
  }

  /// Converts the StopSubscription instance to a JSON map.
  /// 
  /// This method is used when sending stop subscription data to the API or storing locally.
  /// It uses snake_case field names for API compatibility.
  /// 
  /// Returns a Map<String, dynamic> representing the stop subscription data.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'stop_id': stopId,
      'user': user?.toJson(),
      'stop': stop?.toJson(),
    };
  }

  /// Returns a string representation of the StopSubscription for debugging purposes.
  @override
  String toString() {
    return 'StopSubscription{userId: $userId, stopId: $stopId}';
  }
}
