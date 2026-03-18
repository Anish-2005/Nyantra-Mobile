import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/sync_service.dart';
import '../utils/app_logger.dart';
import 'sync_status_provider.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = true;
  SyncStatusProvider? _syncStatusProvider;
  StreamSubscription<User?>? _authStateSubscription;
  String? _lastInitialSyncUserId;
  bool _isInitialSyncInProgress = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void setSyncStatusProvider(SyncStatusProvider provider) {
    if (identical(_syncStatusProvider, provider)) {
      return;
    }
    _syncStatusProvider = provider;
    _maybeStartInitialSync();
  }

  void _init() {
    _authStateSubscription = FirebaseService.auth.authStateChanges().listen(
      _handleAuthStateChanged,
      onError: (Object error, StackTrace stackTrace) {
        _isLoading = false;
        AppLogger.error(
          'Auth state stream failed',
          error: error,
          stackTrace: stackTrace,
        );
        notifyListeners();
      },
    );
  }

  void _handleAuthStateChanged(User? user) {
    final previousUserId = _user?.uid;
    _user = user;
    _isLoading = false;

    if (user == null) {
      _lastInitialSyncUserId = null;
      _isInitialSyncInProgress = false;
    } else if (previousUserId != user.uid) {
      _lastInitialSyncUserId = null;
    }

    _maybeStartInitialSync();
    notifyListeners();
  }

  void _maybeStartInitialSync() {
    final userId = _user?.uid;
    if (userId == null || _syncStatusProvider == null) {
      return;
    }
    if (_isInitialSyncInProgress || _lastInitialSyncUserId == userId) {
      return;
    }

    _isInitialSyncInProgress = true;
    final syncService = SyncService(syncStatusProvider: _syncStatusProvider);
    unawaited(_runInitialSync(syncService, userId));
  }

  Future<void> _runInitialSync(SyncService syncService, String userId) async {
    try {
      await syncService.syncFromFirestore();
      _lastInitialSyncUserId = userId;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Initial Firestore sync failed',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isInitialSyncInProgress = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await FirebaseService.signInWithGoogle();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error signing in with Google',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseService.auth.signOut();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Error signing out',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
