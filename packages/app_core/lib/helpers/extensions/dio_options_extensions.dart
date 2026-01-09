import 'package:dio/dio.dart';

/// Dio Options utility extensions
extension DioOptionsX on Options {
  /// Create new Options with updated timeout values
  /// Note: copyWith doesn't support timeout params, so we create new instance
  Options withTimeout({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    return Options(
      method: method,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      extra: extra,
      headers: headers,
      responseType: responseType,
      contentType: contentType,
      validateStatus: validateStatus,
      receiveDataWhenStatusError: receiveDataWhenStatusError,
      followRedirects: followRedirects,
      maxRedirects: maxRedirects,
      persistentConnection: persistentConnection,
    );
  }

  /// Set authorization header with Bearer token
  Options withBearerToken(String token) {
    return copyWith(
      headers: {...?headers, 'Authorization': 'Bearer $token'},
    );
  }

  /// Set custom headers
  Options withHeaders(Map<String, dynamic> customHeaders) {
    return copyWith(
      headers: {...?headers, ...customHeaders},
    );
  }

  /// Set request content type
  Options withContentType(String contentType) {
    return copyWith(contentType: contentType);
  }

  /// Set response type
  Options withResponseType(ResponseType responseType) {
    return copyWith(responseType: responseType);
  }

  /// Set validate status predicate
  Options withValidateStatus(bool Function(int?)? validateStatus) {
    return copyWith(validateStatus: validateStatus);
  }

  /// Accept all status codes
  Options acceptAllStatusCodes() {
    return copyWith(validateStatus: (_) => true);
  }

  /// Set follow redirects
  Options withFollowRedirects(bool follow, {int? maxRedirects}) {
    return copyWith(
      followRedirects: follow,
      maxRedirects: maxRedirects,
    );
  }

  /// Set extra data (for custom usage)
  Options withExtra(Map<String, dynamic> extraData) {
    return copyWith(
      extra: {...?extra, ...extraData},
    );
  }

  /// Merge multiple options
  Options mergeWith(Options other) {
    return copyWith(
      method: other.method ?? method,
      sendTimeout: other.sendTimeout ?? sendTimeout,
      receiveTimeout: other.receiveTimeout ?? receiveTimeout,
      extra: {...?extra, ...?other.extra},
      headers: {...?headers, ...?other.headers},
      responseType: other.responseType ?? responseType,
      contentType: other.contentType ?? contentType,
      validateStatus: other.validateStatus ?? validateStatus,
      receiveDataWhenStatusError:
          other.receiveDataWhenStatusError ?? receiveDataWhenStatusError,
      followRedirects: other.followRedirects ?? followRedirects,
      maxRedirects: other.maxRedirects ?? maxRedirects,
      persistentConnection: other.persistentConnection ?? persistentConnection,
    );
  }
}

/// Response utility extensions
extension ResponseX on Response {
  /// Check if response is successful (2xx)
  bool get isSuccessful =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;

  /// Get response data as Map
  Map<String, dynamic>? get dataAsMap {
    if (data is Map) {
      return Map<String, dynamic>.from(data as Map);
    }
    return null;
  }

  /// Get response data as List
  List<dynamic>? get dataAsList {
    if (data is List) {
      return data as List<dynamic>;
    }
    return null;
  }

  /// Get nested value from response data using dot notation
  /// e.g., "user.name" or "data.0.id"
  dynamic getValueByPath(String path) {
    final keys = path.split('.');
    dynamic current = data;

    for (final key in keys) {
      if (current is Map) {
        current = current[key];
      } else if (current is List) {
        final index = int.tryParse(key);
        if (index != null && index < current.length) {
          current = current[index];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }

    return current;
  }
}
