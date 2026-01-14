import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class FileLogOutput extends LogOutput {
  File? _logFile;
  bool _isInitialized = false;
  Future _writeQueue = Future.value();

  /// Whether to enable file logging (controlled by environment)
  bool _enableFileLogging = true;

  /// Whether to sanitize logs before writing
  bool _sanitizeLogs = true;

  /// Maximum file size in bytes (50MB)
  static const int maxFileSizeBytes = 50 * 1024 * 1024;

  /// Constructor with logging control
  FileLogOutput({
    bool enableFileLogging = true,
    bool sanitizeLogs = true,
  })  : _enableFileLogging = enableFileLogging,
        _sanitizeLogs = sanitizeLogs;

  /// Enable or disable file logging dynamically
  void setFileLoggingEnabled(bool enabled) {
    _enableFileLogging = enabled;
  }

  /// Set whether to sanitize logs
  void setSanitizationEnabled(bool enabled) {
    _sanitizeLogs = enabled;
  }

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    if (!_enableFileLogging) {
      _isInitialized = true;
      return;
    }

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

      // Check and cleanup storage if needed
      await _checkAndCleanupStorage();
    } catch (e) {
      debugPrint('FileLogOutput init error: $e');
    }
  }

  String? get logFilePath =>
      _isInitialized && _logFile != null ? _logFile!.path : null;

  /// Get all log files sorted by modification time (oldest first)
  Future<List<File>> _getLogFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${dir.path}/logs');
      if (!await logDir.exists()) return [];

      final files = <File>[];
      for (final entity in logDir.listSync()) {
        if (entity is File && entity.path.endsWith('.log')) {
          files.add(entity);
        }
      }

      // Sort by modified time (oldest first)
      files.sort(
        (a, b) => a.statSync().modified.compareTo(b.statSync().modified),
      );

      return files;
    } catch (e) {
      debugPrint('Error getting log files: $e');
      return [];
    }
  }

  /// Check total storage size and cleanup old logs if exceeds limit
  Future<void> _checkAndCleanupStorage() async {
    if (!_isInitialized) return;

    try {
      final files = await _getLogFiles();
      if (files.isEmpty) return;

      // Calculate total size
      int totalSize = 0;
      for (final file in files) {
        totalSize += file.statSync().size;
      }

      // If exceeds max size, delete oldest files
      if (totalSize > maxFileSizeBytes) {
        for (final file in files) {
          if (totalSize <= maxFileSizeBytes) break;
          final stat = await file.stat();
          totalSize -= stat.size;
          await file.delete();
          debugPrint('Deleted log file: ${file.path} (size cleanup)');
        }
      }
    } catch (e) {
      debugPrint('Error checking storage: $e');
    }
  }

  /// Remove logs older than specified days
  Future<void> clearOldLogs({int olderThanDays = 7}) async {
    if (!_isInitialized) return;

    try {
      final files = await _getLogFiles();
      if (files.isEmpty) return;

      final now = DateTime.now();
      for (final file in files) {
        final stat = await file.stat();
        final ageInDays = now.difference(stat.modified).inDays;

        if (ageInDays > olderThanDays) {
          await file.delete();
          debugPrint(
            'Deleted log file: ${file.path} (age: $ageInDays days)',
          );
        }
      }
    } catch (e) {
      debugPrint('Error clearing old logs: $e');
    }
  }

  @override
  void output(OutputEvent event) {
    if (!_isInitialized || !_enableFileLogging || _logFile == null) return;

    var text = '${event.lines.join('\n')}\n';

    // Sanitize if enabled
    if (_sanitizeLogs) {
      // TODO: enable LogSanitizer if needed
      // text = LogSanitizer.sanitize(text);
    }

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
