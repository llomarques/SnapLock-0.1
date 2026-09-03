import 'package:flutter/material.dart';

import '../controller/controller.cadastrar.dart';

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
  final CadastroController cadastroController = CadastroController();

  bool esconderSenha = true;
  bool esconderAfirmacao = true;
  bool carregando = false;
  DateTime? dataNascimento;

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

    if (nome.isEmpty ||
        email.isEmpty ||
        senha.isEmpty ||
        confirmaSenha.isEmpty) {
      mostrarMensagem('Preencha todos os campos');
      return;
    }

    if (!email.contains('@')) {
      mostrarMensagem('Digite um e-mail válido');
      return;
    }

    if (dataNascimento == null) {
      mostrarMensagem('Selecione sua data de nascimento');
      return;
    }

    if (senha != confirmaSenha) {
      mostrarMensagem('As senhas não coincidem');
      return;
    }

    setState(() => carregando = true);
    try {
      await cadastroController.cadastrarUsuario(
        nome: nome,
        email: email,
        senha: senha,
        confirmacaoSenha: confirmaSenha,
        dataNascimento: dataNascimento!,
      );
      if (mounted) {
        mostrarMensagem('Usuário cadastrado com sucesso');
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) mostrarMensagem(error.toString());
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> selecionarData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: dataNascimento ?? DateTime(hoje.year - 16, hoje.month, hoje.day),
      firstDate: DateTime(1900),
      lastDate: hoje,
    );
    if (escolhida != null) setState(() => dataNascimento = escolhida);
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
      backgroundColor: Color(0xFFF3E9DC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/logo.png',
              width: 130,
              height: 130,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: nomeController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFD7CBBD),
                hintText: 'Digite seu nome',
                prefixIcon: const Icon(
                  Icons.person,
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
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: carregando ? null : selecionarData,
              icon: const Icon(Icons.cake_outlined),
              label: Text(dataNascimento == null
                  ? 'Selecione sua data de nascimento'
                  : 'Nascimento: ${dataNascimento!.day.toString().padLeft(2, '0')}/${dataNascimento!.month.toString().padLeft(2, '0')}/${dataNascimento!.year}'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFD7CBBD),
                hintText: 'Digite seu e-mail',
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
            const SizedBox(height: 15),
            TextField(
              controller: confirmaSenhaController,
              obscureText: esconderAfirmacao,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFD7CBBD),
                hintText: 'Confirme sua senha',
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
                      esconderAfirmacao = !esconderAfirmacao;
                    });
                  },
                  icon: Icon(
                    esconderAfirmacao ? Icons.visibility : Icons.visibility_off,
                    color: Color(0xFF5E3023),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: carregando ? null : cadastrar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF895737),
                foregroundColor: Colors.white,
              ),
                label: carregando
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Cadastrar', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 10),
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Já tenho uma conta',
                  style: TextStyle(
                    color: Color(0xFF895737),
                    fontWeight: FontWeight.bold, // Opcional: sublinha a palavra
                  ),
                  textAlign: TextAlign.center,
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
