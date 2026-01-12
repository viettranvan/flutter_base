import 'dart:io';

import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class LogDetailPage extends StatefulWidget {
  final File logFile;

  const LogDetailPage({super.key, required this.logFile});

  @override
  State<LogDetailPage> createState() => _LogDetailPageState();
}

class _LogDetailPageState extends State<LogDetailPage> {
  late Future<List<LogEntry>> _logsFuture;

  final _searchController = TextEditingController();
  String _searchText = '';

  final Set<LogLevel> _enabledLevels = {
    LogLevel.debug,
    LogLevel.info,
    LogLevel.warning,
    LogLevel.error,
    LogLevel.fatal,
  };

  @override
  void initState() {
    super.initState();
    _logsFuture = _loadLogs();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<LogEntry>> _loadLogs() async {
    final lines = await widget.logFile.readAsLines();
    return lines.map(parseLogLine).whereType<LogEntry>().toList();
  }

  List<LogEntry> _filterLogs(List<LogEntry> logs) {
    return logs.where((log) {
      final levelOk = _enabledLevels.contains(log.level);
      final searchOk = _searchText.isEmpty ||
          log.message.toLowerCase().contains(_searchText);
      return levelOk && searchOk;
    }).toList();
  }

  Color _levelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.fatal:
        return Colors.purple;
    }
  }

  /// =======================
  /// UI
  /// =======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.logFile.path.split('/').last),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share log file',
            onPressed: _shareLogFile,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterBar(),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<LogEntry>>(
              future: _logsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading log',
                      style: TextStyle(color: Colors.red.shade300),
                    ),
                  );
                }

                final logs = _filterLogs(snapshot.data ?? []);

                if (logs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No logs found',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (_, i) => _buildLogRow(logs[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// =======================
  /// Widgets
  /// =======================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search logs...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: LogLevel.values.map((level) {
          final selected = _enabledLevels.contains(level);
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(level.name.toUpperCase()),
              selected: selected,
              selectedColor: _levelColor(level).withValues(alpha: 0.25),
              backgroundColor: Colors.grey.shade800,
              labelStyle: const TextStyle(color: Colors.white),
              onSelected: (v) {
                setState(() {
                  v ? _enabledLevels.add(level) : _enabledLevels.remove(level);
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogRow(LogEntry log) {
    return InkWell(
      onTap: () => _showLogDetail(log),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('HH:mm:ss').format(log.time),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white54,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: Text(
                log.level.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _levelColor(log.level),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                log.message,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =======================
  /// Share & Export
  /// =======================

  Future<void> _shareLogFile() async {
    try {
      final fileName = widget.logFile.path.split('/').last;

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(widget.logFile.path)],
          subject: 'App Log File: $fileName',
          text: 'Attached app log file for debugging',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing log: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// =======================
  /// Detail view
  /// =======================

  void _showLogDetail(LogEntry log) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: SelectableText(
            log.raw,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
