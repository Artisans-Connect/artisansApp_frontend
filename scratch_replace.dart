// Note: we are running this as a simple dart script.
import 'dart:io';

void main() {
  final dir = Directory('lib/features/worker');
  if (!dir.existsSync()) {
    print('Directory not found');
    return;
  }

  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();
  
  for (final file in files) {
    String content = file.readAsStringSync();
    bool changed = false;

    // Replace class references
    if (content.contains('WorkerColors')) {
      content = content.replaceAll('WorkerColors', 'AppColors');
      changed = true;
    }
    if (content.contains('WorkerTextStyles')) {
      content = content.replaceAll('WorkerTextStyles', 'AppTypography');
      changed = true;
    }
    if (content.contains('WorkerSpacing')) {
      content = content.replaceAll('WorkerSpacing', 'AppSpacing');
      changed = true;
    }

    // Replace imports
    // Various relative paths to the theme folder might be used, so we use a regex.
    // e.g., import '../theme/worker_colors.dart';
    final importRegex = RegExp(r"import\s+['""](?:[./\w]+)worker_(?:colors|text_styles|spacing)\.dart['""];");
    if (importRegex.hasMatch(content)) {
      content = content.replaceAll(importRegex, "import 'package:artisans_app/core/theme/index.dart';");
      // Remove duplicate index.dart imports if they occur
      content = content.replaceAll(RegExp(r"(import 'package:artisans_app/core/theme/index\.dart';[\r\n]*){2,}"), "import 'package:artisans_app/core/theme/index.dart';\n");
      changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
