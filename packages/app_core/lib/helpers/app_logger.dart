import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Global logger instance
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: kDebugMode ? Level.debug : Level.warning,
);

/// Extension for easy logging
extension LoggerExtension on Logger {
  /// Log debug message with optional error and stack trace
  void d(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    log(
      Level.debug,
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log info message
  void i(String message, {dynamic error, StackTrace? stackTrace}) {
    log(
      Level.info,
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log warning message
  void w(String message, {dynamic error, StackTrace? stackTrace}) {
    log(
      Level.warning,
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log error message
  void e(String message, {dynamic error, StackTrace? stackTrace}) {
    log(
      Level.error,
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log fatal/critical message
  void f(String message, {dynamic error, StackTrace? stackTrace}) {
    log(
      Level.fatal,
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
