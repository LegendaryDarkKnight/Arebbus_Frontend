/// Generic wrapper for API responses in the Arebbus application.
/// 
/// This model provides a standardized structure for all API responses,
/// ensuring consistent error handling and data parsing throughout the app.
/// It supports generic typing to maintain type safety while providing
/// flexible response handling for different data types.
/// 
/// Type parameter [T] represents the type of data returned in successful responses.
class ApiResponse<T> {
  /// Indicates whether the API operation was successful
  final bool success;
  
  /// Response message providing additional context or error details
  final String message;
  
  /// The actual data returned by the API (null if operation failed)
  final T? data;
  
  /// Optional map of field-specific errors for validation failures
  final Map<String, dynamic>? errors;

  /// Creates a new ApiResponse instance.
  /// 
  /// Parameters:
  /// - [success]: Whether the operation was successful
  /// - [message]: Response message or error description
  /// - [data]: Optional data payload (null for errors)
  /// - [errors]: Optional field-specific error details
  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  /// Creates an ApiResponse instance from a JSON map.
  /// 
  /// This factory constructor handles deserialization of API response data.
  /// It supports custom deserialization functions for complex data types.
  /// 
  /// Parameters:
  /// - [json]: Map containing API response data
  /// - [fromJsonT]: Optional function to deserialize the data field
  /// 
  /// Returns a new ApiResponse instance populated from JSON data.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          json['data'] != null && fromJsonT != null
              ? fromJsonT(json['data'])
              : json['data'],
      errors: json['errors'],
    );
  }

  /// Creates a successful ApiResponse with the provided data.
  /// 
  /// This factory constructor is a convenience method for creating
  /// successful responses with a default success message.
  /// 
  /// Parameters:
  /// - [data]: The data to include in the response
  /// - [message]: Optional success message (defaults to 'Success')
  /// 
  /// Returns a successful ApiResponse instance.
  factory ApiResponse.success(T data, {String message = 'Success'}) {
    return ApiResponse<T>(success: true, message: message, data: data);
  }

  /// Creates an error ApiResponse with the provided message.
  /// 
  /// This factory constructor is a convenience method for creating
  /// error responses without data but with optional field-specific errors.
  /// 
  /// Parameters:
  /// - [message]: Error message describing what went wrong
  /// - [errors]: Optional map of field-specific validation errors
  /// 
  /// Returns an error ApiResponse instance.
  factory ApiResponse.error(String message, {Map<String, dynamic>? errors}) {
    return ApiResponse<T>(success: false, message: message, errors: errors);
  }
}
