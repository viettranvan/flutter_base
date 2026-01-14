import 'dart:io';

import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';


class AppLogListPage extends StatefulWidget {
  const AppLogListPage({super.key});

  @override
  State<AppLogListPage> createState() => _AppLogListPageState();
}

class _AppLogListPageState extends State<AppLogListPage> {
  late Future<List<FileSystemEntity>> _logFiles;

  @override
  void initState() {
    super.initState();
    _logFiles = _getLogFiles();
  }

  Future<List<FileSystemEntity>> _getLogFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${dir.path}/logs');

      if (!await logDir.exists()) {
        return [];
      }

      final files = logDir.listSync();
      // Sort by modification time (newest first)
      files.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return bStat.modified.compareTo(aStat.modified);
      });

      return files
          .where((file) => file is File && file.path.endsWith('.log'))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _deleteLog(File file) async {
    try {
      await file.delete();
      setState(() {
        _logFiles = _getLogFiles();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting log: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share all logs',
            onPressed: _shareAllLogs,
          ),
        ],
      ),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: _logFiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final files = snapshot.data ?? [];

          if (files.isEmpty) {
            return const Center(
              child: Text('No log files found'),
            );
          }

          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index] as File;
              final fileName = file.path.split('/').last;
              final stat = file.statSync();
              final size = stat.size;
              final modified = stat.modified;

              return ListTile(
                title: Text(fileName),
                subtitle: Text(
                  '${modified.toString().substring(0, 19)} • ${_formatBytes(size)}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Log'),
                        content: Text('Delete $fileName?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteLog(file);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LogDetailPage(logFile: file),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  Future<void> _shareAllLogs() async {
    try {
      final files = await _getLogFiles();

      if (files.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No log files to share')),
          );
        }
        return;
      }

      final xFiles = files.whereType<File>().map((f) => XFile(f.path)).toList();

      if (xFiles.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No log files to share')),
          );
        }
        return;
      }

      await SharePlus.instance.share(
        ShareParams(
          files: xFiles,
          subject:
              'App Logs - ${DateTime.now().toIso8601String().split('T')[0]}',
          text: 'Attached app logs for debugging',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing logs: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
