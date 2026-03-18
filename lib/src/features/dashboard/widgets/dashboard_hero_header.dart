import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';

class DashboardHeroHeader extends StatelessWidget {
  final IconData icon;
  final String badge;
  final String title;
  final String subtitle;
  final EdgeInsetsGeometry margin;
  final bool animate;
  final List<Widget> trailing;

  const DashboardHeroHeader({
    super.key,
    required this.icon,
    required this.badge,
    required this.title,
    required this.subtitle,
    this.margin = const EdgeInsets.all(20),
    this.animate = true,
    this.trailing = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();

    Widget content = Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient:
            tokens?.brandGradient ??
            const LinearGradient(
              colors: [Color(0xFF155EEF), Color(0xFF0E9384)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: (tokens?.shadowSoft ?? Colors.black26).withValues(alpha: 0.5),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          badge,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (trailing.isNotEmpty) ...[
                const SizedBox(width: 12),
                ...trailing,
              ],
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );

    if (!animate) {
      return content;
    }

    return content
        .animate()
        .fadeIn(duration: 550.ms)
        .slideY(begin: -0.06, end: 0, curve: Curves.easeOutCubic);
  }
}

