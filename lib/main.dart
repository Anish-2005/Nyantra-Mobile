import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'src/core/services/firebase_service.dart';
import 'src/core/providers/theme_provider.dart';
import 'src/core/providers/locale_provider.dart';
import 'src/core/providers/auth_provider.dart';
import 'src/core/providers/connectivity_provider.dart';
import 'src/core/providers/sync_status_provider.dart';
import 'src/core/constants/app_constants.dart';
import 'src/core/utils/app_logger.dart';
import 'src/features/auth/screens/login_screen.dart';
import 'src/features/dashboard/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppLogger.error(
      'Unhandled Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    AppLogger.error(
      'Unhandled platform error',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  };

  Object? initializationError;

  // Initialize Firebase
  try {
    await FirebaseService.initialize();
  } catch (error, stackTrace) {
    initializationError = error;
    AppLogger.error(
      'Firebase initialization failed',
      error: error,
      stackTrace: stackTrace,
    );
  }

  runApp(MyApp(initializationError: initializationError));
}

class MyApp extends StatelessWidget {
  final Object? initializationError;

  const MyApp({super.key, this.initializationError});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => SyncStatusProvider()),
        ChangeNotifierProxyProvider<SyncStatusProvider, AuthProvider>(
          create: (_) => AuthProvider(),
          update: (_, syncStatusProvider, authProvider) {
            final provider = authProvider ?? AuthProvider();
            provider.setSyncStatusProvider(syncStatusProvider);
            return provider;
          },
        ),
      ],
      child: Consumer3<ThemeProvider, LocaleProvider, AuthProvider>(
        builder: (context, themeProvider, localeProvider, authProvider, child) {
          final home = initializationError != null
              ? InitializationErrorScreen(error: initializationError!)
              : !localeProvider.hasTranslations
              ? const SplashScreen()
              : authProvider.isLoading
              ? const SplashScreen()
              : authProvider.isAuthenticated
              ? const DashboardScreen()
              : const LoginScreen();

          return MaterialApp(
            title: AppConstants.appTitle,
            theme: themeProvider.themeData,
            locale: localeProvider.flutterLocale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppConstants.supportedLocales,
            home: home,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class InitializationErrorScreen extends StatelessWidget {
  final Object error;

  const InitializationErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Unable to start app',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Initialization failed: $error',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
