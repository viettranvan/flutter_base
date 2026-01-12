import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'file_logger.dart';

// TODO: 1: chia môi trường -> log interceptor chỉ hiện ở dev?
// TODO: 2: Có nên log reuqest vào file không?

final _fileLogOutput = FileLogOutput();

final _consoleLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    printEmojis: false,
    colors: false,
  ),
  output: ConsoleOutput(),
);

final _fileLogger = Logger(
  printer: FileLogPrinter(),
  output: _fileLogOutput,
  level: kDebugMode ? Level.debug : Level.info,
);

Future<void> initFileLogging() async {
  await _fileLogOutput.init();
  AppLogger.i('File logging initialized');
}

String? getLogFilePath() => _fileLogOutput.logFilePath;

Future<void> clearOldLogs({int olderThanDays = 7}) =>
    _fileLogOutput.clearOldLogs(olderThanDays: olderThanDays);

class AppLogger {
  static void d(String message, {dynamic error, StackTrace? stackTrace}) {
    _consoleLogger.d(message, error: error, stackTrace: stackTrace);
    _fileLogger.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(String message, {dynamic error, StackTrace? stackTrace}) {
    _consoleLogger.i(message, error: error, stackTrace: stackTrace);
    _fileLogger.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(String message, {dynamic error, StackTrace? stackTrace}) {
    _consoleLogger.w(message, error: error, stackTrace: stackTrace);
    _fileLogger.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(String message, {dynamic error, StackTrace? stackTrace}) {
    _consoleLogger.e(message, error: error, stackTrace: stackTrace);
    _fileLogger.e(message, error: error, stackTrace: stackTrace);
  }

  static void f(String message, {dynamic error, StackTrace? stackTrace}) {
    _consoleLogger.f(message, error: error, stackTrace: stackTrace);
    _fileLogger.f(message, error: error, stackTrace: stackTrace);
  }
}

class FileLogPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final time = DateTime.now().toIso8601String();
    final level = event.level.name.toUpperCase();

    final buffer = StringBuffer()
      ..write('[$time]')
      ..write(' [$level]')
      ..write(' ${event.message}');

    if (event.error != null) {
      buffer.write(' | error=${event.error}');
    }

    if (event.stackTrace != null) {
      buffer.write('\n${event.stackTrace}');
    }

    return [buffer.toString()];
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
