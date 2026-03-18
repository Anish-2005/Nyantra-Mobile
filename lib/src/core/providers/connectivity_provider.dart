// ignore_for_file: directives_ordering

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  List<ConnectivityResult> _connectivityResults = [];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool get isOnline =>
      _connectivityResults.isNotEmpty &&
      _connectivityResults.any((result) => result != ConnectivityResult.none);

  ConnectivityProvider() {
    _initConnectivity();
    _listenConnectivity();
  }

  Future<void> _initConnectivity() async {
    _connectivityResults = await _connectivity.checkConnectivity();
    notifyListeners();
  }

  void _listenConnectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _connectivityResults = results;
      notifyListeners();
    });
  }

  List<ConnectivityResult> get connectivityResults => _connectivityResults;

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
