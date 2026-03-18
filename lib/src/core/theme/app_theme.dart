import 'package:flutter/material.dart';

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  final Color brandStart;
  final Color brandEnd;
  final Color backgroundStart;
  final Color backgroundMid;
  final Color backgroundEnd;
  final Color surfaceBase;
  final Color surfaceRaised;
  final Color surfaceMuted;
  final Color borderSubtle;
  final Color borderStrong;
  final Color shadowSoft;
  final Color online;
  final Color offline;
  final Color success;
  final Color warning;
  final Color danger;

  const AppThemeTokens({
    required this.brandStart,
    required this.brandEnd,
    required this.backgroundStart,
    required this.backgroundMid,
    required this.backgroundEnd,
    required this.surfaceBase,
    required this.surfaceRaised,
    required this.surfaceMuted,
    required this.borderSubtle,
    required this.borderStrong,
    required this.shadowSoft,
    required this.online,
    required this.offline,
    required this.success,
    required this.warning,
    required this.danger,
  });

  Gradient get brandGradient => LinearGradient(
        colors: [brandStart, brandEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  Gradient get backgroundGradient => LinearGradient(
        colors: [backgroundStart, backgroundMid, backgroundEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  @override
  AppThemeTokens copyWith({
    Color? brandStart,
    Color? brandEnd,
    Color? backgroundStart,
    Color? backgroundMid,
    Color? backgroundEnd,
    Color? surfaceBase,
    Color? surfaceRaised,
    Color? surfaceMuted,
    Color? borderSubtle,
    Color? borderStrong,
    Color? shadowSoft,
    Color? online,
    Color? offline,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return AppThemeTokens(
      brandStart: brandStart ?? this.brandStart,
      brandEnd: brandEnd ?? this.brandEnd,
      backgroundStart: backgroundStart ?? this.backgroundStart,
      backgroundMid: backgroundMid ?? this.backgroundMid,
      backgroundEnd: backgroundEnd ?? this.backgroundEnd,
      surfaceBase: surfaceBase ?? this.surfaceBase,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      shadowSoft: shadowSoft ?? this.shadowSoft,
      online: online ?? this.online,
      offline: offline ?? this.offline,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) {
      return this;
    }
    return AppThemeTokens(
      brandStart: Color.lerp(brandStart, other.brandStart, t)!,
      brandEnd: Color.lerp(brandEnd, other.brandEnd, t)!,
      backgroundStart: Color.lerp(backgroundStart, other.backgroundStart, t)!,
      backgroundMid: Color.lerp(backgroundMid, other.backgroundMid, t)!,
      backgroundEnd: Color.lerp(backgroundEnd, other.backgroundEnd, t)!,
      surfaceBase: Color.lerp(surfaceBase, other.surfaceBase, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      shadowSoft: Color.lerp(shadowSoft, other.shadowSoft, t)!,
      online: Color.lerp(online, other.online, t)!,
      offline: Color.lerp(offline, other.offline, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _buildTheme(
        brightness: Brightness.light,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFFF97316),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFFFEDD5),
          onPrimaryContainer: Color(0xFF7C2D12),
          secondary: Color(0xFFEA580C),
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFFFF1D6),
          onSecondaryContainer: Color(0xFF5C3B00),
          tertiary: Color(0xFFFB923C),
          onTertiary: Color(0xFF3A2100),
          tertiaryContainer: Color(0xFFFFE9D5),
          onTertiaryContainer: Color(0xFF6F2D00),
          error: Color(0xFFB42318),
          onError: Colors.white,
          errorContainer: Color(0xFFFEE4E2),
          onErrorContainer: Color(0xFF5E1912),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF1C1917),
          onSurfaceVariant: Color(0xFF57534E),
          outline: Color(0xFFE7E5E4),
          outlineVariant: Color(0xFFF5F5F4),
          shadow: Color(0x141C1917),
          scrim: Color(0x661C1917),
          inverseSurface: Color(0xFF292524),
          onInverseSurface: Color(0xFFFAFAF9),
          inversePrimary: Color(0xFFFFB07A),
        ),
        tokens: const AppThemeTokens(
          brandStart: Color(0xFFFF7A1A),
          brandEnd: Color(0xFFFFB347),
          backgroundStart: Color(0xFFFFFFFF),
          backgroundMid: Color(0xFFFFFAF3),
          backgroundEnd: Color(0xFFFFF1E1),
          surfaceBase: Color(0xFFFFFCF8),
          surfaceRaised: Color(0xFFFFFFFF),
          surfaceMuted: Color(0xFFFFF5EB),
          borderSubtle: Color(0xFFF4E1CF),
          borderStrong: Color(0xFFE8C8AA),
          shadowSoft: Color(0x1A442200),
          online: Color(0xFF0F8A4B),
          offline: Color(0xFFD92D20),
          success: Color(0xFF0F8A4B),
          warning: Color(0xFFC2410C),
          danger: Color(0xFFD92D20),
        ),
      );

  static ThemeData dark() => _buildTheme(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF38BDF8),
          onPrimary: Color(0xFF04263A),
          primaryContainer: Color(0xFF0C4A6E),
          onPrimaryContainer: Color(0xFFDBF4FF),
          secondary: Color(0xFF7DD3FC),
          onSecondary: Color(0xFF07283D),
          secondaryContainer: Color(0xFF075985),
          onSecondaryContainer: Color(0xFFD8F2FF),
          tertiary: Color(0xFF60A5FA),
          onTertiary: Color(0xFF071C3A),
          tertiaryContainer: Color(0xFF1E3A8A),
          onTertiaryContainer: Color(0xFFDDE8FF),
          error: Color(0xFFF97066),
          onError: Color(0xFF460D09),
          errorContainer: Color(0xFF7A271A),
          onErrorContainer: Color(0xFFFEE4E2),
          surface: Color(0xFF081427),
          onSurface: Color(0xFFE6F0FF),
          onSurfaceVariant: Color(0xFFAEC2DB),
          outline: Color(0xFF304A66),
          outlineVariant: Color(0xFF1A2E45),
          shadow: Color(0xB3000000),
          scrim: Color(0x9F000000),
          inverseSurface: Color(0xFFE8F3FF),
          onInverseSurface: Color(0xFF0A1526),
          inversePrimary: Color(0xFF0EA5E9),
        ),
        tokens: const AppThemeTokens(
          brandStart: Color(0xFF0EA5E9),
          brandEnd: Color(0xFF7DD3FC),
          backgroundStart: Color(0xFF030B1A),
          backgroundMid: Color(0xFF08203D),
          backgroundEnd: Color(0xFF0B2A4F),
          surfaceBase: Color(0xFF071321),
          surfaceRaised: Color(0xFF0B1C30),
          surfaceMuted: Color(0xFF132B45),
          borderSubtle: Color(0xFF1B3654),
          borderStrong: Color(0xFF2C4D72),
          shadowSoft: Color(0x8A010A17),
          online: Color(0xFF6EE7B7),
          offline: Color(0xFFFDA29B),
          success: Color(0xFF6EE7B7),
          warning: Color(0xFFFCD34D),
          danger: Color(0xFFFDA29B),
        ),
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required AppThemeTokens tokens,
  }) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
    );

    final textTheme = _textTheme(base.textTheme, colorScheme);
    const radius = BorderRadius.all(Radius.circular(18));

    return base.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: tokens.surfaceBase,
      canvasColor: tokens.surfaceBase,
      cardColor: tokens.surfaceRaised,
      dialogBackgroundColor: tokens.surfaceRaised,
      textTheme: textTheme,
      dividerColor: tokens.borderSubtle,
      shadowColor: tokens.shadowSoft,
      extensions: [tokens],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: tokens.surfaceRaised.withValues(alpha: isDark ? 0.92 : 0.98),
        elevation: 0,
        shadowColor: tokens.shadowSoft,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: tokens.borderSubtle),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: tokens.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: tokens.borderSubtle),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: tokens.borderSubtle),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surfaceRaised.withValues(alpha: isDark ? 0.78 : 0.94),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
        ),
        floatingLabelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: tokens.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: tokens.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: colorScheme.error, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: BorderSide(color: tokens.borderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(14)),
          ),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(42, 42),
          padding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: tokens.surfaceMuted,
        selectedColor: colorScheme.primaryContainer,
        side: BorderSide(color: tokens.borderSubtle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: textTheme.labelMedium,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return tokens.surfaceMuted;
        }),
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        iconColor: colorScheme.onSurfaceVariant,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: tokens.surfaceMuted,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      scrollbarTheme: ScrollbarThemeData(
        radius: const Radius.circular(999),
        thickness: WidgetStateProperty.all(6),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.dragged)) {
            return colorScheme.primary.withValues(alpha: 0.82);
          }
          return colorScheme.primary.withValues(alpha: 0.56);
        }),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, ColorScheme colorScheme) {
    return base
        .copyWith(
          displayMedium: base.displayMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
          headlineLarge: base.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: base.bodyLarge?.copyWith(height: 1.35),
          bodyMedium: base.bodyMedium?.copyWith(height: 1.4),
          labelLarge: base.labelLarge?.copyWith(letterSpacing: 0.2),
        )
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );
  }
}
