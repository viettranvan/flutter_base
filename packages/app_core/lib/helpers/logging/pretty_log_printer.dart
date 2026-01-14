import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

class PrettyLogPrinter {
  static const int kInitialTab = 1;
  static const String tabStep = '    ';
  static const int chunkSize = 20;

  final void Function(String) _log;
  final int maxWidth;
  final bool compact;

  const PrettyLogPrinter({
    required void Function(String) log,
    this.maxWidth = 90,
    this.compact = true,
  }) : _log = log;

  // ========= PUBLIC =========

  void print(dynamic data) {
    if (data == null) return;

    if (data is Map) {
      _printPrettyMap(data);
    } else if (data is List) {
      _printList(data);
    } else if (data is Uint8List) {
      _printBytes(data);
    } else {
      _printBlock(data.toString());
    }
  }

  void printApiHeader({
    required String icon,
    required String title,
    required String requestId,
    required int duration,
  }) {
    _log('╔╣ $icon $title');
    _log('║     Request ID: $requestId | Duration: ${duration}ms');
    _log(
        '╚══════════════════════════════════════════════════════════════════════════════');
  }

  void printBoxed({String? header, String? text}) {
    _log('');
    _log('╔╣ $header');
    _log('║  $text');
    _printLine('╚');
  }

  void printRequestHeader({required String method, required String uri}) {
    printBoxed(header: 'Request ║ $method ', text: uri);
  }

  void printResponseHeader({
    required String method,
    required String uri,
    required int? statusCode,
    required String? statusMessage,
  }) {
    printBoxed(
      header: 'Response ║ $method ║ Status: $statusCode $statusMessage',
      text: uri,
    );
  }

  void printCurlCommand({
    required String method,
    required Uri uri,
    required Map<String, dynamic> headers,
    required dynamic data,
  }) {
    final parts = <String>[];
    parts.add('curl -X $method');
    parts.add('"$uri"');

    headers.forEach((key, value) {
      if (key.toLowerCase() != 'host' &&
          key.toLowerCase() != 'content-length' &&
          key.toLowerCase() != 'accept-encoding') {
        parts.add('-H "$key: $value"');
      }
    });

    if (method != 'GET' && data != null) {
      String bodyStr = '';
      if (data is Map) {
        bodyStr = _jsonEncode(data);
      } else {
        bodyStr = data.toString();
      }
      bodyStr = bodyStr.replaceAll('"', '\\"');
      parts.add('-d "$bodyStr"');
    }

    final curlCommand = parts.join(' \\\n');

    _log('');
    _log('╔╣ cURL Command');
    _log('║');

    final curlLines = curlCommand.split('\n');
    for (final line in curlLines) {
      _log('║  $line');
    }

    _log('║');
    _printLine('╚');
  }

  void printDioError({
    required String type,
    required String? message,
    required int? statusCode,
    required String? statusMessage,
    required Uri? uri,
    required dynamic responseData,
  }) {
    if (statusCode != null) {
      printBoxed(
        header: 'DioError ║ Status: $statusCode $statusMessage',
        text: uri.toString(),
      );
      if (responseData != null) {
        _log('╔ $type');
        print(responseData);
      }
      _printLine('╚');
    } else {
      printBoxed(header: 'DioError ║ $type', text: message ?? 'Unknown error');
    }

    _log('');
  }

  void printResponseBody({
    required dynamic data,
    required bool includeHeader,
  }) {
    if (includeHeader) {
      _log('╔ Body');
      _log('║');
    }

    print(data);

    if (includeHeader) {
      _log('║');
      _printLine('╚');
    }
  }

  void printResponseHeaders(Map<String, dynamic> headers) {
    if (headers.isEmpty) return;
    _log('╔ Headers ');
    headers.forEach((key, value) {
      _printKV(key, value);
    });
    _printLine('╚');
  }

  // ========= CORE =========

  void _printPrettyMap(
    Map data, {
    int tabs = kInitialTab,
    bool isListItem = false,
    bool isLast = false,
  }) {
    final indent = _indent(tabs);

    if (tabs == kInitialTab || isListItem) {
      _log('║$indent{');
    }

    data.entries.toList().asMap().forEach((i, entry) {
      final key = entry.key;
      final value = entry.value;
      final last = i == data.length - 1;

      if (value is Map) {
        if (compact && _canFlattenMap(value)) {
          _log('║${_indent(tabs + 1)} $key: $value${last ? '' : ','}');
        } else {
          _log('║${_indent(tabs + 1)} $key: {');
          _printPrettyMap(value, tabs: tabs + 1);
        }
      } else if (value is List) {
        _log('║${_indent(tabs + 1)} $key: [');
        _printList(value, tabs: tabs + 1);
        _log('║${_indent(tabs + 1)} ]${last ? '' : ','}');
      } else {
        final msg = value.toString().replaceAll('\n', ' ');
        final prefix = '║${_indent(tabs + 1)} $key: ';

        if (prefix.length + msg.length <= maxWidth) {
          _log('$prefix$msg${last ? '' : ','}');
        } else {
          _log(prefix);
          _printBlock(msg, tabs: tabs + 1);
        }
      }
    });

    _log('║$indent}${isListItem && !isLast ? ',' : ''}');
  }

  void _printList(List list, {int tabs = kInitialTab}) {
    for (var i = 0; i < list.length; i++) {
      final e = list[i];
      final isLast = i == list.length - 1;

      if (e is Map) {
        _printPrettyMap(e, tabs: tabs + 1, isListItem: true, isLast: isLast);
      } else {
        _log('║${_indent(tabs + 2)} $e${isLast ? '' : ','}');
      }
    }
  }

  void _printBytes(Uint8List list, {int tabs = kInitialTab}) {
    for (var i = 0; i < list.length; i += chunkSize) {
      final chunk = list.sublist(
        i,
        math.min(i + chunkSize, list.length),
      );
      _log('║${_indent(tabs)} ${chunk.join(", ")}');
    }
  }

  // ========= UTIL =========

  void _printKV(String? key, Object? v) {
    final pre = '╟ $key: ';
    final msg = v.toString();

    if (pre.length + msg.length > maxWidth) {
      _log(pre);
      _printBlock(msg);
    } else {
      _log('$pre$msg');
    }
  }

  void _printLine([String pre = '', String suf = '╝']) =>
      _log('$pre${'═' * maxWidth}$suf');

  void _printBlock(String msg, {int tabs = kInitialTab}) {
    final width = maxWidth - _indent(tabs).length;
    final lines = (msg.length / width).ceil();

    for (var i = 0; i < lines; i++) {
      final start = i * width;
      final end = math.min(start + width, msg.length);
      _log('║${_indent(tabs)} ${msg.substring(start, end)}');
    }
  }

  bool _canFlattenMap(Map map) =>
      map.values.where((v) => v is Map || v is List).isEmpty &&
      map.toString().length < maxWidth;

  String _indent(int tabs) => tabStep * tabs;

  String _jsonEncode(Map map) {
    try {
      return jsonEncode(map);
    } catch (e) {
      return map.toString();
    }
  }
}
