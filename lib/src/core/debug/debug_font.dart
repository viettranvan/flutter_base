import 'package:flutter/material.dart';

class DebugFontPage extends StatelessWidget {
  const DebugFontPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Font Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text('This is the Debug Font Page'),
          ],
        ),
      ),
    );
  }
}
