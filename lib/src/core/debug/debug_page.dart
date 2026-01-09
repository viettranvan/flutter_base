import 'package:app_core/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/src/core/index.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 20,
          children: [
            const SizedBox(height: 10),
            AppButton(
              title: 'App Font',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DebugFontPage(),
                  ),
                );
              },
            ),
            AppButton(
              title: 'Icon List',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DebugIconPage(),
                  ),
                );
              },
            ),
            AppButton(title: 'App Log'),
          ],
        ),
      ),
    );
  }
}
