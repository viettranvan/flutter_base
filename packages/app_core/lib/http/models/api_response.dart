/// Standard API response format used across the application
/// Simple & generic format - adapter level handles error parsing/mapping
///
/// Usage Examples:
/// ```dart
/// // Adapter creates success response
/// final response = ApiResponse.success(
///   statusCode: 200,
///   data: User.fromJson(json),
///   message: 'User loaded',
/// );
///
/// // Adapter creates error response with raw error for parsing
/// final errorResponse = ApiResponse.error(
///   statusCode: 422,
///   message: 'Validation failed',
///   rawError: response.data['errors'], // Keep raw for project-specific handling
/// );
///
/// // Usage in feature layer
/// if (response.success) {
///   print('User: ${response.data}');
/// } else {
///   print('Error: ${response.message}');
///   // Project adapter handles rawError based on backend format
///   if (response.rawError is Map) {
///     // Parse validation errors
///   }
/// }
/// ```
class ApiResponse<T> {
  final int statusCode;
  final T? data;
  final String? message;
  final bool success;
  final dynamic rawResponse; // Original Dio Response
  final dynamic rawError; // Original error data from API (for adapter to parse)

  const ApiResponse({
    required this.statusCode,
    this.data,
    this.message,
    required this.success,
    this.rawResponse,
    this.rawError,
  });

  /// Create successful response
  factory ApiResponse.success({
    required int statusCode,
    required T data,
    String? message,
    dynamic rawResponse,
  }) {
    return ApiResponse(
      statusCode: statusCode,
      data: data,
      message: message,
      success: true,
      rawResponse: rawResponse,
    );
  }

  /// Create error response - simple, adapter handles parsing
  factory ApiResponse.error({
    required int statusCode,
    String? message,
    dynamic rawError,
    dynamic rawResponse,
  }) {
    return ApiResponse(
      statusCode: statusCode,
      data: null,
      message: message,
      success: false,
      rawResponse: rawResponse,
      rawError: rawError,
    );
  }

  /// Check if response is successful (2xx status code)
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  @override
  String toString() => '''
ApiResponse(
  statusCode: $statusCode,
  success: $success,
  data: $data,
  message: $message,
)''';
}
