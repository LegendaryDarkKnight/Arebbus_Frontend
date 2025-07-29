import 'package:arebbus/models/bus.dart';

/// Represents a paginated response containing a list of buses from the API.
/// 
/// This model is used when fetching buses with pagination support, such as
/// when browsing all available buses or filtering installed buses. It contains
/// the actual bus data along with pagination metadata that helps with
/// implementing infinite scroll, page navigation, and data loading strategies.
class BusResponse {
  /// List of buses returned in this page of results
  final List<Bus> buses;
  
  /// Current page number (0-based)
  final int page;
  
  /// Number of items per page
  final int size;
  
  /// Total number of pages available
  final int totalPages;
  
  /// Total number of bus elements across all pages
  final int totalElements;

  /// Creates a new BusResponse instance.
  /// 
  /// Parameters:
  /// - [buses]: List of buses for this page
  /// - [page]: Current page number (0-based)
  /// - [size]: Number of items per page
  /// - [totalPages]: Total number of pages available
  /// - [totalElements]: Total number of bus elements across all pages
  BusResponse({
    required this.buses,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  /// Creates a BusResponse instance from a JSON map.
  /// 
  /// This factory constructor handles deserialization of paginated bus data
  /// from API responses. It properly deserializes the nested list of buses
  /// and provides safe defaults for pagination metadata.
  /// 
  /// Parameters:
  /// - [json]: Map containing paginated bus response data from API
  /// 
  /// Returns a new BusResponse instance populated from JSON data.
  factory BusResponse.fromJson(Map<String, dynamic> json) {
    return BusResponse(
      buses: (json['buses'] as List<dynamic>)
          .map((busJson) => Bus.fromJson(busJson as Map<String, dynamic>))
          .toList(),
      page: json['page'] ?? 0,
      size: json['size'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
    );
  }

  /// Converts the BusResponse instance to a JSON map.
  /// 
  /// This method is used when caching response data locally or for debugging purposes.
  /// It properly serializes the nested list of buses along with pagination metadata.
  /// 
  /// Returns a Map<String, dynamic> representing the bus response data.
  Map<String, dynamic> toJson() {
    return {
      'buses': buses.map((bus) => bus.toJson()).toList(),
      'page': page,
      'size': size,
      'totalPages': totalPages,
      'totalElements': totalElements,
    };
  }
}