import 'dart:convert';
import 'dart:io';

const _enPath = 'assets/translations/en.json';
const _hiPath = 'assets/translations/hi.json';
const _defaultTop = 25;

final _translationCallPatterns = <RegExp>[
  RegExp(r"(?:\btranslate|\bt)\(\s*'([^']+)'"),
  RegExp(r'(?:\btranslate|\bt)\(\s*"([^"]+)"'),
];

void main(List<String> args) {
  final strict = args.contains('--strict');
  final top = _parseTop(args);

  final enFile = File(_enPath);
  final hiFile = File(_hiPath);
  if (!enFile.existsSync() || !hiFile.existsSync()) {
    stderr.writeln('Missing translation files: $_enPath or $_hiPath');
    exitCode = 1;
    return;
  }

  final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
  final hiJson = jsonDecode(hiFile.readAsStringSync()) as Map<String, dynamic>;
  final enLeaves = <String>{};
  final hiLeaves = <String>{};
  _collectLeaves(enJson, '', enLeaves);
  _collectLeaves(hiJson, '', hiLeaves);

  final usedKeys = _scanUsedTranslationKeys(Directory('lib'));

  final missingInEn = usedKeys.difference(enLeaves).toList()..sort();
  final missingInHi = usedKeys.difference(hiLeaves).toList()..sort();
  final unusedInEn = enLeaves.difference(usedKeys).toList()..sort();
  final unusedInHi = hiLeaves.difference(usedKeys).toList()..sort();

  stdout.writeln('Translation audit summary');
  stdout.writeln('  Used in code: ${usedKeys.length}');
  stdout.writeln('  Keys in en.json: ${enLeaves.length}');
  stdout.writeln('  Keys in hi.json: ${hiLeaves.length}');
  stdout.writeln('  Missing in en.json: ${missingInEn.length}');
  stdout.writeln('  Missing in hi.json: ${missingInHi.length}');
  stdout.writeln('  Unused in en.json: ${unusedInEn.length}');
  stdout.writeln('  Unused in hi.json: ${unusedInHi.length}');

  _printList('Missing in en.json', missingInEn, top);
  _printList('Missing in hi.json', missingInHi, top);
  _printList('Unused in en.json', unusedInEn, top);
  _printList('Unused in hi.json', unusedInHi, top);

  if (strict && (missingInEn.isNotEmpty || missingInHi.isNotEmpty)) {
    stderr.writeln('Translation audit failed in strict mode.');
    exitCode = 1;
  }
}

int _parseTop(List<String> args) {
  for (final arg in args) {
    if (arg.startsWith('--top=')) {
      final parsed = int.tryParse(arg.substring('--top='.length));
      if (parsed != null && parsed > 0) return parsed;
    }
  }
  return _defaultTop;
}

Set<String> _scanUsedTranslationKeys(Directory root) {
  final usedKeys = <String>{};
  if (!root.existsSync()) {
    return usedKeys;
  }

  for (final file in root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))) {
    final content = file.readAsStringSync();
    for (final pattern in _translationCallPatterns) {
      for (final match in pattern.allMatches(content)) {
        final key = match.group(1);
        if (key != null && key.isNotEmpty) {
          usedKeys.add(key);
        }
      }
    }
  }
  return usedKeys;
}

void _collectLeaves(dynamic node, String path, Set<String> output) {
  if (node is Map<String, dynamic>) {
    for (final entry in node.entries) {
      final next = path.isEmpty ? entry.key : '$path.${entry.key}';
      _collectLeaves(entry.value, next, output);
    }
    return;
  }

  if (node is List) {
    for (var i = 0; i < node.length; i++) {
      final next = '$path[$i]';
      _collectLeaves(node[i], next, output);
    }
    return;
  }

  output.add(path);
}

void _printList(String label, List<String> items, int top) {
  if (items.isEmpty) return;
  stdout.writeln('\n$label (${items.length}):');
  for (final item in items.take(top)) {
    stdout.writeln('  - $item');
  }
}
