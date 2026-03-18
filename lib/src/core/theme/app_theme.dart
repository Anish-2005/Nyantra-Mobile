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
      primary: Color(0xFF155EEF),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDCE7FF),
      onPrimaryContainer: Color(0xFF001A4A),
      secondary: Color(0xFF0E9384),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD6F5EF),
      onSecondaryContainer: Color(0xFF022D2A),
      tertiary: Color(0xFF1D4ED8),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFDDE7FF),
      onTertiaryContainer: Color(0xFF0D1B42),
      error: Color(0xFFB42318),
      onError: Colors.white,
      errorContainer: Color(0xFFFEE4E2),
      onErrorContainer: Color(0xFF5E1912),
      surface: Color(0xFFF5F7FF),
      onSurface: Color(0xFF111827),
      onSurfaceVariant: Color(0xFF475467),
      outline: Color(0xFFD0D5DD),
      outlineVariant: Color(0xFFE4E7EC),
      shadow: Color(0x0F101828),
      scrim: Color(0x66101828),
      inverseSurface: Color(0xFF1D2939),
      onInverseSurface: Color(0xFFF9FAFB),
      inversePrimary: Color(0xFF7EA7FF),
    ),
    tokens: const AppThemeTokens(
      brandStart: Color(0xFF155EEF),
      brandEnd: Color(0xFF0E9384),
      backgroundStart: Color(0xFFF8FAFF),
      backgroundMid: Color(0xFFEFF4FF),
      backgroundEnd: Color(0xFFE9F7F5),
      surfaceBase: Color(0xFFF5F7FF),
      surfaceRaised: Color(0xFFFFFFFF),
      surfaceMuted: Color(0xFFF2F4F7),
      borderSubtle: Color(0xFFE4E7EC),
      borderStrong: Color(0xFFD0D5DD),
      shadowSoft: Color(0x1A0F172A),
      online: Color(0xFF087443),
      offline: Color(0xFFB42318),
      success: Color(0xFF087443),
      warning: Color(0xFFB54708),
      danger: Color(0xFFB42318),
    ),
  );

  static ThemeData dark() => _buildTheme(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF78A7FF),
      onPrimary: Color(0xFF071534),
      primaryContainer: Color(0xFF153A86),
      onPrimaryContainer: Color(0xFFD8E6FF),
      secondary: Color(0xFF53D2C5),
      onSecondary: Color(0xFF042523),
      secondaryContainer: Color(0xFF12534C),
      onSecondaryContainer: Color(0xFFB8F2EA),
      tertiary: Color(0xFF9AC5FF),
      onTertiary: Color(0xFF0A1C3D),
      tertiaryContainer: Color(0xFF1D3F78),
      onTertiaryContainer: Color(0xFFDEEAFF),
      error: Color(0xFFF97066),
      onError: Color(0xFF460D09),
      errorContainer: Color(0xFF7A271A),
      onErrorContainer: Color(0xFFFEE4E2),
      surface: Color(0xFF0B1220),
      onSurface: Color(0xFFE4E7EC),
      onSurfaceVariant: Color(0xFF98A2B3),
      outline: Color(0xFF344054),
      outlineVariant: Color(0xFF1D2939),
      shadow: Color(0x70000000),
      scrim: Color(0x9F000000),
      inverseSurface: Color(0xFFE4E7EC),
      onInverseSurface: Color(0xFF111827),
      inversePrimary: Color(0xFF155EEF),
    ),
    tokens: const AppThemeTokens(
      brandStart: Color(0xFF78A7FF),
      brandEnd: Color(0xFF53D2C5),
      backgroundStart: Color(0xFF050914),
      backgroundMid: Color(0xFF0A162B),
      backgroundEnd: Color(0xFF062325),
      surfaceBase: Color(0xFF0B1220),
      surfaceRaised: Color(0xFF101828),
      surfaceMuted: Color(0xFF1D2939),
      borderSubtle: Color(0xFF1D2939),
      borderStrong: Color(0xFF344054),
      shadowSoft: Color(0x66000000),
      online: Color(0xFF6CE9B8),
      offline: Color(0xFFFDA29B),
      success: Color(0xFF6CE9B8),
      warning: Color(0xFFFEC84B),
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
      scaffoldBackgroundColor: tokens.surfaceBase,
      canvasColor: tokens.surfaceBase,
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
      cardTheme: CardTheme(
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
      dialogTheme: DialogTheme(
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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surfaceRaised.withValues(alpha: isDark ? 0.78 : 0.94),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
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
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

