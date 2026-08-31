import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool esconderSenha = true;
  bool carregando = false;
  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> entrar() async {
    String email = emailController.text.trim();
    String senha = senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      mostrarMensagem(
        'Preencha o e-mail e a senha.',
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EFE9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/Logo.png',
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFD7CBBD),
                hintText: 'Digite seu e-mail',
                prefixIcon: Icon(
                  Icons.email,
                  color: Color(0xFF5E3023),
                ),
                border: OutlineInputBorder(),
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
                border: const OutlineInputBorder(),
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
            GestureDetector(
                onTap: () {},
                child: Text(
                  'Esqueceu a senha?',
                )),
            const SizedBox(
              height: 25,
            ),
            ElevatedButton.icon(
                onPressed: entrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF895737),
                  foregroundColor: Colors.white,
                ),
                icon: carregando
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.login),
                label: const Text('Entrar')),
            const SizedBox(
              height: 10,
            ),
            RichText(
              text: TextSpan(
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16), // Estilo para todo o texto
                children: [
                  TextSpan(
                    text: 'Não tem uma conta? ',
                  ),
                  TextSpan(
                    text: 'Cadastre-se',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration
                          .underline, // Opcional: sublinha a palavra
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Ação específica para o clique em "Cadastre-se"
                        print('Ir para a tela de cadastro!');
                      },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
