import 'package:app_core/app_core.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/*
Dio
 → LoggingInterceptor
   → AppLogger
     → logger (SourceHorizon)
       → FileLogPrinter
         → log file (text)
           → parseLogLine
             → LogEntry
               → LogDetailPage (UI)
*/

class LoggingInterceptor extends Interceptor {
  /// Print [Response.data]
  final bool responseBody;

  /// Print [Response.headers]
  final bool responseHeader;

  /// Print compact json response
  final bool compact;

  /// Width size per logPrint
  final int maxWidth;

  /// Log printer; defaults logPrint log to console.
  final void Function(String message) logPrint;

  LoggingInterceptor({
    this.responseHeader = false,
    this.responseBody = true,
    this.maxWidth = 90,
    this.compact = true,
    void Function(String message)? logPrint,
  }) : logPrint = logPrint ?? debugPrint;

  late final PrettyLogPrinter _printer = PrettyLogPrinter(
    log: logPrint,
    maxWidth: maxWidth,
    compact: compact,
  );
  late final NetworkLogBuilder _logBuilder = NetworkLogBuilder();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestId =
        options.extra['requestId'] as String? ?? const Uuid().v4();
    options.extra['requestId'] = requestId;
    options.extra['startTime'] = DateTime.now();

    _printer.printApiHeader(
      icon: '➡️',
      title: 'API REQUEST',
      requestId: requestId,
      duration: 0,
    );

    _printer.printRequestHeader(
      method: options.method,
      uri: options.uri.toString(),
    );
    _printer.printCurlCommand(
      method: options.method,
      uri: options.uri,
      headers: options.headers,
      data: options.data,
    );

    // Capture request data as JSON
    final requestJson = _captureRequestJson(options);
    options.extra['_requestJson'] = requestJson;

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestId = err.requestOptions.extra['requestId'] as String? ?? 'N/A';
    final startTime = err.requestOptions.extra['startTime'] as DateTime?;
    final duration = startTime != null
        ? DateTime.now().difference(startTime).inMilliseconds
        : 0;

    _printer.printApiHeader(
      icon: '🔴',
      title: 'API ERROR',
      requestId: requestId,
      duration: duration,
    );

    _printer.printDioError(
      type: err.type.toString(),
      message: err.message,
      statusCode: err.response?.statusCode,
      statusMessage: err.response?.statusMessage,
      uri: err.response?.requestOptions.uri,
      responseData: err.response?.data,
    );

    logPrint('');

    final requestJson =
        err.requestOptions.extra['_requestJson'] as Map<String, dynamic>?;
    final errorJson = _captureErrorJson(err);

    final logGroup = _logBuilder.error(
      requestId: requestId,
      options: err.requestOptions,
      startTime: startTime ?? DateTime.now(),
      statusCode: err.response?.statusCode ?? -1,
      requestJson: requestJson,
      errorJson: errorJson,
    );

    
    AppLogger.file(logGroup);

    final appException = mapDioException(err);

    // Throw AppException so it bubbles up to BLoC
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: appException,
        type: err.type,
        response: err.response,
      ),
    );
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestId =
        response.requestOptions.extra['requestId'] as String? ?? 'N/A';
    final startTime = response.requestOptions.extra['startTime'] as DateTime?;
    final duration = startTime != null
        ? DateTime.now().difference(startTime).inMilliseconds
        : 0;

    _printer.printApiHeader(
      icon: '🟢',
      title: 'API SUCCESS',
      requestId: requestId,
      duration: duration,
    );

    _printer.printResponseHeader(
      method: response.requestOptions.method,
      uri: response.requestOptions.uri.toString(),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
    );

    if (responseHeader) {
      final responseHeaders = <String, dynamic>{};
      response.headers.forEach((k, list) => responseHeaders[k] = list);
      _printer.printResponseHeaders(responseHeaders);
    }

    if (responseBody) {
      _printer.printResponseBody(
        data: response.data,
        includeHeader: true,
      );
    }

    logPrint('');

    final requestJson =
        response.requestOptions.extra['_requestJson'] as Map<String, dynamic>?;
    final responseJson = _captureResponseJson(response);
    final statusCode = response.statusCode ?? -1;
    final logGroup = _logBuilder.success(
      requestId: requestId,
      options: response.requestOptions,
      startTime: startTime ?? DateTime.now(),
      statusCode: statusCode,
      requestJson: requestJson,
      responseJson: responseJson,
    );
    AppLogger.file(logGroup);

    handler.next(response);
  }

// ======== PRIVATE HELPERS ========

  /// Captures request data as structured JSON
  Map<String, dynamic> _captureRequestJson(RequestOptions options) {
    try {
      return {
        'method': options.method,
        'url': options.uri.toString(),
        'path': options.path,
        'queryParameters':
            options.queryParameters.isNotEmpty ? options.queryParameters : null,
        'headers':
            options.headers.isNotEmpty ? Map.from(options.headers) : null,
        'body': options.data,
        'contentType': options.contentType?.toString(),
      };
    } catch (e) {
      return {};
    }
  }

  /// Captures response data as structured JSON
  Map<String, dynamic> _captureResponseJson(Response response) {
    try {
      final responseHeaders = <String, dynamic>{};
      response.headers.forEach((k, list) => responseHeaders[k] = list);

      return {
        'statusCode': response.statusCode,
        'statusMessage': response.statusMessage,
        'headers': responseHeaders.isNotEmpty ? responseHeaders : null,
        'data': response.data,
      };
    } catch (e) {
      return {};
    }
  }

  /// Captures error data as structured JSON
  Map<String, dynamic> _captureErrorJson(DioException err) {
    try {
      final responseHeaders = <String, dynamic>{};
      if (err.response != null) {
        err.response!.headers.forEach((k, list) => responseHeaders[k] = list);
      }

      return {
        'type': err.type.toString(),
        'message': err.message,
        'statusCode': err.response?.statusCode,
        'statusMessage': err.response?.statusMessage,
        'headers': responseHeaders.isNotEmpty ? responseHeaders : null,
        'data': err.response?.data,
      };
    } catch (e) {
      return {};
    }
  }
}
