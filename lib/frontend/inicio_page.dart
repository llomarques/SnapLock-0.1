import 'package:flutter/material.dart';
import 'package:snaplock/frontend/login_page.dart';
import 'cadastro_page.dart';
import 'package:snaplock/frontend/carrossel.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Seja bem-vindo!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E3A36),
              ),
            ),
            const CarrosselDeInformacoes(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 65),
              decoration: BoxDecoration(
                color: Color(0xFFF3E9DC),
                borderRadius: BorderRadius.circular(27),
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => abrirLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF895737),
                      foregroundColor: Color(0xFFF3E9DC),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Fazer Login'),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: () => abrirCadastro(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF895737),
                      foregroundColor: Color(0xFFF3E9DC),
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
