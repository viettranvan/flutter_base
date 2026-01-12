enum LogLevel { debug, info, warning, error, fatal }

class LogEntry {
  final DateTime time;
  final LogLevel level;
  final String message;
  final String raw;

  LogEntry({
    required this.time,
    required this.level,
    required this.message,
    required this.raw,
  });
}

LogEntry? parseLogLine(String line) {
  final timeMatch = RegExp(r'\[(.*?)\]').firstMatch(line);
  final levelMatch =
      RegExp(r'\[(DEBUG|INFO|WARNING|ERROR|FATAL)\]').firstMatch(line);

  if (timeMatch == null || levelMatch == null) return null;

  final time = DateTime.tryParse(timeMatch.group(1)!);
  if (time == null) return null;

  final level = LogLevel.values.firstWhere(
    (e) => e.name.toUpperCase() == levelMatch.group(1),
  );

  final message = line.replaceAll(RegExp(r'\[.*?\]'), '').trim();

  return LogEntry(
    time: time,
    level: level,
    message: message,
    raw: line,
  );
}
