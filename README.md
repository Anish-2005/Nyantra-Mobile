# Nyantra Mobile

<p align="left">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.24%2B-02569B?logo=flutter&logoColor=white">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.5%2B-0175C2?logo=dart&logoColor=white">
  <img alt="Firebase" src="https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=black">
  <img alt="License" src="https://img.shields.io/badge/License-MIT-green.svg">
  <img alt="Platform" src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey">
</p>

Offline-first Flutter application for SC/ST Act relief workflows, including applications, beneficiaries, disbursements, grievances, reports, and feedback.

## Why Nyantra

| Focus Area | What It Delivers |
| --- | --- |
| Offline reliability | Local SQLite persistence for unstable network conditions. |
| Governed workflow | Structured modules for end-to-end relief processing. |
| Bilingual UX | English and Hindi localization support. |
| Operational visibility | Dashboards and reports for case movement and outcomes. |

## Feature Snapshot

| Module | Capabilities |
| --- | --- |
| Authentication | Google sign-in with Firebase Auth |
| Applications | Registration and status tracking |
| Beneficiaries | Beneficiary profile and case linkage |
| Disbursements | Assistance and payment workflow management |
| Grievances | Complaint capture and resolution tracking |
| Reports | Dashboard metrics and workflow visibility |
| Feedback | User-side feedback intake |

## Tech Stack

| Layer | Tools |
| --- | --- |
| App framework | Flutter, Dart |
| State management | Provider |
| Backend services | Firebase Auth, Cloud Firestore |
| Offline data | SQLite (`sqflite`) |
| Navigation | `go_router` |
| Localization | `intl`, `flutter_localizations` |

## Project Map

```text
lib/
  main.dart
  src/
    components/
    core/
      models/
      providers/
      repositories/
      services/
      utils/
      widgets/
    features/
      auth/
      dashboard/
```

## Quick Start

### Prerequisites

- Flutter SDK (stable channel)
- Dart SDK (bundled with Flutter)
- Android Studio or VS Code with Flutter tooling
- Firebase project configured for target platforms

### Local Setup

1. Clone the repository and open the root directory.
2. Install dependencies:

```bash
flutter pub get
```

3. Add Firebase config files:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist` (iOS)

4. Run the app:

```bash
flutter run
```

## Runtime Configuration

Email notifications use `NYANTRA_API_BASE_URL`:

```bash
flutter run --dart-define=NYANTRA_API_BASE_URL=https://api.example.com
```

If this variable is not provided, email sending is skipped and logged as a warning.

## Quality Gates

Run before opening a PR:

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

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Contributing](CONTRIBUTING.md)
- [Security](SECURITY.md)
- [Changelog](CHANGELOG.md)

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
