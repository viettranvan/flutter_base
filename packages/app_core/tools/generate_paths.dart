// ignore_for_file: avoid_print

import 'dart:io';

/// Navigate to root path of the project and run this script to generate paths for assets.
/// ``` bash
/// dart run packages/app_core/tools/generate_paths.dart
///
/// ```
void main() {
  final projectRoot = Directory.current.path;
  final iconsPath = '$projectRoot/packages/app_core/assets/icons/';
  final imagePath = '$projectRoot/packages/app_core/assets/images/';

  final iconDir = Directory(iconsPath);
  final imageDir = Directory(imagePath);

  if (!iconDir.existsSync() || !imageDir.existsSync()) {
    print('❌ Folder not found $iconsPath or $imagePath');
    return;
  }

  final buffer = StringBuffer('/*\n'
      'This file is AUTO-GENERATED. DO NOT MODIFY BY HAND.\n'
      'To regenerate this file, Navigate to root path of the project and run this script to generate paths for assets:\n'
      '``` bash\n'
      'dart run packages/app_core/tools/generate_paths.dart\n'
      '```\n'
      '*/\n\n'
      'const _basePath = \'packages/app_core/assets\';\n\n');

  // Collect icon and image names first
  final iconNames = <String>[];
  final imageNames = <String>[];

  for (var file in iconDir.listSync()) {
    if (file is File) {
      final fileName = file.uri.pathSegments.last;
      if (fileName == '.DS_Store') continue;
      final name = _toCamelCase(fileName.split('.').first);
      iconNames.add(name);
    }
  }

  for (var file in imageDir.listSync()) {
    if (file is File) {
      final fileName = file.uri.pathSegments.last;
      if (fileName == '.DS_Store') continue;
      final name = _toCamelCase(fileName.split('.').first);
      imageNames.add(name);
    }
  }

  // Generate main AssetsPath class first
  buffer.writeln('class AssetsPath {');
  buffer.writeln('  static const IconAssets icons = IconAssets._();');
  buffer.writeln('  static const ImageAssets images = ImageAssets._();');
  buffer.writeln('}\n');

  // Generate IconAssets class
  buffer.writeln('class IconAssets {');
  buffer.writeln('  const IconAssets._();\n');

  for (var file in iconDir.listSync()) {
    if (file is File) {
      final fileName = file.uri.pathSegments.last;
      if (fileName == '.DS_Store') continue;
      final name = _toCamelCase(fileName.split('.').first);
      buffer.writeln(
        "  static const String $name = '\$_basePath/icons/$fileName';",
      );
    }
  }

  // Add all icons list for debug
  buffer.writeln('\n  static const List<String> all = [');
  for (var name in iconNames) {
    buffer.writeln('    $name,');
  }
  buffer.writeln('  ];');
  buffer.writeln('}\n');

  // Generate ImageAssets class
  buffer.writeln('class ImageAssets {');
  buffer.writeln('  const ImageAssets._();\n');

  for (var file in imageDir.listSync()) {
    if (file is File) {
      final fileName = file.uri.pathSegments.last;
      if (fileName == '.DS_Store') continue;
      final name = _toCamelCase(fileName.split('.').first);
      buffer.writeln(
        "  static const String $name = '\$_basePath/images/$fileName';",
      );
    }
  }
  buffer.writeln('}');

  final outputPath =
      '$projectRoot/packages/app_core/lib/utils/assets_path.dart';
  File(outputPath).writeAsStringSync(buffer.toString());

  print('✅ Generated: $outputPath');
}

String _toCamelCase(String input) {
  final parts = input
      .toLowerCase()
      .replaceAll(RegExp(r'[-_\s]+'), ' ') // replace `-`, `_` with space
      .split(' ');

  if (parts.isEmpty) return '';

  // The first letter remains the same, the following words have the first letter capitalized
  return parts.first +
      parts
          .skip(1)
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join();
}
