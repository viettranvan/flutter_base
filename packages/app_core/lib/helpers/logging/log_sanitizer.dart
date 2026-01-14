/// Sanitizes log messages by removing or masking sensitive data
class LogSanitizer {
  static const String _mask = '***';

  /// Sanitize a log message by removing/masking sensitive data
  /// Removes: Bearer tokens, API keys, passwords, emails, credit cards
  static String sanitize(String message) {
    var sanitized = message;

    // Mask Bearer tokens
    sanitized = sanitized.replaceAll(
      RegExp(r'Bearer\s+[\w\-_.]+'),
      'Bearer $_mask',
    );

    // Mask Authorization headers
    sanitized = sanitized.replaceAll(
      RegExp(r'"authorization":\s*"[^"]*"', caseSensitive: false),
      '"authorization": "$_mask"',
    );

    // Mask token fields in JSON
    sanitized = sanitized.replaceAll(
      RegExp(r'"token":\s*"[^"]*"', caseSensitive: false),
      '"token": "$_mask"',
    );

    // Mask refreshToken fields
    sanitized = sanitized.replaceAll(
      RegExp(r'"refreshToken":\s*"[^"]*"', caseSensitive: false),
      '"refreshToken": "$_mask"',
    );

    // Mask password fields
    sanitized = sanitized.replaceAll(
      RegExp(r'"password":\s*"[^"]*"', caseSensitive: false),
      '"password": "$_mask"',
    );

    // Mask API keys (common patterns)
    sanitized = sanitized.replaceAll(
      RegExp(r'"api[_-]?key":\s*"[^"]*"', caseSensitive: false),
      '"api_key": "$_mask"',
    );

    // Mask secret keys
    sanitized = sanitized.replaceAll(
      RegExp(r'"secret[_-]?key?":\s*"[^"]*"', caseSensitive: false),
      '"secret_key": "$_mask"',
    );

    // Mask credit card numbers (common patterns)
    sanitized = sanitized.replaceAll(
      RegExp(r'\b\d{4}[\s\-]?\d{4}[\s\-]?\d{4}[\s\-]?\d{4}\b'),
      '****-****-****-****',
    );

    // Mask SSN pattern (XXX-XX-XXXX)
    sanitized = sanitized.replaceAll(
      RegExp(r'\b\d{3}-\d{2}-\d{4}\b'),
      '***-**-****',
    );

    // Mask email addresses (partially)
    sanitized = sanitized.replaceAll(
      RegExp(r'([a-zA-Z0-9._%-]+)@([a-zA-Z0-9.-]+)'),
      '***@***',
    );

    return sanitized;
  }

  /// Check if message contains sensitive data patterns
  static bool containsSensitiveData(String message) {
    final sensitivePatterns = [
      RegExp(r'Bearer\s+', caseSensitive: false),
      RegExp(r'"(token|password|api.?key|secret.?key)"', caseSensitive: false),
      RegExp(r'\b\d{4}[\s\-]?\d{4}[\s\-]?\d{4}[\s\-]?\d{4}\b'),
      RegExp(r'\b\d{3}-\d{2}-\d{4}\b'),
      RegExp(r'[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+'),
    ];

    return sensitivePatterns.any((pattern) => pattern.hasMatch(message));
  }
}
