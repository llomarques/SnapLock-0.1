import 'package:flutter/material.dart';
import 'package:snaplock/frontend/inicio_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
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
