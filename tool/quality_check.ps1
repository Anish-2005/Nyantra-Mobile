$ErrorActionPreference = 'Stop'

Write-Host 'Running translation validation...'
dart run tool/validate_translations.dart

Write-Host 'Checking formatting...'
dart format --output=none --set-exit-if-changed lib test tool

Write-Host 'Running static analysis...'
flutter analyze

Write-Host 'Running tests...'
flutter test

Write-Host 'Quality checks completed successfully.'
