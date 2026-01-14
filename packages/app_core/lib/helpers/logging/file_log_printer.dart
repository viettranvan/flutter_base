// import 'dart:convert';

// import 'package:app_core/app_core.dart';
// import 'package:logger/logger.dart';

// class FileLogPrinter extends LogPrinter {
//   static const _structuredMarker = '##NET ';

//   @override
//   List<String> log(LogEvent event) {
//     final time = DateTime.now().toIso8601String();
//     final level = event.level.name.toUpperCase();

//     final lines = <String>[];

//     // -------- Main text line --------
//     final buffer = StringBuffer()
//       ..write('[$time]')
//       ..write(' [$level]')
//       ..write(' ${_resolveText(event.message)}');

//     if (event.error != null) {
//       buffer.write(' | error=${event.error}');
//     }

//     if (event.stackTrace != null) {
//       buffer.write('\n${event.stackTrace}');
//     }

//     lines.add(buffer.toString());

//     // -------- Structured metadata line --------
//     if (event.message is StructuredLogMessage) {
//       final structured = event.message as StructuredLogMessage;
//       final data = structured.toStructuredData();

//       if (data.isNotEmpty) {
//         lines.add('$_structuredMarker${jsonEncode(data)}');
//       }
//     }

//     return lines;
//   }

//   String _resolveText(dynamic message) {
//     if (message is StructuredLogMessage) {
//       return message.text;
//     }
//     return message.toString();
//   }
// }

import 'dart:convert';

import 'package:app_core/app_core.dart';
import 'package:logger/logger.dart';

class FileLogPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final time = DateTime.now().toIso8601String();

    final message = event.message;

    // Network log → NDJSON
    if (message is NetworkLogGroup) {
      final jsonLine = jsonEncode({
        'timestamp': time,
        'level': event.level.name,
        ...message.toJson(),
      });

      return [jsonLine];
    }

    // Normal app log → still NDJSON
    final jsonLine = jsonEncode({
      'timestamp': time,
      'level': event.level.name,
      'type': 'app',
      'message': message.toString(),
    });

    return [jsonLine];
  }
}
