import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:snaplock/frontend/pages/inicio_page.dart';
import 'package:snaplock/theme/app_theme.dart';
import 'package:snaplock/theme/app_theme_controller.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = AppThemeController.instance;
  await themeController.load();
  runApp(HelloWorldApp(themeController: themeController));
}

class HelloWorldApp extends StatelessWidget {
  const HelloWorldApp({super.key, required this.themeController});

  final AppThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          themeMode: themeController.isDark ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.lightTheme.copyWith(
            textTheme: GoogleFonts.poppinsTextTheme(),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: AppTheme.mediumBrown,
              contentTextStyle: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
              ),
              actionTextColor: AppTheme.darkThemeTextPrimary,
              behavior: SnackBarBehavior.floating,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: AppTheme.cardBorder),
              ),
            ),
          ),
          darkTheme: AppTheme.darkTheme.copyWith(
            snackBarTheme: SnackBarThemeData(
              backgroundColor: AppTheme.darkThemeSurfaceLight,
              contentTextStyle: GoogleFonts.poppins(
                color: AppTheme.darkThemeTextPrimary,
                fontSize: 14,
              ),
              actionTextColor: AppTheme.darkThemeLightBrown,
              behavior: SnackBarBehavior.floating,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppTheme.darkThemeCardBorder),
              ),
            ),
          ),
          home: const InicioPage(),
        );
      },
    );
  }
}
