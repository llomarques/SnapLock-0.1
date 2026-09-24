import 'package:flutter/material.dart';
import 'package:snaplock/frontend/pages/inicio_page.dart';
import 'package:google_fonts/google_fonts.dart';

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
			theme: ThemeData(
				textTheme: GoogleFonts.poppinsTextTheme(),
			),
			home: const InicioPage(),
		);
	}
}
