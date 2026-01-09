import 'package:design_assets/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
// ignore: depend_on_referenced_packages
import 'package:xml/xml.dart';

import 'index.dart';

class DebugIconPage extends StatelessWidget {
  const DebugIconPage({super.key});

  Future<String> _getSvgDimensions(String assetPath) async {
    try {
      final svgContent = await rootBundle.loadString(assetPath);
      final document = XmlDocument.parse(svgContent);
      final viewBox = document.rootElement.getAttribute('viewBox');

      if (viewBox == null) return 'N/A';

      final parts = viewBox.split(' ');
      if (parts.length == 4) {
        final width = parts[2];
        final height = parts[3];
        return '$width x $height';
      }
      return viewBox;
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Icon Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 10,
          children: [
            const Text(
              'At the root of project, run following command to generate icon paths:',
            ),
            CodeBlock(
              code: 'dart run packages/design_assets/tools/generate_paths.dart',
            ),
            const Text('ICON LIST:'),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: IconAssets.all.length,
                itemBuilder: (context, index) {
                  final assetPath = IconAssets.all[index];
                  final iconName = assetPath.split('/').last.split('.').first;

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          iconName,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        FutureBuilder<String>(
                          future: _getSvgDimensions(assetPath),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'Loading...',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                        Expanded(child: SvgPicture.asset(assetPath)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
