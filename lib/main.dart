import 'package:flutter/material.dart';
import 'package:snaplock/frontend/login_page.dart';

void main() {
	runApp(const SnapLockApp());
}

class SnapLockApp extends StatelessWidget {
	const SnapLockApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SnapLock',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true
      ),
      home: const LoginPage(),
    );
	}
}
