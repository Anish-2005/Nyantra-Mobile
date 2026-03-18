# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Centralized logging utility (`AppLogger`) with level-based output.
- Shared Firestore query batching helper for safe `whereIn` access.
- Translation validation script and Windows quality-check script.
- CI workflow, contribution guide, and security policy.
- Translation key audit script (`tool/audit_translation_keys.dart`).
- Coverage threshold script (`tool/check_coverage.dart`).
- Repository-layer modules for dashboard, applications, beneficiaries, disbursements, grievances, feedback, and users.
- Sync status provider tests.

### Changed
- App startup now includes guarded Firebase initialization and global error logging.
- `AuthProvider` initial sync behavior is guarded to prevent duplicate sync loops.
- Firestore collection usage is standardized through constants.
- Locale provider now supports fallback translation lookup and logs load/persistence failures.
- Theme provider now logs persistence/load failures.
- `DataService` is now a thin facade delegating to repository modules.
- Deprecated color opacity usage has been migrated to `withValues(alpha: ...)`.
- Duplicate beneficiary controller init/dispose in application edit flows has been fixed.
- Async context handling in application edit save flows now checks widget mount state before UI calls.
- `path` is now an explicit direct dependency (removing `depend_on_referenced_packages` suppression).
