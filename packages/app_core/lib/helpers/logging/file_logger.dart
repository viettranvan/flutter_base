import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class FileLogOutput extends LogOutput {
  File? _logFile;
  bool _isInitialized = false;
  Future _writeQueue = Future.value();

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${dir.path}/logs');

      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      // Use only date (YYYY-MM-DD) so logs from same day are grouped
      final today = DateTime.now();
      final dateStr =
          '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final logPath = '${logDir.path}/app_$dateStr.log';

      _logFile = File(logPath);
      _isInitialized = true;
    } catch (e) {
      debugPrint('FileLogOutput init error: $e');
    }
  }

  String? get logFilePath =>
      _isInitialized && _logFile != null ? _logFile!.path : null;

  Future<void> clearOldLogs({int olderThanDays = 7}) async {
    if (!_isInitialized) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${dir.path}/logs');
      if (!await logDir.exists()) return;

      final now = DateTime.now();
      for (final entity in logDir.listSync()) {
        if (entity is File && entity.path.endsWith('.log')) {
          final stat = await entity.stat();
          if (now.difference(stat.modified).inDays > olderThanDays) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error clearing old logs: $e');
    }
  }

  @override
  void output(OutputEvent event) {
    if (!_isInitialized || _logFile == null) return;

    final text = '${event.lines.join('\n')}\n';
    _enqueueWrite(text);
  }

  void _enqueueWrite(String text) {
    _writeQueue = _writeQueue.then((_) async {
      try {
        await _logFile!.writeAsString(
          text,
          mode: FileMode.append,
          flush: true,
        );
      } catch (e) {
        debugPrint('Error writing log file: $e');
      }
    });
  }
}
