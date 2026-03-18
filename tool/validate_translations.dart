import 'dart:convert';
import 'dart:io';

const _enPath = 'assets/translations/en.json';
const _hiPath = 'assets/translations/hi.json';
final _singleBracePlaceholderRegex = RegExp(r'\{([a-zA-Z0-9_.]+)\}');
final _doubleBracePlaceholderRegex = RegExp(r'\{\{([a-zA-Z0-9_.]+)\}\}');

void main() {
  final enFile = File(_enPath);
  final hiFile = File(_hiPath);

  if (!enFile.existsSync() || !hiFile.existsSync()) {
    stderr.writeln('Missing translation files: $_enPath or $_hiPath');
    exitCode = 1;
    return;
  }

  final enJson = _loadLocaleMap(_enPath);
  final hiJson = _loadLocaleMap(_hiPath);
  if (enJson == null || hiJson == null) {
    exitCode = 1;
    return;
  }

  final enLeaves = <String, dynamic>{};
  final hiLeaves = <String, dynamic>{};
  _collectLeaves(enJson, '', enLeaves);
  _collectLeaves(hiJson, '', hiLeaves);

  final enKeys = enLeaves.keys.toSet();
  final hiKeys = hiLeaves.keys.toSet();
  final missingInHi = enKeys.difference(hiKeys).toList()..sort();
  final missingInEn = hiKeys.difference(enKeys).toList()..sort();

  var hasError = false;

  if (missingInHi.isNotEmpty) {
    hasError = true;
    stderr.writeln('Missing in hi.json (${missingInHi.length}):');
    for (final key in missingInHi.take(20)) {
      stderr.writeln('  - $key');
    }
  }

  if (missingInEn.isNotEmpty) {
    hasError = true;
    stderr.writeln('Missing in en.json (${missingInEn.length}):');
    for (final key in missingInEn.take(20)) {
      stderr.writeln('  - $key');
    }
  }

  final placeholderMismatches = <String>[];
  for (final key in enKeys.intersection(hiKeys)) {
    final enValue = enLeaves[key];
    final hiValue = hiLeaves[key];
    if (enValue is! String || hiValue is! String) {
      continue;
    }

    final enPlaceholders = _extractPlaceholders(enValue);
    final hiPlaceholders = _extractPlaceholders(hiValue);
    if (enPlaceholders.length != hiPlaceholders.length ||
        !enPlaceholders.containsAll(hiPlaceholders)) {
      placeholderMismatches.add(key);
    }
  }

  if (placeholderMismatches.isNotEmpty) {
    hasError = true;
    stderr.writeln(
      'Placeholder mismatch between locale files (${placeholderMismatches.length}):',
    );
    for (final key in placeholderMismatches.take(20)) {
      stderr.writeln('  - $key');
    }
  }

  if (hasError) {
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Translation validation passed (${enLeaves.length} keys checked).',
  );
}

Map<String, dynamic>? _loadLocaleMap(String path) {
  final file = File(path);
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, dynamic>) {
      stderr.writeln('Invalid locale root in $path: expected JSON object.');
      return null;
    }
    return decoded;
  } on FormatException catch (error) {
    stderr.writeln('Invalid JSON in $path: ${error.message}');
    return null;
  } catch (error) {
    stderr.writeln('Failed to read $path: $error');
    return null;
  }
}

void _collectLeaves(
  dynamic node,
  String path,
  Map<String, dynamic> output,
) {
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

  output[path] = node;
}

Set<String> _extractPlaceholders(String input) {
  final placeholders = <String>{};

  for (final match in _doubleBracePlaceholderRegex.allMatches(input)) {
    final name = match.group(1);
    if (name != null) {
      placeholders.add(name);
    }
  }

  for (final match in _singleBracePlaceholderRegex.allMatches(input)) {
    final name = match.group(1);
    if (name != null) {
      placeholders.add(name);
    }
  }

  return placeholders;
}
