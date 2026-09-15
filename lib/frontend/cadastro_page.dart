import 'package:flutter/material.dart';
import 'package:snaplock/frontend/personalizarPerfil_page.dart';
import 'package:snaplock/frontend/login_page.dart';

import '../controller/controller.cadastrar.dart';
import '../services/app_localizations.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
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
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String senha = senhaController.text;
    String confirmaSenha = confirmaSenhaController.text;

    if (nome.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        senha.isEmpty ||
        confirmaSenha.isEmpty) {
      mostrarMensagem(AppLocalizations.of(context).fillAllFields);
      return;
    }

    if (!email.contains('@')) {
      mostrarMensagem(AppLocalizations.of(context).invalidEmail);
      return;
    }

    if (dataNascimento == null) {
      mostrarMensagem(AppLocalizations.of(context).selectBirthdate);
      return;
    }

    if (senha != confirmaSenha) {
      mostrarMensagem(AppLocalizations.of(context).passwordsDoNotMatch);
      return;
    }

    setState(() => carregando = true);
    try {
      await cadastroController.cadastrarUsuario(
        nome: nome,
        username: username,
        email: email,
        senha: senha,
        confirmacaoSenha: confirmaSenha,
        dataNascimento: dataNascimento!,
      );
      if (mounted) {
        mostrarMensagem(AppLocalizations.of(context).accountCreated);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const personalizarPerfilPage(),
          ),
        );
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
      initialDate:
          dataNascimento ?? DateTime(hoje.year - 16, hoje.month, hoje.day),
      firstDate: DateTime(1900),
      lastDate: hoje,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF895737),
              onPrimary: Colors.white,
              surface: Color(0xFFF3E9DC),
              onSurface: Color(0xFF3E3A36),
            ),
          ),
          child: child!,
        );
      },
    );
    if (escolhida != null) setState(() => dataNascimento = escolhida);
  }

  @override
  void dispose() {
    nomeController.dispose();
    usernameController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmaSenhaController.dispose();
    super.dispose();
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
                hintText: AppLocalizations.of(context).typeName,
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
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFD7CBBD),
                hintText: AppLocalizations.of(context).typeUsername,
                prefixIcon:
                    const Icon(Icons.alternate_email, color: Color(0xFF5E3023)),
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
              readOnly: true,
              showCursor: false,
              onTap: carregando ? null : selecionarData,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFD7CBBD),
                hintText: dataNascimento == null
                    ? AppLocalizations.of(context).typeBirthdate
                    : '${AppLocalizations.of(context).birthdate}: ${dataNascimento!.day.toString().padLeft(2, '0')}/${dataNascimento!.month.toString().padLeft(2, '0')}/${dataNascimento!.year}',
                prefixIcon: const Icon(
                  Icons.cake,
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
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFD7CBBD),
                hintText: AppLocalizations.of(context).typeEmail,
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
                hintText: AppLocalizations.of(context).typePassword,
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
                hintText: AppLocalizations.of(context).confirmPassword,
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
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(AppLocalizations.of(context).register, style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 10),
            GestureDetector(
                onTap: () => abrirLogin(context),
                child: Text(
                  AppLocalizations.of(context).alreadyAccount,
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
