import 'package:flutter/material.dart';
import 'package:snaplock/frontend/pages/login_page.dart';
import 'cadastro_page.dart';
import 'package:snaplock/frontend/utils/carrossel.dart';
import 'package:snaplock/theme/app_fonts.dart';
import 'package:snaplock/frontend/widgets/botoes_widget.dart';

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
              'Bem-vindo!',
              textAlign: TextAlign.center,
              style: AppFonts.cormorantBold.copyWith(
                fontSize: 24,
                color: Color(0xFF3E3A36),
                fontWeight: FontWeight.w800
              ),
            ),
            const CarrosselDeInformacoes(),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 59),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E9DC),
                borderRadius: BorderRadius.circular(27),
              ),
              child: Transform.translate(
                offset: const Offset(0, -28),
                child: Column(
                  children: [
                    BotoesWidget(
                      texto: 'Fazer Login',
                      aoTocar: () => abrirLogin(context),
                    ),
                    const SizedBox(height: 22),
                    BotoesWidget(
                      texto: 'Criar Conta',
                      aoTocar: () => abrirCadastro(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}