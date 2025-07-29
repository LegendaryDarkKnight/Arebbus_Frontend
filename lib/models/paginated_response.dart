/// Generic paginated response wrapper for API responses in the Arebbus application.
/// 
/// This model provides a standardized structure for all paginated API responses,
/// ensuring consistent pagination handling throughout the app. It supports generic
/// typing to maintain type safety while providing flexible pagination for different
/// data types like buses, posts, comments, etc.
/// 
/// Type parameter [T] represents the type of data being paginated.
class PaginatedResponse<T> {
  /// List of items for the current page
  final List<T> data;
  
  /// Current page number (typically 1-based)
  final int currentPage;
  
  /// Total number of pages available
  final int totalPages;
  
  /// Total number of items across all pages
  final int totalItems;
  
  /// Number of items per page
  final int itemsPerPage;
  
  /// Whether there are more pages after the current page
  final bool hasNext;
  
  /// Whether there are pages before the current page
  final bool hasPrevious;

  /// Creates a new PaginatedResponse instance.
  /// 
  /// Parameters:
  /// - [data]: List of items for the current page
  /// - [currentPage]: Current page number
  /// - [totalPages]: Total number of pages available
  /// - [totalItems]: Total number of items across all pages
  /// - [itemsPerPage]: Number of items per page
  /// - [hasNext]: Whether there are more pages available
  /// - [hasPrevious]: Whether there are previous pages available
  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNext,
    required this.hasPrevious,
  });

  /// Creates a PaginatedResponse instance from a JSON map.
  /// 
  /// This factory constructor deserializes JSON data into a PaginatedResponse
  /// object. The generic [fromJsonT] function is used to deserialize individual
  /// items in the data array to type [T].
  /// 
  /// Parameters:
  /// - [json]: JSON map containing the paginated response data
  /// - [fromJsonT]: Function to convert JSON objects to type [T]
  /// 
  /// Returns: A new PaginatedResponse<T> instance with populated data
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data: (json['data'] as List).map((item) => fromJsonT(item)).toList(),
      currentPage: json['current_page'] ?? json['currentPage'] ?? 1,
      totalPages: json['total_pages'] ?? json['totalPages'] ?? 1,
      totalItems: json['total_items'] ?? json['totalItems'] ?? 0,
      itemsPerPage: json['items_per_page'] ?? json['itemsPerPage'] ?? 10,
      hasNext: json['has_next'] ?? json['hasNext'] ?? false,
      hasPrevious: json['has_previous'] ?? json['hasPrevious'] ?? false,
    );
  }

  /// Converts this PaginatedResponse instance to a JSON map.
  /// 
  /// This method serializes the PaginatedResponse object to a JSON-compatible
  /// map structure. The [toJsonT] function is used to serialize individual
  /// items in the data array.
  /// 
  /// Parameter:
  /// - [toJsonT]: Function to convert type [T] objects to JSON maps
  /// 
  /// Returns: A JSON map representation of this PaginatedResponse
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'data': data.map((item) => toJsonT(item)).toList(),
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'items_per_page': itemsPerPage,
      'has_next': hasNext,
      'has_previous': hasPrevious,
    };
  }

  /// Returns whether this response represents the first page.
  /// 
  /// Returns: `true` if current page is 1, `false` otherwise
  bool get isFirstPage => currentPage == 1;

  /// Returns whether this response represents the last page.
  /// 
  /// Returns: `true` if current page equals total pages, `false` otherwise
  bool get isLastPage => currentPage >= totalPages;

  /// Returns whether the response contains any data.
  /// 
  /// Returns: `true` if data list is not empty, `false` otherwise
  bool get hasData => data.isNotEmpty;

  /// Returns the number of items in the current page.
  /// 
  /// Returns: Count of items in the data list
  int get currentPageItemCount => data.length;
}
