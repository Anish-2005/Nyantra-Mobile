import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_dashboard_app/src/core/providers/sync_status_provider.dart';

void main() {
  group('SyncStatusProvider', () {
    test('starts idle with no pending sync', () {
      final provider = SyncStatusProvider();

      expect(provider.status, SyncStatus.idle);
      expect(provider.pendingSyncCount, 0);
      expect(provider.hasPendingSync, isFalse);
      expect(provider.getStatusText(), 'Synced');
      expect(provider.getStatusColor(), Colors.green);
      expect(provider.getStatusIcon(), Icons.sync);
    });

    test('tracks pending sync count', () {
      final provider = SyncStatusProvider();

      provider.incrementPendingSync();
      provider.incrementPendingSync();
      provider.decrementPendingSync();

      expect(provider.pendingSyncCount, 1);
      expect(provider.hasPendingSync, isTrue);
      expect(provider.getStatusText(), '1 items to sync');
    });

    test('stores error status and clears it on success', () {
      final provider = SyncStatusProvider();

      provider.setStatus(SyncStatus.error, error: 'Network failure');
      expect(provider.status, SyncStatus.error);
      expect(provider.lastError, 'Network failure');

      provider.setStatus(SyncStatus.success);
      expect(provider.status, SyncStatus.success);
      expect(provider.lastError, isNull);
      expect(provider.lastSyncTime, isNotNull);
      expect(provider.getStatusText(), 'Synced successfully');
    });
  });
}
