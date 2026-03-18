import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class LoadingState extends StatelessWidget {
  final String? message;
  final double? size;
  final bool fullScreen;

  const LoadingState({
    super.key,
    this.message,
    this.size,
    this.fullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();
    final spinnerGradient =
        tokens?.brandGradient ??
        const LinearGradient(
          colors: [Color(0xFF155EEF), Color(0xFF0E9384)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    final loadingWidget = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: size ?? 60,
            height: size ?? 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: spinnerGradient,
              boxShadow: [
                BoxShadow(
                  color: (tokens?.shadowSoft ?? Colors.black26).withValues(
                    alpha: 0.35,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.onPrimary,
              ),
              strokeWidth: 2.8,
            ),
          ).animate(
            effects: [
              const ScaleEffect(
                begin: Offset(0.8, 0.8),
                end: Offset(1.0, 1.0),
                duration: Duration(milliseconds: 600),
              ),
              const RotateEffect(
                begin: 0,
                end: 0.1,
                duration: Duration(milliseconds: 800),
                curve: Curves.easeInOut,
              ),
            ],
          ),
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ).animate(
              effects: [
                const FadeEffect(
                  begin: 0,
                  end: 1,
                  delay: Duration(milliseconds: 300),
                  duration: Duration(milliseconds: 400),
                ),
                const SlideEffect(
                  begin: Offset(0, 0.2),
                  end: Offset.zero,
                  delay: Duration(milliseconds: 300),
                  duration: Duration(milliseconds: 400),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (fullScreen) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: loadingWidget,
      );
    }

    return loadingWidget;
  }
}
