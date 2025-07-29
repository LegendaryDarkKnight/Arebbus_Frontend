import 'package:arebbus/models/stop.dart';

/// Represents a paginated response containing stop data from the Arebbus API.
/// 
/// This model handles API responses that return multiple bus stops with
/// pagination information. It's used when fetching lists of stops, such as
/// when browsing stops in an area, searching for specific stops, or loading
/// stops along a particular route.
/// 
/// The response includes both the stop data and pagination metadata to support
/// efficient loading of large stop datasets.
class StopResponse {
  /// List of stops returned in this response page
  final List<Stop> stops;
  
  /// Current page number (typically 0-based from API)
  final int page;
  
  /// Number of items per page requested
  final int size;
  
  /// Total number of pages available
  final int totalPages;
  
  /// Total number of stop elements across all pages
  final int totalElements;

  /// Creates a new StopResponse instance.
  /// 
  /// All parameters are required to ensure complete pagination information.
  StopResponse({
    required this.stops,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  /// Creates a StopResponse instance from a JSON map.
  /// 
  /// This factory constructor deserializes JSON data from the API into
  /// a StopResponse object, including parsing the list of stops and
  /// pagination metadata.
  /// 
  /// Parameter:
  /// - [json]: JSON map containing the stop response data
  /// 
  /// Returns: A new StopResponse instance with data populated from JSON
  factory StopResponse.fromJson(Map<String, dynamic> json) {
    return StopResponse(
      stops: (json['stops'] as List)
          .map((stop) => Stop.fromJson(stop as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      size: json['size'] as int,
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
    );
  }

  /// Converts this StopResponse instance to a JSON map.
  /// 
  /// This method serializes the StopResponse object to a JSON-compatible map,
  /// including serializing the list of stops and pagination information.
  /// 
  /// Returns: A JSON map representation of this StopResponse
  Map<String, dynamic> toJson() {
    return {
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'page': page,
      'size': size,
      'totalPages': totalPages,
      'totalElements': totalElements,
    };
  }
}