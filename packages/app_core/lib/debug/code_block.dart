import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// =======================
/// Token definitions
/// =======================

enum CodeTokenType { command, subCommand, path }

class CodeToken {
  final String text;
  final CodeTokenType type;

  const CodeToken(this.text, this.type);
}

/// =======================
/// Parsing logic
/// =======================
///
/// Example input:
/// dart run packages/app_core/tools/generate_paths.dart
///
List<CodeToken> parseCommand(String command) {
  final parts = command.trim().split(RegExp(r'\s+'));

  if (parts.length < 2) {
    return [CodeToken(command, CodeTokenType.command)];
  }

  return [
    CodeToken(parts[0], CodeTokenType.command),
    CodeToken(parts[1], CodeTokenType.subCommand),
    if (parts.length > 2)
      CodeToken(parts.sublist(2).join(' '), CodeTokenType.path),
  ];
}

/// =======================
/// Style resolver
/// =======================

TextStyle styleForToken(CodeTokenType type) {
  switch (type) {
    case CodeTokenType.command:
      return const TextStyle(
        color: Colors.greenAccent,
        fontWeight: FontWeight.w500,
      );
    case CodeTokenType.subCommand:
      return const TextStyle(color: Colors.white);
    case CodeTokenType.path:
      return const TextStyle(
        color: Colors.white,
        decoration: TextDecoration.underline,
        decorationColor: Colors.white,
        decorationThickness: 1.2,
      );
  }
}

/// =======================
/// CodeBlock widget
/// =======================

class CodeBlock extends StatelessWidget {
  final String code;

  const CodeBlock({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final tokens = parseCommand(code);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'monospace',
                  height: 1.4,
                ),
                children: [
                  for (int i = 0; i < tokens.length; i++)
                    TextSpan(
                      text: i == tokens.length - 1
                          ? tokens[i].text
                          : '${tokens[i].text} ',
                      style: styleForToken(tokens[i].type),
                    ),
                ],
              ),
            ),
          ),

          /// Copy button
          Positioned(
            top: -6,
            right: -6,
            child: IconButton(
              tooltip: 'Copy',
              icon: const Icon(Icons.copy, size: 18, color: Colors.white70),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: code));

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
