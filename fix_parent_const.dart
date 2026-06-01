import 'dart:io';

void replaceInFile(String path, Map<RegExp, String> replacements) {
  final file = File(path);
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  for (final entry in replacements.entries) {
    content = content.replaceAll(entry.key, entry.value);
  }
  file.writeAsStringSync(content);
}

void main() {
  replaceInFile('lib/features/worker/presentation/screens/worker_active_empty_screen.dart', {
    RegExp(r'const Center\(\s*child: Icon\(\s*PhosphorIcons.wrench'): 'Center(child: Icon(PhosphorIcons.wrench',
  });
  
  replaceInFile('lib/features/worker/presentation/widgets/map_placeholder.dart', {
    RegExp(r'const Center\(\s*child: Icon\(\s*PhosphorIcons.mapPin'): 'Center(child: Icon(PhosphorIcons.mapPin',
  });
  
  replaceInFile('lib/shared/presentation/screens/chat_detail_screen.dart', {
    RegExp(r'const Padding\(\s*padding:\s*EdgeInsets.all\(10\),\s*child: Icon\(PhosphorIcons.plus'): 'Padding(padding: const EdgeInsets.all(10), child: Icon(PhosphorIcons.plus',
    RegExp(r'const Padding\(\s*padding:\s*EdgeInsets.all\(12\),\s*child: Icon\(PhosphorIcons.paperPlaneRight'): 'Padding(padding: const EdgeInsets.all(12), child: Icon(PhosphorIcons.paperPlaneRight',
  });
  
  replaceInFile('lib/shared/presentation/screens/user_profile_screen.dart', {
    RegExp(r'const Positioned\(\s*bottom: 0,\s*right: 0,\s*child: CircleAvatar\(\s*radius: 14,\s*backgroundColor: AppColors.success,\s*child: Icon\(PhosphorIcons.sealCheck'): 'Positioned(bottom: 0, right: 0, child: CircleAvatar(radius: 14, backgroundColor: AppColors.success, child: Icon(PhosphorIcons.sealCheck',
  });
  
  print('Parent const fixes applied with Regex!');
}
