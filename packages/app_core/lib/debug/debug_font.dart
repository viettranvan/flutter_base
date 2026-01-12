import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

class DebugFontPage extends StatelessWidget {
  const DebugFontPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Font Page')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Font Weights & Styles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ..._buildFontWeights(),
            const SizedBox(height: 40),
            const Text(
              'Typography Presets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ..._buildTypographyPresets(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFontWeights() {
    final weights = [
      ('Thin (W100)', FontWeight.w100),
      ('Extra Light (W200)', FontWeight.w200),
      ('Light (W300)', FontWeight.w300),
      ('Regular (W400)', FontWeight.w400),
      ('Medium (W500)', FontWeight.w500),
      ('Semi Bold (W600)', FontWeight.w600),
      ('Bold (W700)', FontWeight.w700),
      ('Extra Bold (W800)', FontWeight.w800),
      ('Black (W900)', FontWeight.w900),
    ];

    return weights
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$1,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'abcdefghijklmnopqrstuvwxyz',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: item.$2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: item.$2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildTypographyPresets() {
    final presets = [
      ('Headline 1', AppTypography.headline1),
      ('Headline 2', AppTypography.of(size: 28, weight: AppFontWeight.bold)),
      (
        'Headline 3',
        AppTypography.of(size: 24, weight: AppFontWeight.semiBold),
      ),
      (
        'Headline 4',
        AppTypography.of(size: 20, weight: AppFontWeight.semiBold),
      ),
      ('Body Large', AppTypography.of(size: 18, weight: AppFontWeight.regular)),
      (
        'Body Medium',
        AppTypography.of(size: 16, weight: AppFontWeight.regular),
      ),
      ('Body Small', AppTypography.of(size: 14, weight: AppFontWeight.regular)),
      (
        'Label Large',
        AppTypography.of(size: 14, weight: AppFontWeight.semiBold),
      ),
      (
        'Label Medium',
        AppTypography.of(size: 12, weight: AppFontWeight.medium),
      ),
      ('Label Small', AppTypography.of(size: 11, weight: AppFontWeight.medium)),
    ];

    return presets
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue.shade50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$1,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('abcdefghijklmnopqrstuvwxyz', style: item.$2),
                  const SizedBox(height: 6),
                  Text('ABCDEFGHIJKLMNOPQRSTUVWXYZ', style: item.$2),
                ],
              ),
            ),
          ),
        )
        .toList();
  }
}
