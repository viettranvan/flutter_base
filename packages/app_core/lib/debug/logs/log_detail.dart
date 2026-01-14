import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:app_core/app_core.dart';
import 'package:app_core/debug/logs/json_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class NDJsonLogEntry {
  final DateTime timestamp;
  final String level;
  final String type; // 'app' or 'network'
  final String message;
  final Map<String, dynamic>? networkData;

  NDJsonLogEntry({
    required this.timestamp,
    required this.level,
    required this.type,
    required this.message,
    this.networkData,
  });

  factory NDJsonLogEntry.fromJson(Map<String, dynamic> json) {
    final timestamp = DateTime.parse(json['timestamp'] as String);
    final level = json['level'] as String;
    final type = json['type'] as String? ?? 'app';

    // Network log
    if (type == 'network') {
      return NDJsonLogEntry(
        timestamp: timestamp,
        level: level,
        type: type,
        message: _buildNetworkMessage(json),
        networkData: json,
      );
    }

    // App log
    return NDJsonLogEntry(
      timestamp: timestamp,
      level: level,
      type: type,
      message: json['message'] as String? ?? '',
    );
  }

  static String _buildNetworkMessage(Map<String, dynamic> json) {
    final method = json['method'] as String? ?? '';
    final path = json['path'] as String? ?? '';
    return '$method $path';
  }

  int? getStatusCode() {
    if (networkData != null) {
      try {
        final status = networkData!['status'];
        if (status is Map<String, dynamic>) {
          final code = status['code'];
          return code is int ? code : int.tryParse(code.toString());
        }
      } catch (e) {
        dev.log('Error getting status code: $e');
      }
    }
    return null;
  }
}

class LogDetailPage extends StatefulWidget {
  final File logFile;

  const LogDetailPage({super.key, required this.logFile});

  @override
  State<LogDetailPage> createState() => _LogDetailPageState();
}

class _LogDetailPageState extends State<LogDetailPage> {
  final _searchController = TextEditingController();
  String _searchText = '';

  final Set<String> _enabledLevels = {
    'debug',
    'info',
    'warning',
    'error',
    'fatal',
  };

  @override
  void initState() {
    super.initState();
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

  Future<List<NDJsonLogEntry>> _loadLogs() async {
    final lines = await widget.logFile.readAsLines();
    final entries = <NDJsonLogEntry>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      try {
        final json = jsonDecode(line) as Map<String, dynamic>;
        entries.add(NDJsonLogEntry.fromJson(json));
      } catch (e) {
        // Skip invalid JSON lines
        continue;
      }
    }

    return entries;
  }

  List<NDJsonLogEntry> _filterLogs(List<NDJsonLogEntry> logs) {
    final filtered = logs.where((log) {
      final levelOk = _enabledLevels.contains(log.level.toLowerCase());
      final searchOk = _searchText.isEmpty ||
          log.message.toLowerCase().contains(_searchText);
      return levelOk && searchOk;
    }).toList();
    return filtered.reversed.toList();
  }

  Color _levelColor(String level) {
    switch (level.toLowerCase()) {
      case 'debug':
        return Colors.grey;
      case 'info':
        return Colors.blue;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'fatal':
        return Colors.purple;
      default:
        return Colors.white;
    }
  }

  Color _getStatusCodeColor(int? statusCode) {
    if (statusCode == null) return Colors.grey;
    if (statusCode >= 200 && statusCode < 300) return Colors.green;
    if (statusCode >= 300 && statusCode < 400) return Colors.blue;
    if (statusCode >= 400 && statusCode < 500) return Colors.orange;
    return Colors.red;
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
            child: FutureBuilder<List<NDJsonLogEntry>>(
              future: _loadLogs(),
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
                  physics: const BouncingScrollPhysics(),
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
    final levels = ['debug', 'info', 'warning', 'error', 'fatal'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: levels.map((level) {
          final selected = _enabledLevels.contains(level);
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(level.toUpperCase()),
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

  Widget _buildLogRow(NDJsonLogEntry log) {
    final isNetworkLog = log.type == 'network';
    final bgColor = isNetworkLog ? Colors.grey.shade900 : Colors.transparent;
    final statusCode = isNetworkLog ? log.getStatusCode() : null;

    return InkWell(
      onTap: () => _showLogDetail(log),
      child: Container(
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('HH:mm:ss').format(log.timestamp),
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
                log.level.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _levelColor(log.level),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (isNetworkLog)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'NET',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                  ),
                ),
              ),
            if (isNetworkLog) const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
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
                  if (isNetworkLog && statusCode != null)
                    const SizedBox(width: 6),
                  if (isNetworkLog && statusCode != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusCodeColor(statusCode)
                            .withValues(alpha: 0.2),
                        border: Border.all(
                          color: _getStatusCodeColor(statusCode),
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '$statusCode',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusCodeColor(statusCode),
                        ),
                      ),
                    ),
                ],
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

  void _showLogDetail(NDJsonLogEntry log) {
    final isNetworkLog = log.type == 'network';
    final statusCode = isNetworkLog ? log.getStatusCode() : null;

    showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1E1E1E),
        isScrollControlled: true,
        builder: (_) => SizedBox(
              height: context.screenHeight - context.statusBarHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade800,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (isNetworkLog)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue
                                              .withValues(alpha: 0.3),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        child: const Text(
                                          'NETWORK',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.lightBlue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (isNetworkLog && statusCode != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusCodeColor(statusCode)
                                            .withValues(alpha: 0.2),
                                        border: Border.all(
                                          color:
                                              _getStatusCodeColor(statusCode),
                                          width: 0.5,
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        '$statusCode',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              _getStatusCodeColor(statusCode),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                log.message,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () {
                            if (isNetworkLog && log.networkData != null) {
                              final jsonString = jsonEncode(log.networkData);
                              Clipboard.setData(
                                  ClipboardData(text: jsonString));
                              Fluttertoast.showToast(
                                msg: 'JSON copied to clipboard',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            }
                          },
                          color: Colors.white54,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                          color: Colors.white54,
                        ),
                      ],
                    ),
                  ),
                  // Content with JsonViewer
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      child: isNetworkLog && log.networkData != null
                          ? Theme(
                              data: Theme.of(context).copyWith(
                                textTheme:
                                    const TextTheme(bodySmall: TextStyle()),
                              ),
                              child: JsonViewer(log.networkData),
                            )
                          : Text(
                              log.message,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ));
  }
}
