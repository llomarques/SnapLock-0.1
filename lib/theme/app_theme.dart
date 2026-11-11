import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de Cores Oficial do Figma:
  // 5E3023 (Marrom Escuro), 3E3A36 (Grafite/Texto), 895737 (Marrom Médio), C08552 (Marrom Claro), F3E9DC (Creme/Bege Fundo)
  static const Color _lightBackground = Color(0xFFF3E9DC);
  static const Color _lightSurface = Color(0xFFE6D7C3);
  static const Color _lightSurfaceLight = Color(0xFFEADCCE);

  static const Color _lightDarkBrown = Color(0xFF5E3023);
  static const Color _lightMediumBrown = Color(0xFF895737);
  static const Color _lightBrown = Color(0xFFC08552);

  static const Color _lightTextPrimary = Color(0xFF3E3A36);
  static const Color _lightTextSecondary = Color(0xFF6E6760);
  static const Color _lightCardBorder = Color(0xFFD8C7B2);
  static const Color _lightDanger = Color(0xFFB33939);
  static const Color _lightSuccess = Color(0xFF218C74);

  static bool _darkModeEnabled = false;

  static void setDarkMode(bool enabled) => _darkModeEnabled = enabled;

  static Color get background =>
      _darkModeEnabled ? darkThemeBackground : _lightBackground;
  static Color get surface =>
      _darkModeEnabled ? darkThemeSurface : _lightSurface;
  static Color get surfaceLight =>
      _darkModeEnabled ? darkThemeSurfaceLight : _lightSurfaceLight;
  static Color get darkBrown =>
      _darkModeEnabled ? darkThemeBrown : _lightDarkBrown;
  static Color get mediumBrown =>
      _darkModeEnabled ? darkThemeMediumBrown : _lightMediumBrown;
  static Color get lightBrown =>
      _darkModeEnabled ? darkThemeLightBrown : _lightBrown;
  static Color get textPrimary =>
      _darkModeEnabled ? darkThemeTextPrimary : _lightTextPrimary;
  static Color get textSecondary =>
      _darkModeEnabled ? darkThemeTextSecondary : _lightTextSecondary;
  static Color get cardBorder =>
      _darkModeEnabled ? darkThemeCardBorder : _lightCardBorder;
  static Color get danger => _darkModeEnabled ? darkThemeDanger : _lightDanger;
  static Color get success =>
      _darkModeEnabled ? darkThemeSuccess : _lightSuccess;

  static const Color darkThemeBackground = Color(0xFF211B18);
  static const Color darkThemeSurface = Color(0xFF302722);
  static const Color darkThemeSurfaceLight = Color(0xFF44372F);
  static const Color darkThemeBrown = Color(0xFFA87550);
  static const Color darkThemeMediumBrown = Color(0xFFA87550);
  static const Color darkThemeLightBrown = Color(0xFFA87550);
  static const Color darkThemeTextPrimary = Color(0xFFF2E8DC);
  static const Color darkThemeTextSecondary = Color(0xFFC2A58D);
  static const Color darkThemeCardBorder = Color(0xFF514238);
  static const Color darkThemeDanger = Color(0xFFE05A55);
  static const Color darkThemeSuccess = Color(0xFF42A88A);

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme();
    final serifTheme = GoogleFonts.cormorantGaramondTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _lightBackground,
      primaryColor: _lightDarkBrown,
      colorScheme: const ColorScheme.light(
        primary: _lightDarkBrown,
        secondary: _lightMediumBrown,
        tertiary: _lightBrown,
        surface: _lightSurface,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: serifTheme.displayLarge
            ?.copyWith(color: _lightTextPrimary, fontWeight: FontWeight.bold),
        displayMedium: serifTheme.displayMedium
            ?.copyWith(color: _lightTextPrimary, fontWeight: FontWeight.bold),
        titleLarge: serifTheme.titleLarge
            ?.copyWith(color: _lightTextPrimary, fontWeight: FontWeight.bold),
        titleMedium: serifTheme.titleMedium
            ?.copyWith(color: _lightTextPrimary, fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: _lightTextPrimary),
        bodyMedium:
            baseTextTheme.bodyMedium?.copyWith(color: _lightTextSecondary),
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 2,
        shadowColor: _lightDarkBrown.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: _lightCardBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _lightBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _lightTextPrimary),
        titleTextStyle: GoogleFonts.cormorantGaramond(
          color: _lightTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _lightBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: _lightCardBorder, width: 1),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme =
        GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);
    final serifTheme = GoogleFonts.cormorantGaramondTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkThemeBackground,
      primaryColor: darkThemeMediumBrown,
      colorScheme: const ColorScheme.dark(
        primary: darkThemeMediumBrown,
        onPrimary: darkThemeBackground,
        secondary: darkThemeLightBrown,
        tertiary: darkThemeBrown,
        surface: darkThemeSurface,
        surfaceContainerHighest: darkThemeSurfaceLight,
        onSurface: darkThemeTextPrimary,
        onSurfaceVariant: darkThemeTextSecondary,
        outlineVariant: darkThemeCardBorder,
        error: darkThemeDanger,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: serifTheme.displayLarge?.copyWith(
          color: darkThemeTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: serifTheme.displayMedium?.copyWith(
          color: darkThemeTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: serifTheme.titleLarge?.copyWith(
          color: darkThemeTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: serifTheme.titleMedium?.copyWith(
          color: darkThemeTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge:
            baseTextTheme.bodyLarge?.copyWith(color: darkThemeTextPrimary),
        bodyMedium:
            baseTextTheme.bodyMedium?.copyWith(color: darkThemeTextSecondary),
      ),
      cardTheme: CardThemeData(
        color: darkThemeSurface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: darkThemeCardBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkThemeBackground,
        foregroundColor: darkThemeTextPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkThemeTextPrimary),
        titleTextStyle: GoogleFonts.cormorantGaramond(
          color: darkThemeTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkThemeSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: darkThemeCardBorder, width: 1),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: darkThemeTextPrimary,
        iconColor: darkThemeLightBrown,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkThemeSurfaceLight,
        labelStyle: const TextStyle(color: darkThemeTextSecondary),
        hintStyle: const TextStyle(color: darkThemeTextSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkThemeCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkThemeLightBrown, width: 1.5),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: darkThemeSurface,
        indicatorColor: Colors.transparent,
      ),
    );
  }

  static TextStyle get brandingTitleStyle {
    return GoogleFonts.cormorantGaramond(
      color: textPrimary,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    );
  }

  static TextStyle get brandingSubtitleStyle {
    return GoogleFonts.cormorantGaramond(
      color: textSecondary,
      fontSize: 14,
      fontStyle: FontStyle.italic,
      letterSpacing: 2,
    );
  }
}
