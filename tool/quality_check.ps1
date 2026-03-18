$ErrorActionPreference = 'Stop'

Write-Host 'Running translation validation...'
dart run tool/validate_translations.dart

Write-Host 'Auditing translation key usage...'
dart run tool/audit_translation_keys.dart --top=20

Write-Host 'Checking formatting...'
dart format --output=none --set-exit-if-changed lib test tool

Write-Host 'Running static analysis...'
flutter analyze

Write-Host 'Running tests...'
flutter test --coverage

Write-Host 'Checking minimum coverage threshold...'
dart run tool/check_coverage.dart --min=1

Write-Host 'Quality checks completed successfully.'
