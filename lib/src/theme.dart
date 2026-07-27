import 'package:flutter/material.dart';

abstract final class GuardianColors {
  static const lightPrimary = Color(0xFF1A1A1A);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceContainer = Color(0xFFF3F3F3);
  static const lightOutline = Color(0xFFD1D1D1);
  static const lightInk = Color(0xFF1A1A1A);
  static const lightMuted = Color(0xFF666666);
  static const lightSecondary = Color(0xFF4A4A4A);

  static const darkPrimary = Color(0xFFF2F2F2);
  static const darkOnPrimary = Color(0xFF121212);
  static const darkSurface = Color(0xFF121212);
  static const darkSurfaceContainer = Color(0xFF202020);
  static const darkOutline = Color(0xFF494949);
  static const darkInk = Color(0xFFF2F2F2);
  static const darkMuted = Color(0xFFB3B3B3);
  static const darkSecondary = Color(0xFFD0D0D0);
}

abstract final class GuardianTheme {
  static ThemeData light() => _theme(
    brightness: Brightness.light,
    primary: GuardianColors.lightPrimary,
    onPrimary: GuardianColors.lightOnPrimary,
    surface: Colors.white,
    surfaceContainer: GuardianColors.lightSurfaceContainer,
    outline: GuardianColors.lightOutline,
    ink: GuardianColors.lightInk,
    muted: GuardianColors.lightMuted,
    secondary: GuardianColors.lightSecondary,
  );

  static ThemeData dark() => _theme(
    brightness: Brightness.dark,
    primary: GuardianColors.darkPrimary,
    onPrimary: GuardianColors.darkOnPrimary,
    surface: GuardianColors.darkSurface,
    surfaceContainer: GuardianColors.darkSurfaceContainer,
    outline: GuardianColors.darkOutline,
    ink: GuardianColors.darkInk,
    muted: GuardianColors.darkMuted,
    secondary: GuardianColors.darkSecondary,
  );

  static ThemeData _theme({
    required Brightness brightness,
    required Color primary,
    required Color onPrimary,
    required Color surface,
    required Color surfaceContainer,
    required Color outline,
    required Color ink,
    required Color muted,
    required Color secondary,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: brightness == Brightness.light
          ? Colors.white
          : const Color(0xFF121212),
      error: brightness == Brightness.light
          ? const Color(0xFFB3261E)
          : const Color(0xFFFFB4AB),
      onError: brightness == Brightness.light
          ? Colors.white
          : const Color(0xFF690005),
      surface: surface,
      onSurface: ink,
      surfaceContainer: surfaceContainer,
      onSurfaceVariant: muted,
      outline: outline,
      outlineVariant: outline.withValues(alpha: 0.55),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: ink,
      onInverseSurface: surface,
      inversePrimary: primary,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontSize: 28,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontSize: 20,
          height: 1.3,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          height: 1.45,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: outline.withValues(alpha: 0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surfaceContainer,
        indicatorColor: primary.withValues(alpha: 0.15),
        selectedIconTheme: IconThemeData(color: primary),
        selectedLabelTextStyle: TextStyle(
          color: ink,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(color: muted),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: surfaceContainer,
        indicatorColor: primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected) ? ink : muted,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: outline.withValues(alpha: 0.65),
        thickness: 1,
      ),
    );
  }
}
