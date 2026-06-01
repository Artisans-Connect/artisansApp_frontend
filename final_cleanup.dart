import 'dart:io';

void main() {
  final dir = Directory('lib/features/worker');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    var lines = file.readAsLinesSync();
    bool changed = false;

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains("import '") && lines[i].contains("theme/worker_")) {
        lines[i] = "";
        changed = true;
      }
      if (lines[i].contains("AppTypography.badge")) {
        lines[i] = lines[i].replaceAll("AppTypography.badge", "AppTypography.labelSmall");
        changed = true;
      }
      if (lines[i].contains("AppColors.cardRadius")) {
        lines[i] = lines[i].replaceAll("AppColors.cardRadius", "16.0");
        changed = true;
      }
    }

    if (changed) {
      // Add core theme import near the top if not present
      if (!lines.any((l) => l.contains("import 'package:artisans_app/core/theme/index.dart';"))) {
        int insertIdx = lines.indexWhere((l) => l.startsWith("import '"));
        if (insertIdx == -1) insertIdx = 0;
        lines.insert(insertIdx, "import 'package:artisans_app/core/theme/index.dart';");
      }
      // Remove empty lines created by import removal
      lines.removeWhere((l) => l.trim().isEmpty && lines.indexOf(l) < 20); // rough cleanup top
      
      file.writeAsStringSync(lines.join('\n'));
      print('Fixed ${file.path}');
    }
  }

  print('Final worker theme cleanup completed.');
}
