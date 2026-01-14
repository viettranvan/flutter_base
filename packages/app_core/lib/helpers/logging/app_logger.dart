import 'package:app_core/app_core.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final _fileLogOutput = FileLogOutput();

final _consoleLogger = Logger(
  printer: RawConsolePrinter(),
  output: PlainConsoleOutput(),
);

final _fileLogger = Logger(
  printer: FileLogPrinter(),
  output: _fileLogOutput,
  level: kDebugMode ? Level.debug : Level.info,
);

/// Initialize file logging with environment-based configuration
Future<void> initFileLogging({AppCoreConfig? coreConfig}) async {
  // Determine if file logging should be enabled
  final shouldEnableFileLogging = _shouldEnableFileLogging(coreConfig);

  // Configure file logging based on environment
  _fileLogOutput.setFileLoggingEnabled(shouldEnableFileLogging);

  // Always sanitize for dev/staging, optional override for production
  final shouldSanitize = coreConfig?.environment.toLowerCase() != 'production';
  _fileLogOutput.setSanitizationEnabled(shouldSanitize);

  await _fileLogOutput.init();

  if (shouldEnableFileLogging) {
    AppLogger.i(
      'File logging initialized (environment: ${coreConfig?.environment ?? "unknown"})',
    );
  }
}

/// Determine if file logging should be enabled based on environment
bool _shouldEnableFileLogging(AppCoreConfig? coreConfig) {
  if (coreConfig == null) return true; // Default to enabled if no config

  // Disable file logging only for production
  return coreConfig.environment.toLowerCase() != 'production';
}

String? getLogFilePath() => _fileLogOutput.logFilePath;

Future<void> clearOldLogs({int olderThanDays = 7}) =>
    _fileLogOutput.clearOldLogs(olderThanDays: olderThanDays);

class AppLogger {
  static void d(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _consoleLogger.d(message, error: error, stackTrace: stackTrace);
    _fileLogger.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _consoleLogger.i(message, error: error, stackTrace: stackTrace);
    _fileLogger.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _consoleLogger.w(message, error: error, stackTrace: stackTrace);
    _fileLogger.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _consoleLogger.e(message, error: error, stackTrace: stackTrace);
    _fileLogger.e(message, error: error, stackTrace: stackTrace);
  }

  static void f(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _consoleLogger.f(message, error: error, stackTrace: stackTrace);
    _fileLogger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Network / interceptor logs → FILE ONLY
  static void file(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    _fileLogger.d(message, error: error, stackTrace: stackTrace);
  }
}

class PlainConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      debugPrint(line);
    }
  }
}

class RawConsolePrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    return [event.message.toString()];
  }
}
