import 'dart:io';

void main() {
  final file = File(r'c:\Users\user\Downloads\FinalYearProject\artisansApp_frontend\lib\features\client\presentation\screens\client_home_screen.dart');
  String content = file.readAsStringSync();

  content = content.replaceAll("import '../client_shell.dart';\r\n", "");
  content = content.replaceAll("import '../client_shell.dart';\n", "");

  final regex = RegExp(r'class _T \{[\s\S]*?\n\}\s*');
  content = content.replaceAll(regex, '');

  content = content.replaceAll('_T.', 'DesignTokens.');

  if (!content.contains('design_tokens.dart')) {
    content = "import '../../../../core/theme/design_tokens.dart';\n" + content;
  }

  file.writeAsStringSync(content);
}
