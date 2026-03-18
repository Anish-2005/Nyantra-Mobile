# Contributing

## Development Setup
1. Install Flutter stable.
2. Run `flutter pub get`.
3. Configure Firebase for your target platform(s).

## Local Quality Checks
Run these before creating a pull request:

```bash
dart run tool/validate_translations.dart
dart format lib test
flutter analyze
flutter test
```

PowerShell shortcut:

```powershell
./tool/quality_check.ps1
```

## Pull Request Guidelines
- Keep PRs scoped and focused.
- Include tests for bug fixes or new behavior.
- Update docs for config or architecture changes.
- Avoid committing generated build artifacts.
