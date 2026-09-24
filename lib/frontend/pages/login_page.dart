import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'cadastro_page.dart';
import 'esqueceuSenha_page.dart';
import 'feed_page.dart';
import '../../controller/controller.login.dart';
import 'package:snaplock/frontend/utils/mensagem_utils.dart';
import 'package:snaplock/frontend/widgets/inputSenha_widget.dart';
import 'package:snaplock/frontend/widgets/input_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController loginControllerTexto = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final LoginController loginController = LoginController();

  bool esconderSenha = true;
  bool carregando = false;

  Future<void> entrar() async {
    String login = loginControllerTexto.text.trim();
    String senha = senhaController.text;

    if (login.isEmpty || senha.isEmpty) {
      mostrarMensagem(
        context,
        'Preencha o e-mail/username e a senha.',
      );
      return;
    }

    setState(() => carregando = true);
    try {
      await loginController.entrar(login: login, senha: senha);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FeedPage()),
      );
    } catch (error) {
      if (mounted) mostrarMensagem(context, error.toString());
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  void abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CadastroPage()),
    );
  }

  void abrirEsqueceuSenha() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const esqueceuSenhaPage()),
    );
  }

  @override
  void dispose() {
    loginControllerTexto.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3E9DC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 250,
            ),
            const SizedBox(height: 20),
            InputWidget(
              controller: loginControllerTexto,
              texto: 'Digite seu e-mail ou usuário',
              icon: Icons.person,
            ),
            const SizedBox(
              height: 15,
            ),
            InputsenhaWidget(
							controller: senhaController,
							texto: 'Digite sua senha',
						),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  abrirEsqueceuSenha();
                },
                child: Text(
                  'Esqueceu a senha?',
                  style: TextStyle(
                    color: Color(0xFF895737),
                    fontWeight: FontWeight.w900
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            ElevatedButton.icon(
                onPressed: carregando ? null : entrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF895737),
                  foregroundColor: Color(0xFFF3E9DC),
                ),
                label: carregando
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Entrar')),
            const SizedBox(
              height: 10,
            ),
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  TextSpan(
                    text: 'Nao tem uma conta? ',
                  ),
                  TextSpan(
                    text: 'Cadastre-se',
                    style: TextStyle(
                      color: Color(0xFF895737),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        abrirCadastro();
                      },
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}