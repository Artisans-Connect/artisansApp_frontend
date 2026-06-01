import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  final regex = RegExp(r'Icons\.([a-zA-Z0-9_]+)');
  final icons = <String>{};

  for (final file in files) {
    final content = file.readAsStringSync();
    final matches = regex.allMatches(content);
    for (final match in matches) {
      icons.add(match.group(1)!);
    }
  }

  print(icons.toList()..sort());
}
