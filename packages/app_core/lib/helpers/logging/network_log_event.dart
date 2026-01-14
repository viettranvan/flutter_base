enum NetworkLogType {
  group, // summary row
  request, // request detail
  curl, // curl command
  response, // response detail
  error, // error detail
}

class NetworkLogEvent {
  final String requestId;
  final NetworkLogType type;

  final String method;
  final String url;

  final int? statusCode;
  final int? durationMs;

  final DateTime timestamp;

  NetworkLogEvent({
    required this.requestId,
    required this.type,
    required this.method,
    required this.url,
    required this.timestamp,
    this.statusCode,
    this.durationMs,
  });

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'type': type.name,
      'method': method,
      'url': url,
      'statusCode': statusCode,
      'durationMs': durationMs,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory NetworkLogEvent.fromJson(Map<String, dynamic> json) {
    return NetworkLogEvent(
      requestId: json['requestId'] as String,
      type: NetworkLogType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      method: json['method'] as String,
      url: json['url'] as String,
      statusCode: json['statusCode'] as int?,
      durationMs: json['durationMs'] as int?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
