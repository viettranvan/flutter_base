import 'package:app_core/app_core.dart';

abstract class LogRenderItem {}

class SingleLogItem extends LogRenderItem {
  final LogEntry entry;
  SingleLogItem(this.entry);
}

class NetworkLogGroupItem extends LogRenderItem {
  final String requestId;
  final List<LogEntry> entries;
  bool expanded;

  NetworkLogGroupItem({
    required this.requestId,
    required this.entries,
    this.expanded = false,
  });

  LogEntry get summary =>
      entries.firstWhere((e) => e.network?.type.name == 'group');

  List<LogEntry> get details =>
      entries.where((e) => e.network?.type.name != 'group').toList();
}

List<LogRenderItem> buildRenderItems(List<LogEntry> logs) {
  final Map<String, List<LogEntry>> networkGroups = {};
  final List<LogRenderItem> result = [];

  for (final log in logs) {
    if (!log.isNetworkLog) {
      result.add(SingleLogItem(log));
      continue;
    }

    final requestId = log.network!.requestId;
    networkGroups.putIfAbsent(requestId, () => []).add(log);
  }

  // giữ nguyên thứ tự xuất hiện
  final handled = <String>{};

  for (final log in logs) {
    if (!log.isNetworkLog) continue;

    final requestId = log.network!.requestId;
    if (handled.contains(requestId)) continue;

    handled.add(requestId);

    result.add(
      NetworkLogGroupItem(
        requestId: requestId,
        entries: networkGroups[requestId]!,
      ),
    );
  }

  return result;
}
