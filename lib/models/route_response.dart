import 'package:arebbus/models/route.dart';

class RouteResponse {
  final List<Route> routes;
  final int page;
  final int size;
  final int totalPages;
  final int totalElements;

  RouteResponse({
    required this.routes,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    return RouteResponse(
      routes: (json['routes'] as List<dynamic>)
          .map((routeJson) => Route.fromJson(routeJson as Map<String, dynamic>))
          .toList(),
      page: json['page'] ?? 0,
      size: json['size'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routes': routes.map((route) => route.toJson()).toList(),
      'page': page,
      'size': size,
      'totalPages': totalPages,
      'totalElements': totalElements,
    };
  }
}