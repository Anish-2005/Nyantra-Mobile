import 'dart:io';

const _defaultMinCoverage = 1.0;
const _lcovPath = 'coverage/lcov.info';

void main(List<String> args) {
  final minCoverage = _parseMinCoverage(args);
  final lcovFile = File(_lcovPath);
  if (!lcovFile.existsSync()) {
    stderr.writeln('Coverage file not found: $_lcovPath');
    exitCode = 1;
    return;
  }

  var totalLines = 0;
  var coveredLines = 0;
  for (final line in lcovFile.readAsLinesSync()) {
    if (!line.startsWith('DA:')) continue;
    final payload = line.substring(3).split(',');
    if (payload.length != 2) continue;
    final hits = int.tryParse(payload[1]) ?? 0;
    totalLines++;
    if (hits > 0) {
      coveredLines++;
    }
  }

  if (totalLines == 0) {
    stderr.writeln('No executable lines found in coverage report.');
    exitCode = 1;
    return;
  }

  final coverage = (coveredLines / totalLines) * 100;
  stdout.writeln(
    'Coverage: ${coverage.toStringAsFixed(2)}% '
    '($coveredLines/$totalLines), minimum required: ${minCoverage.toStringAsFixed(2)}%',
  );

  if (coverage < minCoverage) {
    stderr.writeln('Coverage check failed.');
    exitCode = 1;
  }
}

double _parseMinCoverage(List<String> args) {
  for (final arg in args) {
    if (arg.startsWith('--min=')) {
      final parsed = double.tryParse(arg.substring('--min='.length));
      if (parsed != null) return parsed;
    }
  }
  return _defaultMinCoverage;
}
