import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:snaplock/frontend/inicio_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snaplock/services/app_language.dart';
import 'package:snaplock/services/app_localizations.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await appLanguage.load();
	runApp(const HelloWorldApp());
}

class HelloWorldApp extends StatelessWidget {
	const HelloWorldApp({super.key});

	@override
	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: appLanguage,
			builder: (context, child) => MaterialApp(
				debugShowCheckedModeBanner: false,
				locale: appLanguage.locale,
				supportedLocales: const [
					Locale('pt', 'BR'),
					Locale('en'),
					Locale('es'),
				],
				localizationsDelegates: const [
					AppLocalizations.delegate,
					GlobalMaterialLocalizations.delegate,
					GlobalWidgetsLocalizations.delegate,
					GlobalCupertinoLocalizations.delegate,
				],
				theme: ThemeData(
					textTheme: GoogleFonts.poppinsTextTheme(),
				),
				home: const InicioPage(),
			),
		);
	}
}
