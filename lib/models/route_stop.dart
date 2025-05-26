import 'route.dart';
import 'stop.dart';
import 'user.dart';

class RouteStop {
  final int routeId;
  final int stopId;
  final int stopIndex;
  final int authorId;
  final Route? route;
  final Stop? stop;
  final User? author;

  RouteStop({
    required this.routeId,
    required this.stopId,
    required this.stopIndex,
    required this.authorId,
    this.route,
    this.stop,
    this.author,
  });

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

  @override
  String toString() {
    return 'RouteStop{routeId: $routeId, stopId: $stopId, index: $stopIndex}';
  }
}
