import 'package:flutter/material.dart';
import 'package:snaplock/frontend/login_page.dart';
import 'cadastro_page.dart';
import 'package:snaplock/frontend/carrossel.dart';
import 'package:snaplock/theme/app_fonts.dart';

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
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: 43),
            Text(
              'Seja bem-vindo!',
              textAlign: TextAlign.center,
              style: AppFonts.cormorantBold.copyWith(
                fontSize: 24,
                color: Color(0xFF3E3A36),
                fontWeight: FontWeight.w800
              ),
            ),
            const CarrosselDeInformacoes(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 77),
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
