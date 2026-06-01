import 'dart:io';

void main() {
  // 1. job_request_detail_screen.dart
  final f1 = File('lib/features/worker/presentation/screens/job_request_detail_screen.dart');
  var content1 = f1.readAsStringSync();
  content1 = content1.replaceFirst(
    "import '../theme/worker_colors.dart';\nimport '../theme/worker_spacing.dart';\nimport '../theme/worker_text_styles.dart';",
    "import 'package:artisans_app/core/theme/index.dart';"
  );
  f1.writeAsStringSync(content1);

  // 2. completion_photo_picker.dart
  final f2 = File('lib/features/worker/presentation/widgets/completion_photo_picker.dart');
  var content2 = f2.readAsStringSync();
  content2 = content2.replaceFirst(
    "import '../theme/worker_colors.dart';\nimport '../theme/worker_spacing.dart';\nimport '../theme/worker_text_styles.dart';",
    "import 'package:artisans_app/core/theme/index.dart';"
  );
  f2.writeAsStringSync(content2);

  // 3. job_receipt_screen.dart
  final f3 = File('lib/shared/presentation/screens/job_receipt_screen.dart');
  var content3 = f3.readAsStringSync();
  content3 = content3.replaceFirst(
    "rows: const <_ReceiptRow>[",
    "rows: <_ReceiptRow>["
  );
  f3.writeAsStringSync(content3);

  // 4. onboarding_screen.dart
  final f4 = File('lib/features/auth/presentation/screens/onboarding_screen.dart');
  var content4 = f4.readAsStringSync();
  content4 = content4.replaceFirst(
    "children: const <Widget>[",
    "children: <Widget>["
  );
  f4.writeAsStringSync(content4);

  print('Patched successfully!');
}
