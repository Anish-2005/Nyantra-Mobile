# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Centralized logging utility (`AppLogger`) with level-based output.
- Shared Firestore query batching helper for safe `whereIn` access.
- Translation validation script and Windows quality-check script.
- CI workflow, contribution guide, and security policy.

### Changed
- App startup now includes guarded Firebase initialization and global error logging.
- `AuthProvider` initial sync behavior is guarded to prevent duplicate sync loops.
- Firestore collection usage is standardized through constants.
- Locale provider now supports fallback translation lookup and logs load/persistence failures.
- Theme provider now logs persistence/load failures.
