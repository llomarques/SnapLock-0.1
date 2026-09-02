import 'package:flutter/material.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmaSenhaController = TextEditingController();

  bool esconderSenha = true;
  bool esconderAfirmacao = true;

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> cadastrar() async {
    String nome = nomeController.text.trim();
    String email = emailController.text.trim();
    String senha = senhaController.text;
    String confirmaSenha = confirmaSenhaController.text;

    if (nome.isEmpty || email.isEmpty || senha.isEmpty || confirmaSenha.isEmpty) {
      mostrarMensagem('Preencha todos os campos');
      return;
    }

    if (!email.contains('@')) {
      mostrarMensagem('Digite um e-mail válido');
      return;
    }

    if (senha.length < 4) {
      mostrarMensagem('A senha deve ter no mínimo 4 caracteres');
      return;
    }

    if (senha != confirmaSenha) {
      mostrarMensagem('As senhas não coincidem');
      return;
    }

    // Aqui pode adicionar a lógica real de cadastro.
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmaSenhaController.dispose();
    super.dispose();
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
              'assets/images/logo.png',
              width: 150,
              height: 300,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFD7CBBD),
                hintText: 'Digite seu nome',
                prefixIcon: Icon(
                  Icons.person, 
                  color: Color(0xFF5E3023),
                  ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
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
            const SizedBox(height: 15),
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
                    esconderSenha ? Icons.visibility_off : Icons.visibility,
                    color: Color(0xFF5E3023),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: confirmaSenhaController,
              obscureText: esconderAfirmacao,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFD7CBBD),
                hintText: 'Confirme sua senha',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF5E3023),
                  ),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      esconderAfirmacao = !esconderAfirmacao;
                    });
                  },
                  icon: Icon(
                    esconderAfirmacao ? Icons.visibility_off : Icons.visibility,
                    color: Color(0xFF5E3023),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: cadastrar,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF895737),
                  foregroundColor: Colors.white,
                ),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Cadastrar', style: TextStyle(fontSize: 14)),
              
              
              ),
            
            const SizedBox(height: 10),
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Já tenho uma conta',
                )),
            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }
}