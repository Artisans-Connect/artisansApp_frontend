import 'dart:io';

void main() {
  final f1 = File('lib/features/worker/presentation/screens/job_request_detail_screen.dart');
  var lines = f1.readAsLinesSync();
  lines.removeWhere((l) => l.contains("import '../theme/worker_colors.dart';"));
  lines.removeWhere((l) => l.contains("import '../theme/worker_spacing.dart';"));
  lines.removeWhere((l) => l.contains("import '../theme/worker_text_styles.dart';"));
  lines.insert(4, "import 'package:artisans_app/core/theme/index.dart';");
  f1.writeAsStringSync(lines.join('\n'));

  final f2 = File('lib/features/worker/presentation/widgets/completion_photo_picker.dart');
  lines = f2.readAsLinesSync();
  lines.removeWhere((l) => l.contains("import '../theme/worker_colors.dart';"));
  lines.removeWhere((l) => l.contains("import '../theme/worker_spacing.dart';"));
  lines.removeWhere((l) => l.contains("import '../theme/worker_text_styles.dart';"));
  lines.insert(2, "import 'package:artisans_app/core/theme/index.dart';");
  f2.writeAsStringSync(lines.join('\n'));

  print('Patched successfully without truncating!');
}
