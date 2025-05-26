import 'route.dart';
import 'stop.dart';
import 'user.dart';

class RouteSubscription {
  final int userId;
  final int routeId;
  final User? user;
  final Route? route;

  RouteSubscription({
    required this.userId,
    required this.routeId,
    this.user,
    this.route,
  });

  factory RouteSubscription.fromJson(Map<String, dynamic> json) {
    return RouteSubscription(
      userId: json['user_id'] ?? json['userId'],
      routeId: json['route_id'] ?? json['routeId'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      route: json['route'] != null ? Route.fromJson(json['route']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'route_id': routeId,
      'user': user?.toJson(),
      'route': route?.toJson(),
    };
  }

  @override
  String toString() {
    return 'RouteSubscription{userId: $userId, routeId: $routeId}';
  }
}

class StopSubscription {
  final int userId;
  final int stopId;
  final User? user;
  final Stop? stop;

  StopSubscription({
    required this.userId,
    required this.stopId,
    this.user,
    this.stop,
  });

  factory StopSubscription.fromJson(Map<String, dynamic> json) {
    return StopSubscription(
      userId: json['user_id'] ?? json['userId'],
      stopId: json['stop_id'] ?? json['stopId'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      stop: json['stop'] != null ? Stop.fromJson(json['stop']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'stop_id': stopId,
      'user': user?.toJson(),
      'stop': stop?.toJson(),
    };
  }

  @override
  String toString() {
    return 'StopSubscription{userId: $userId, stopId: $stopId}';
  }
}
