import 'package:flutter/material.dart';
import 'package:snaplock/frontend/pages/personalizarPerfil_page.dart';
import 'package:snaplock/frontend/pages/login_page.dart';
import 'package:snaplock/frontend/utils/mensagem_utils.dart';
import '../../controller/controller.cadastrar.dart';
import '../../controller/controller.login.dart';
import 'package:snaplock/frontend/widgets/inputSenha_widget.dart';

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
      mostrarMensagem(context, 'Preencha todos os campos');
      return;
    }

    if (!email.contains('@')) {
      mostrarMensagem(context, 'Digite um e-mail valido');
      return;
    }

    if (dataNascimento == null) {
      mostrarMensagem(context, 'Selecione sua data de nascimento');
      return;
    }

    if (senha != confirmaSenha) {
      mostrarMensagem(context, 'As senhas nao coincidem.');
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
      await LoginController().entrar(login: email, senha: senha);
      if (mounted) {
        mostrarMensagem(context, 'Usuario cadastrado com sucesso');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const personalizarPerfilPage(),
          ),
        );
      }
    } catch (error) {
      if (mounted) mostrarMensagem(context, error.toString());
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
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFD7CBBD),
                hintText: 'Digite seu username',
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
                    ? 'Digite sua data de nascimento'
                    : '${dataNascimento!.day.toString().padLeft(2, '0')}/${dataNascimento!.month.toString().padLeft(2, '0')}/${dataNascimento!.year}',
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
            InputsenhaWidget(
							controller: senhaController,
							texto: 'Digite sua senha',
						),
            const SizedBox(height: 15),
            InputsenhaWidget(
							controller: confirmaSenhaController,
							texto: 'Confirme sua senha',
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
                  : const Text('Cadastrar', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 10),
            GestureDetector(
                onTap: () => abrirLogin(context),
                child: Text(
                  'Ja tenho uma conta',
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
