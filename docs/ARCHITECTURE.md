# Architecture Overview

## High-Level Flow
1. UI reads and writes through providers and services.
2. Local persistence (`DatabaseHelper`) stores offline-safe data.
3. `SyncService` synchronizes local changes with Firestore when online.
4. `DataService` powers live dashboard data streams and CRUD operations.

## Core Modules
- `lib/src/core/models`: domain data models
- `lib/src/core/providers`: app state and user/session context
- `lib/src/core/services`: Firebase, sync, and data access logic
- `lib/src/core/utils`: cross-cutting utilities (for example logging)
- `lib/src/features`: feature-level screens and widgets

## Reliability Notes
- Firestore `whereIn` access is batched to respect query limits.
- Sync status is surfaced through `SyncStatusProvider`.
- Logging is centralized via `AppLogger` for cleaner diagnostics.
