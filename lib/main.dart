import 'package:flutter/material.dart';
import 'package:snaplock/frontend/inicio_page.dart';
import 'package:snaplock/frontend/login_page.dart';

void main() {
	runApp(const HelloWorldApp());
}

class HelloWorldApp extends StatelessWidget {
	const HelloWorldApp({super.key});

	@override
	Widget build(BuildContext context) {
		return const MaterialApp(
      debugShowCheckedModeBanner: false,
			home: const InicioPage(),
		);
	}
}
