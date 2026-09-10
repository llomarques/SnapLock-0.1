import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de Cores Oficial do Figma:
  // 5E3023 (Marrom Escuro), 3E3A36 (Grafite/Texto), 895737 (Marrom Médio), C08552 (Marrom Claro), F3E9DC (Creme/Bege Fundo)
  static const Color background = Color(0xFFF3E9DC);
  static const Color surface = Color(0xFFE6D7C3);
  static const Color surfaceLight = Color(0xFFEADCCE);
  
  static const Color darkBrown = Color(0xFF5E3023);
  static const Color mediumBrown = Color(0xFF895737);
  static const Color lightBrown = Color(0xFFC08552);

  static const Color textPrimary = Color(0xFF3E3A36);
  static const Color textSecondary = Color(0xFF6E6760);
  static const Color cardBorder = Color(0xFFD8C7B2);
  static const Color danger = Color(0xFFB33939);
  static const Color success = Color(0xFF218C74);

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme();
    final serifTheme = GoogleFonts.cormorantGaramondTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: darkBrown,
      colorScheme: const ColorScheme.light(
        primary: darkBrown,
        secondary: mediumBrown,
        tertiary: lightBrown,
        surface: surface,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: serifTheme.displayLarge?.copyWith(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium: serifTheme.displayMedium?.copyWith(color: textPrimary, fontWeight: FontWeight.bold),
        titleLarge: serifTheme.titleLarge?.copyWith(color: textPrimary, fontWeight: FontWeight.bold),
        titleMedium: serifTheme.titleMedium?.copyWith(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textPrimary),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textSecondary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shadowColor: darkBrown.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.cormorantGaramond(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
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
