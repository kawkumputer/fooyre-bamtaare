import 'package:flutter/material.dart';

/// Identite visuelle de Fooyre Ɓamtaare : vert profond (agriculture, Islam)
/// et or (savane, soleil) inspires des couleurs du drapeau mauritanien,
/// avec une touche terracotta reservee aux alertes (abonnement expirant).
class AppTheme {
  AppTheme._();

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0E6B3A),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFD3F0DD),
    onPrimaryContainer: Color(0xFF08361D),
    secondary: Color(0xFFAD7C0A),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFCE9BE),
    onSecondaryContainer: Color(0xFF4A3600),
    tertiary: Color(0xFFB4432D),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFFDAD1),
    onTertiaryContainer: Color(0xFF410F00),
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF7FBF6),
    onSurface: Color(0xFF191C1A),
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: Color(0xFFF1F5EF),
    surfaceContainer: Color(0xFFEBEFE9),
    surfaceContainerHigh: Color(0xFFE5E9E3),
    surfaceContainerHighest: Color(0xFFDFE4DD),
    outline: Color(0xFF74796F),
    outlineVariant: Color(0xFFC3C8BD),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF8FD9A8),
    onPrimary: Color(0xFF00391B),
    primaryContainer: Color(0xFF0E6B3A),
    onPrimaryContainer: Color(0xFFD3F0DD),
    secondary: Color(0xFFE9C46A),
    onSecondary: Color(0xFF3F2E00),
    secondaryContainer: Color(0xFF5C4300),
    onSecondaryContainer: Color(0xFFFCE9BE),
    tertiary: Color(0xFFFFB4A0),
    onTertiary: Color(0xFF5F1600),
    tertiaryContainer: Color(0xFF7D2C13),
    onTertiaryContainer: Color(0xFFFFDAD1),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF10140F),
    onSurface: Color(0xFFE1E3DD),
    surfaceContainerLowest: Color(0xFF0B0F0A),
    surfaceContainerLow: Color(0xFF181C17),
    surfaceContainer: Color(0xFF1C201B),
    surfaceContainerHigh: Color(0xFF272B25),
    surfaceContainerHighest: Color(0xFF323630),
    outline: Color(0xFF8F9389),
    outlineVariant: Color(0xFF404940),
  );

  static ThemeData light() => _build(_lightScheme);
  static ThemeData dark() => _build(_darkScheme);

  static ThemeData _build(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
