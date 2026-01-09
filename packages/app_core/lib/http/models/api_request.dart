/// Standard API request model
class ApiRequest {
  final String path;
  final dynamic body;
  final Map<String, dynamic>? queryParameters;
  final Map<String, dynamic>? headers;
  final String? contentType;

  const ApiRequest({
    required this.path,
    this.body,
    this.queryParameters,
    this.headers,
    this.contentType,
  });

  /// Create request with JSON content type
  factory ApiRequest.json({
    required String path,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) {
    return ApiRequest(
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      contentType: 'application/json',
    );
  }

  /// Create request with form data content type
  factory ApiRequest.formData({
    required String path,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) {
    return ApiRequest(
      path: path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      contentType: 'multipart/form-data',
    );
  }
}
