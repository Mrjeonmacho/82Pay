import 'dart:io';

void main() {
  final mappingContent = File(r'c:\Users\SSAFY\Desktop\yeji\A208\S14P21A208\palipay\palipay-frontend\lib\i18n_mapping.txt').readAsStringSync();
  
  final mappingRegex = RegExp(r"^'(.+)'\s*:\s*'(.+)'$");
  final keysToFind = <String>{};
  
  for (final line in mappingContent.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final match = mappingRegex.firstMatch(trimmed);
    if (match != null) {
      keysToFind.add(match.group(1)!);
    }
  }

  // TARGET ONLY FEATURES
  final directory = Directory(r'c:\Users\SSAFY\Desktop\yeji\A208\S14P21A208\palipay\palipay-frontend\lib\features');
  if (!directory.existsSync()) {
     print("Directory not found!");
     return;
  }
  
  final files = directory.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  final filesToModify = <String>{};
  
  final textRegex = RegExp(r'''Text\s*\(\s*(['"])(.*?)\1''', dotAll: true);

  for (var file in files) {
    if (file.path.contains('.antigravityignore')) continue;
    
    final content = file.readAsStringSync();
    final matches = textRegex.allMatches(content);
    for (var match in matches) {
      final text = match.group(2) ?? '';
      String codeText = text.replaceAll('\n', r'\n');
      if (keysToFind.contains(codeText) || keysToFind.contains(text)) {
        filesToModify.add(file.path.replaceAll(r'\', '/')); // keep full paths
      }
    }
  }
  
  File(r'c:\Users\SSAFY\Desktop\yeji\A208\S14P21A208\palipay\palipay-frontend\files_to_update.txt')
     .writeAsStringSync(filesToModify.toList()..sort().join('\n'));
}
