import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    String content = file.readAsStringSync();
    bool changed = false;

    // Pattern 1: const Icon(PhosphorIcons.xxx())
    final regex1 = RegExp(r'const\s+(Icon\s*\(\s*PhosphorIcons)');
    if (regex1.hasMatch(content)) {
      content = content.replaceAllMapped(regex1, (m) => m.group(1)!);
      changed = true;
    }

    // Pattern 2: const PhosphorIcons.xxx()
    final regex2 = RegExp(r'const\s+(PhosphorIcons)');
    if (regex2.hasMatch(content)) {
      content = content.replaceAllMapped(regex2, (m) => m.group(1)!);
      changed = true;
    }

    // Pattern 3: const _NavItem(icon: PhosphorIcons.xxx)
    // Actually just removing const before any widget that immediately uses PhosphorIcons is hard.
    // Let's do a more generic regex: replace "const " with "" on the same line if PhosphorIcons is present?
    // Let's just do a simple line-by-line check. If a line contains PhosphorIcons and has 'const ', it might be invalid.
    // Wait, replacing 'const ' naively might break other things on the line.
    
    // Instead of regex, let's just do a regex that finds `const WidgetName(..., PhosphorIcons` which is hard.
    // I'll run this basic fix first.
    if (changed) {
      file.writeAsStringSync(content);
      print('Fixed const in ${file.path}');
    }
  }
}
