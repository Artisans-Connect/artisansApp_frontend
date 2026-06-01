import 'dart:io';

void replaceInFile(String path, Map<String, String> replacements) {
  final file = File(path);
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  for (final entry in replacements.entries) {
    content = content.replaceAll(entry.key, entry.value);
  }
  file.writeAsStringSync(content);
}

void main() {
  replaceInFile('lib/shared/presentation/screens/chat_detail_screen.dart', {
    'const Icon(PhosphorIcons.': 'Icon(PhosphorIcons.',
  });
  replaceInFile('lib/shared/presentation/screens/user_profile_screen.dart', {
    'const Icon(PhosphorIcons.': 'Icon(PhosphorIcons.',
  });
  replaceInFile('lib/features/worker/presentation/screens/worker_active_empty_screen.dart', {
    'AppColors.successDark': 'AppColors.success',
    'const Icon(PhosphorIcons.': 'Icon(PhosphorIcons.',
  });
  replaceInFile('lib/features/worker/presentation/screens/worker_earnings_screen.dart', {
    'AppColors.successDark': 'AppColors.success',
  });
  replaceInFile('lib/features/worker/presentation/widgets/gradient_button.dart', {
    'AppColors.inputRadius': '12.0',
  });
  replaceInFile('lib/features/worker/presentation/widgets/elapsed_timer_card.dart', {
    'AppColors.successDark': 'AppColors.success',
  });
  replaceInFile('lib/features/worker/presentation/widgets/map_placeholder.dart', {
    'const Icon(PhosphorIcons.': 'Icon(PhosphorIcons.',
  });
  replaceInFile('lib/features/worker/presentation/widgets/history_job_card.dart', {
    'AppColors.successDark': 'AppColors.success',
  });
  print('Targeted fixes applied!');
}
