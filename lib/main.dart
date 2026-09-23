import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:snaplock/frontend/pages/inicio_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snaplock/services/app_localizations.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	runApp(const HelloWorldApp());
}

class HelloWorldApp extends StatelessWidget {
	const HelloWorldApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			debugShowCheckedModeBanner: false,
			locale: const Locale('pt', 'BR'),
			supportedLocales: const [
				Locale('pt', 'BR'),
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
		);
	}
}
