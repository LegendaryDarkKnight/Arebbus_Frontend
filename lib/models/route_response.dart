import 'package:arebbus/models/route.dart';

/// Represents a paginated response containing route data from the Arebbus API.
/// 
/// This model handles API responses that return multiple routes with pagination
/// information. It's used when fetching lists of routes, such as when browsing
/// available routes, searching for specific routes, or loading routes for
/// a particular area or user preferences.
/// 
/// The response includes both the route data and pagination metadata to support
/// efficient loading of large route datasets.
class RouteResponse {
  /// List of routes returned in this response page
  final List<Route> routes;
  
  /// Current page number (typically 0-based from API)
  final int page;
  
  /// Number of items per page requested
  final int size;
  
  /// Total number of pages available
  final int totalPages;
  
  /// Total number of route elements across all pages
  final int totalElements;

  /// Creates a new RouteResponse instance.
  /// 
  /// All parameters are required to ensure complete pagination information.
  RouteResponse({
    required this.routes,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  /// Creates a RouteResponse instance from a JSON map.
  /// 
  /// This factory constructor deserializes JSON data from the API into
  /// a RouteResponse object, including parsing the list of routes and
  /// pagination metadata.
  /// 
  /// Parameter:
  /// - [json]: JSON map containing the route response data
  /// 
  /// Returns: A new RouteResponse instance with data populated from JSON
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

  /// Converts this RouteResponse instance to a JSON map.
  /// 
  /// This method serializes the RouteResponse object to a JSON-compatible map,
  /// including serializing the list of routes and pagination information.
  /// 
  /// Returns: A JSON map representation of this RouteResponse
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