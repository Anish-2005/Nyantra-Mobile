// ignore_for_file: directives_ordering

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

import '../core/theme/app_theme.dart';

class AnimatedBackground extends StatefulWidget {
  final bool isDark;

  const AnimatedBackground({super.key, required this.isDark});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late final AnimationController _textureController;
  late final AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _textureController = AnimationController(
      duration: const Duration(seconds: 24),
      vsync: this,
    )..repeat();

    _orbController = AnimationController(
      duration: const Duration(seconds: 14),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _textureController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();
    final isDarkTheme = widget.isDark || theme.brightness == Brightness.dark;
    final shouldForceDarkPalette =
        isDarkTheme && (tokens == null || _isLightBackground(tokens));
    final backgroundGradient = shouldForceDarkPalette
        ? const LinearGradient(
            colors: [Color(0xFF030B1A), Color(0xFF08203D), Color(0xFF0B2A4F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : tokens?.backgroundGradient ??
            const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFFFFAF3), Color(0xFFFFF1E1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );
    final brandStart = shouldForceDarkPalette
        ? const Color(0xFF0EA5E9)
        : tokens?.brandStart ?? const Color(0xFF155EEF);
    final brandEnd = shouldForceDarkPalette
        ? const Color(0xFF7DD3FC)
        : tokens?.brandEnd ?? const Color(0xFF0E9384);
    final tertiaryColor = shouldForceDarkPalette
        ? const Color(0xFF60A5FA)
        : theme.colorScheme.tertiary;
    final textureGridColor = shouldForceDarkPalette
        ? const Color(0xFF2C4D72)
        : tokens?.borderSubtle ?? const Color(0xFFE7E5E4);

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(gradient: backgroundGradient),
            child: const SizedBox.expand(),
          ),
          AnimatedBuilder(
            animation: _orbController,
            builder: (context, child) {
              return Stack(
                children: [
                  _floatingOrb(
                    alignment: const Alignment(-0.9, -0.85),
                    color: brandStart,
                    size: 280,
                    glow: 58,
                    t: _orbController.value,
                    dxAmplitude: 40,
                    dyAmplitude: 28,
                  ),
                  _floatingOrb(
                    alignment: const Alignment(0.85, -0.55),
                    color: brandEnd,
                    size: 220,
                    glow: 52,
                    t: 1 - _orbController.value,
                    dxAmplitude: 35,
                    dyAmplitude: 18,
                  ),
                  _floatingOrb(
                    alignment: const Alignment(0.9, 0.92),
                    color: tertiaryColor,
                    size: 320,
                    glow: 64,
                    t: _orbController.value * 0.8,
                    dxAmplitude: 26,
                    dyAmplitude: 34,
                  ),
                ],
              );
            },
          ),
          AnimatedBuilder(
            animation: _textureController,
            builder: (context, child) {
              return CustomPaint(
                painter: _TexturePainter(
                  animation: _textureController.value,
                  tokenColor: brandStart,
                  gridColor: textureGridColor,
                  isDarkPalette: isDarkTheme,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isLightBackground(AppThemeTokens tokens) {
    final averageLuminance = (tokens.backgroundStart.computeLuminance() +
            tokens.backgroundMid.computeLuminance() +
            tokens.backgroundEnd.computeLuminance()) /
        3;
    return averageLuminance > 0.32;
  }

  Widget _floatingOrb({
    required Alignment alignment,
    required Color color,
    required double size,
    required double glow,
    required double t,
    required double dxAmplitude,
    required double dyAmplitude,
  }) {
    final wave = sin(t * 2 * pi);
    final drift = cos(t * 2 * pi);

    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(wave * dxAmplitude, drift * dyAmplitude),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: glow, sigmaY: glow),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.22),
            ),
          ),
        ),
      ),
    );
  }
}

class _TexturePainter extends CustomPainter {
  final double animation;
  final Color tokenColor;
  final Color gridColor;
  final bool isDarkPalette;

  const _TexturePainter({
    required this.animation,
    required this.tokenColor,
    required this.gridColor,
    required this.isDarkPalette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final particlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = tokenColor.withValues(alpha: 0.09);
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = gridColor.withValues(alpha: isDarkPalette ? 0.09 : 0.16);
    final random = Random(17);

    const spacing = 58.0;
    final lineShift = animation * spacing;

    for (double x = -spacing; x <= size.width + spacing; x += spacing) {
      final dx = x + lineShift;
      canvas.drawLine(Offset(dx, 0), Offset(dx - 28, size.height), linePaint);
    }

    for (int i = 0; i < 70; i++) {
      final x =
          (random.nextDouble() * size.width + animation * (45 + i * 0.6)) %
              size.width;
      final y =
          (random.nextDouble() * size.height + animation * (24 + i * 0.4)) %
              size.height;
      final radius = random.nextDouble() * 1.8 + 0.5;
      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TexturePainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.tokenColor != tokenColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.isDarkPalette != isDarkPalette;
  }
}
