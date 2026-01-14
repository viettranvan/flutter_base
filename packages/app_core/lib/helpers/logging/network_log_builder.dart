import 'package:app_core/app_core.dart';

enum NetworkLogPhase {
  request,
  curl,
  response,
  error,
}

/// ===============================================================
/// NetworkLogPhaseData
/// ---------------------------------------------------------------
/// Data container for a single phase.
/// - `text`   : raw ASCII / human-readable output
/// - `data`   : optional structured payload (headers, body, etc.)
///
/// `data` is intentionally generic to allow future extension
/// without changing the core model.
/// ===============================================================
class NetworkLogPhaseData {
  final NetworkLogPhase phase;

  /// Human-readable content (multi-line ASCII)
  final String? text;

  /// Structured data for advanced filtering / inspection
  final Map<String, dynamic>? data;

  NetworkLogPhaseData({
    required this.phase,
    this.text,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'phase': phase.name,
      if (text != null) 'text': text,
      if (data != null) 'data': data,
    };
  }
}

/// ===============================================================
/// NetworkLogStatus
/// ---------------------------------------------------------------
/// Represents HTTP status result.
/// Extracted as a value object to simplify filtering:
///   - success / failure
///   - status code
/// ===============================================================
class NetworkLogStatus {
  final int? code;
  final bool success;

  NetworkLogStatus({
    required this.code,
    required this.success,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'success': success,
    };
  }
}

/// ===============================================================
/// NetworkLogTiming
/// ---------------------------------------------------------------
/// Timing information for a network request.
/// Provides:
///   - start time
///   - end time
///   - computed duration
/// ===============================================================
class NetworkLogTiming {
  final DateTime startedAt;
  final DateTime endedAt;

  NetworkLogTiming({
    required this.startedAt,
    required this.endedAt,
  });

  int get durationMs => endedAt.difference(startedAt).inMilliseconds;

  Map<String, dynamic> toJson() {
    return {
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'durationMs': durationMs,
    };
  }
}

/// ===============================================================
/// NetworkLogGroup
/// ---------------------------------------------------------------
/// The ROOT object representing ONE HTTP transaction.
///
/// This is the object that will be:
///   - emitted as JSON into log files
///   - consumed by UI for grouping & filtering
///   - exported for debugging / support
///
/// Design notes:
///   - `phases` is a Map for O(1) access
///   - No assumption that all phases exist
///   - No formatting logic inside this class
/// ===============================================================
class NetworkLogGroup {
  final String id;

  final String method;
  final String url;
  final String path;

  final NetworkLogTiming timing;
  final NetworkLogStatus status;

  /// Phase → Data mapping
  final Map<NetworkLogPhase, NetworkLogPhaseData> phases;

  NetworkLogGroup({
    required this.id,
    required this.method,
    required this.url,
    required this.path,
    required this.timing,
    required this.status,
    required this.phases,
  });

  bool get hasError => phases.containsKey(NetworkLogPhase.error);

  Map<String, dynamic> toJson() {
    return {
      'type': 'network',
      'id': id,
      'method': method,
      'url': url,
      'path': path,
      'timing': timing.toJson(),
      'status': status.toJson(),
      'phases': {
        for (final entry in phases.entries)
          entry.key.name: entry.value.toJson(),
      },
    };
  }
}

class NetworkLogBuilder {
  NetworkLogGroup success({
    required String requestId,
    required RequestOptions options,
    required DateTime startTime,
    required Map<String, dynamic>? requestJson,
    required Map<String, dynamic>? responseJson,
    required int statusCode,
  }) {
    return _build(
      requestId: requestId,
      method: options.method,
      uri: options.uri,
      path: options.path,
      startTime: startTime,
      statusCode: statusCode,
      success: true,
      requestJson: requestJson,
      responseJson: responseJson,
    );
  }

  NetworkLogGroup error({
    required String requestId,
    required RequestOptions options,
    required DateTime startTime,
    required Map<String, dynamic>? requestJson,
    required Map<String, dynamic>? errorJson,
    required int statusCode,
  }) {
    return _build(
      requestId: requestId,
      method: options.method,
      uri: options.uri,
      path: options.path,
      startTime: startTime,
      statusCode: statusCode,
      success: false,
      requestJson: requestJson,
      errorJson: errorJson,
    );
  }

  NetworkLogGroup _build({
    required String requestId,
    required String method,
    required Uri uri,
    required String path,
    required DateTime startTime,
    required int statusCode,
    required bool success,
    Map<String, dynamic>? requestJson,
    Map<String, dynamic>? responseJson,
    Map<String, dynamic>? errorJson,
  }) {
    return NetworkLogGroup(
      id: requestId,
      method: method,
      url: uri.toString(),
      path: path,
      timing: NetworkLogTiming(
        startedAt: startTime,
        endedAt: DateTime.now(),
      ),
      status: NetworkLogStatus(
        code: statusCode,
        success: success,
      ),
      phases: {
        if (requestJson != null)
          NetworkLogPhase.request: NetworkLogPhaseData(
              phase: NetworkLogPhase.request, data: requestJson),
        if (responseJson != null)
          NetworkLogPhase.response: NetworkLogPhaseData(
              phase: NetworkLogPhase.response, data: responseJson),
        if (errorJson != null)
          NetworkLogPhase.error: NetworkLogPhaseData(
              phase: NetworkLogPhase.error, data: errorJson),
      },
    );
  }
}
