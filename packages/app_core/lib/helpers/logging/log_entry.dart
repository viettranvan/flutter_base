import 'dart:convert';

import 'package:app_core/app_core.dart';

enum LogLevel { debug, info, warning, error, fatal }

final _timeReg = RegExp(r'\[(.*?)\]');
final _levelReg = RegExp(r'\[(DEBUG|INFO|WARNING|ERROR|FATAL)\]');

class LogEntry {
  final DateTime time;
  final LogLevel level;

  /// Text hiển thị (ASCII)
  final String message;

  /// Raw lines (để detail view)
  final List<String> rawLines;

  /// Network metadata (nullable)
  final NetworkLogEvent? network;

  LogEntry({
    required this.time,
    required this.level,
    required this.message,
    required this.rawLines,
    this.network,
  });

  bool get isNetworkLog => network != null;
}

List<LogEntry> parseLogLines(List<String> lines) {
  final List<LogEntry> entries = [];

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];

    if (line.startsWith('##NET')) {
      // safety: NET line không bao giờ đứng đầu
      continue;
    }

    final timeMatch = _timeReg.firstMatch(line);
    final levelMatch = _levelReg.firstMatch(line);

    if (timeMatch == null || levelMatch == null) {
      continue;
    }

    final time = DateTime.tryParse(timeMatch.group(1)!);
    if (time == null) continue;

    final level = LogLevel.values.firstWhere(
      (e) => e.name.toUpperCase() == levelMatch.group(1),
    );

    final message =
        line.replaceAll(_timeReg, '').replaceAll(_levelReg, '').trim();

    NetworkLogEvent? network;
    final rawLines = <String>[line];

    // check next line = metadata
    if (i + 1 < lines.length && lines[i + 1].startsWith('##NET')) {
      final jsonText = lines[i + 1].substring(5).trim();
      try {
        final json = jsonDecode(jsonText) as Map<String, dynamic>;
        network = NetworkLogEvent.fromJson(json);
        rawLines.add(lines[i + 1]);
        i++; // skip NET line
      } catch (_) {
        // ignore malformed NET
      }
    }

    entries.add(
      LogEntry(
        time: time,
        level: level,
        message: message,
        rawLines: rawLines,
        network: network,
      ),
    );
  }

  return entries;
}

