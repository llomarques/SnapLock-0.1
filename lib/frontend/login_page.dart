import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'cadastro_page.dart';
import 'esqueceuSenha_page.dart';
import 'feed_page.dart';
import '../controller/controller.login.dart';

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
  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> entrar() async {
    String login = loginControllerTexto.text.trim();
    String senha = senhaController.text;

    if (login.isEmpty || senha.isEmpty) {
      mostrarMensagem(
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
      if (mounted) mostrarMensagem(error.toString());
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
            TextField(
              controller: loginControllerTexto,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFD7CBBD),
                hintText: 'Digite seu e-mail ou usuário',
                prefixIcon: const Icon(
                  Icons.email,
                  color: Color(0xFF5E3023),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              controller: senhaController,
              obscureText: esconderSenha,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFD7CBBD),
                hintText: 'Digite sua senha',
                prefixIcon: const Icon(
                  Icons.lock,
                  color: Color(0xFF5E3023),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        esconderSenha = !esconderSenha;
                      });
                    },
                    icon: Icon(
                      esconderSenha ? Icons.visibility : Icons.visibility_off,
                      color: Color(0xFF5E3023),
                    )),
              ),
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
                child: const Text(
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
                    text: 'Não tem uma conta? ',
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