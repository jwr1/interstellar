import 'package:flutter/material.dart';

class ThemeInfo {
  ThemeInfo(this.name, {this.lightMode, this.darkMode});

  final String name;
  ColorScheme? lightMode = const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF6750A4),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFEADDFF),
    onPrimaryContainer: Color(0xFF21005D),
    secondary: Color(0xFF625B71),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE8DEF8),
    onSecondaryContainer: Color(0xFF1D192B),
    tertiary: Color(0xFF7D5260),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFD8E4),
    onTertiaryContainer: Color(0xFF31111D),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    surface: Color(0xFFFFFBFE),
    onSurface: Color(0xFF1C1B1F),
    surfaceContainerHighest: Color(0xFFE7E0EC),
    onSurfaceVariant: Color(0xFF49454F),
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFCAC4D0),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF313033),
    onInverseSurface: Color(0xFFF4EFF4),
    inversePrimary: Color(0xFFD0BCFF),
    // The surfaceTint color is set to the same color as the primary.
    surfaceTint: Color(0xFF6750A4),
  );
  ColorScheme? darkMode = const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFD0BCFF),
    onPrimary: Color(0xFF381E72),
    primaryContainer: Color(0xFF4F378B),
    onPrimaryContainer: Color(0xFFEADDFF),
    secondary: Color(0xFFCCC2DC),
    onSecondary: Color(0xFF332D41),
    secondaryContainer: Color(0xFF4A4458),
    onSecondaryContainer: Color(0xFFE8DEF8),
    tertiary: Color(0xFFEFB8C8),
    onTertiary: Color(0xFF492532),
    tertiaryContainer: Color(0xFF633B48),
    onTertiaryContainer: Color(0xFFFFD8E4),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    errorContainer: Color(0xFF8C1D18),
    onErrorContainer: Color(0xFFF9DEDC),
    surface: Color(0xFF1C1B1F),
    onSurface: Color(0xFFE6E1E5),
    surfaceContainerHighest: Color(0xFF49454F),
    onSurfaceVariant: Color(0xFFCAC4D0),
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF49454F),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE6E1E5),
    onInverseSurface: Color(0xFF313033),
    inversePrimary: Color(0xFF6750A4),
    // The surfaceTint color is set to the same color as the primary.
    surfaceTint: Color(0xFFD0BCFF),
  );
}

final List<ThemeInfo> themes = [
  ThemeInfo('Default'),
  ThemeInfo('Cappuccino',
      lightMode: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFFDCE0E8),
        onPrimary: Color(0xFF8839EF),
        secondary: Color(0xFFE6E9EF),
        onSecondary: Color(0xFFEA76CB),
        error: Color(0xFFACB0BE),
        onError: Color(0xFFD20F39),
        surface: Color(0xFFCCD0DA),
        onSurface: Color(0xFF4C4F69),
      ),
      darkMode: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFCBA6F7),
        onPrimary: Color(0xFFCDD6F4),
        secondary: Color(0xFF181825),
        onSecondary: Color(0xFFF5C2E7),
        error: Color(0xFF585B70),
        onError: Color(0xFFF38BA8),
        surface: Color(0xFF313244),
        onSurface: Color(0xFFCDD6F4),
      )),
  ThemeInfo(
    'Blue',
    lightMode: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue, backgroundColor: const Color(0xFFFFFBFE)),
    darkMode: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
      backgroundColor: const Color(0xFF1C1B1F),
      brightness: Brightness.dark,
    ),
  ),
  ThemeInfo(
    'Purple',
    lightMode: ColorScheme.fromSwatch(
      primarySwatch: Colors.purple,
    ),
    darkMode: ColorScheme.fromSwatch(
      primarySwatch: Colors.purple,
      brightness: Brightness.dark,
    ),
  ),
  ThemeInfo(
    'Red',
    lightMode: ColorScheme.fromSwatch(
      primarySwatch: Colors.red,
    ),
    darkMode: ColorScheme.fromSwatch(
      primarySwatch: Colors.red,
      brightness: Brightness.dark,
    ),
  ),
  ThemeInfo(
    'Amber',
    lightMode: ColorScheme.fromSwatch(
      primarySwatch: Colors.amber,
    ),
    darkMode: ColorScheme.fromSwatch(
      primarySwatch: Colors.amber,
      brightness: Brightness.dark,
    ),
  ),
];
