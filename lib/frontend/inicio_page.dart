import 'package:flutter/material.dart';
import 'package:snaplock/frontend/login_page.dart';
import 'cadastro_page.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  void abrirCadastro(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CadastroPage()),
    );
  }

  void abrirLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC08552),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 300,
                height: 300,
              ),
            ),
            // const SizedBox(height: 9),
            const Text(
              'Seja bem-vindo!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E3A36),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              color: const Color(0xFFF4EFE9),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => abrirLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF895737),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Fazer Login'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => abrirCadastro(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF895737),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Criar conta'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}