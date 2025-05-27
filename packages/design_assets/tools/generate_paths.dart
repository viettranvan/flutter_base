// ignore_for_file: avoid_print

import 'dart:io';

/// Navigate to root path of the project and run this script to generate paths for assets.
/// ``` bash
/// dart run packages/design_assets/tools/generate_paths.dart
///
/// ```
void main() {
  final projectRoot = Directory.current.path;
  final iconsPath = '$projectRoot/packages/design_assets/assets/icons/';
  final imagePath = '$projectRoot/packages/design_assets/assets/images/';

  final iconDir = Directory(iconsPath);
  final imageDir = Directory(imagePath);
  final buffer = StringBuffer(
      'const _basePath = \'packages/design_assets/assets\';\n\nclass AssetsPath {\n  // === ICONS PATH ===\n');

  if (!iconDir.existsSync() || !imageDir.existsSync()) {
    print('❌ Folder not found $iconsPath or $imagePath');
    return;
  }

  for (var file in iconDir.listSync()) {
    if (file is File) {
      final fileName = file.uri.pathSegments.last;
      if (fileName == '.DS_Store') continue; // Skip .DS_Store file
      final name = fileName.split('.').first;
      buffer.writeln(
        "  static const String ${_toCamelCase(name)} = '\$_basePath/icons/$fileName';",
      );
    }
  }
  buffer.writeln("\n  // === IMAGES PATH === ");

  for (var file in imageDir.listSync()) {
    if (file is File) {
      final fileName = file.uri.pathSegments.last;
      if (fileName == '.DS_Store') continue; // Skip .DS_Store file
      final name = fileName.split('.').first;
      buffer.writeln(
        "  static const String ${_toCamelCase(name)} = '\$_basePath/images/$fileName';",
      );
    }
  }

  buffer.writeln('}');

  final outputPath =
      '$projectRoot/packages/design_assets/lib/utils/assets_path.dart';
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
