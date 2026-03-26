# Contributing to Nyantra Mobile

Thank you for contributing to Nyantra Mobile. This guide explains the expected workflow for proposing and shipping changes.

## Development Setup

1. Install Flutter stable.
2. Run dependency install:

```bash
flutter pub get
```

3. Configure Firebase for your target platform(s).
4. Verify the app boots locally:

```bash
flutter run
```

## Branching and Scope

- Create a feature branch from `main`.
- Keep pull requests focused to one logical change.
- Avoid mixing refactors, bug fixes, and feature work in one PR unless tightly related.

## Code Quality Requirements

Run all checks before opening or updating a pull request:

```bash
dart run tool/validate_translations.dart
dart run tool/audit_translation_keys.dart --top=20
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/check_coverage.dart --min=1
```

PowerShell shortcut:

```powershell
./tool/quality_check.ps1
```

## Pull Request Checklist

- Add or update tests for behavior changes.
- Update relevant docs when architecture, config, or workflows change.
- Keep generated files and build artifacts out of commits.
- Include a clear PR description with context, approach, and test evidence.

## Commit Guidance

- Write descriptive commit messages in imperative mood.
- Prefer small, reviewable commits.
- Reference issue IDs in commits or PR descriptions when applicable.

## Issue Reporting

For bug reports, include:

- Expected behavior
- Actual behavior
- Steps to reproduce
- Platform details (device, OS, app build)
- Logs or screenshots when useful

## Security Reporting

Do not open public issues for sensitive vulnerabilities.
Use the process defined in [SECURITY.md](SECURITY.md).

## Contributor License Expectations

By submitting code, documentation, or tests, you agree that your contributions are licensed under this repository's [MIT License](LICENSE).
