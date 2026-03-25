# Nyantra Mobile 🚀

Offline-first Flutter application for managing SC/ST Act relief workflows, including applications, beneficiaries, disbursements, grievances, and feedback.

## Highlights
- Offline-first data flow with local SQLite persistence and cloud sync.
- Google sign-in and Firebase-backed data access.
- Dashboard workflow for applications, beneficiaries, disbursements, reports, grievances, and feedback.
- English and Hindi localization support.

## Tech Stack
- Flutter + Dart
- Provider (state management)
- Firebase Auth + Firestore
- SQLite (`sqflite`) for local/offline storage

## Project Structure
```text
lib/
  main.dart
  src/
    components/
    core/
      repositories/
      models/
      providers/
      services/
      utils/
      widgets/
    features/
      auth/
      dashboard/
```

## Prerequisites
- Flutter SDK (stable)
- Dart SDK (bundled with Flutter)
- Android Studio or VS Code with Flutter plugin
- Firebase project configured for your target platforms

## Local Setup
1. Clone and enter the repository.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Add Firebase platform configuration files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist` (for iOS builds)
4. Run the app:
   ```bash
   flutter run
   ```

## Runtime Configuration
Email notifications use an API endpoint configured with a Dart define:

```bash
flutter run --dart-define=NYANTRA_API_BASE_URL=https://api.example.com
```

If `NYANTRA_API_BASE_URL` is not provided, email sending is skipped with a warning log.

## Quality Gates
Run these commands before opening a PR:

```bash
dart run tool/validate_translations.dart
dart run tool/audit_translation_keys.dart --top=20
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
dart run tool/check_coverage.dart --min=1
```

A GitHub Actions pipeline also runs format checks, analyze, and tests on push/PR.
On Windows PowerShell, you can run all checks via:

```powershell
./tool/quality_check.ps1
```

## Notes
- Firestore `whereIn` queries are batched to handle production-scale ID sets safely.
- Logging is centralized through `AppLogger` for cleaner observability.
- Placeholder duplicate core files under `lib/src/features/core` were removed to reduce architectural noise.

## Additional Docs
- Architecture: `docs/ARCHITECTURE.md`
- Contribution Guide: `CONTRIBUTING.md`
- Security Policy: `SECURITY.md`
- Changelog: `CHANGELOG.md`
