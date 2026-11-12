import 'package:flutter/material.dart';
import 'package:snaplock/theme/app_theme.dart';
import 'package:snaplock/frontend/widgets/logo_sobre_nos_widget.dart';
import 'package:snaplock/frontend/pages/login_page.dart';
import 'package:snaplock/screens/auth/confirm_signup_email_screen.dart';
import '../controller/controller.cadastrar.dart';

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
  bool emailEnviado = false;
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
      mostrarMensagem('Preencha todos os campos.');
      return;
    }

    if (!email.contains('@')) {
      mostrarMensagem('Digite um e-mail válido.');
      return;
    }

    if (dataNascimento == null) {
      mostrarMensagem('Selecione sua data de nascimento.');
      return;
    }

    if (senha != confirmaSenha) {
      mostrarMensagem('As senhas não coincidem.');
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
        senhaController.clear();
        confirmaSenhaController.clear();
        setState(() => emailEnviado = true);
        await abrirPaginaCodigo();
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
            colorScheme: ColorScheme.light(
              primary: AppTheme.mediumBrown,
              onPrimary: Colors.white,
              surface: const Color(0xFFF3E9DC),
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (escolhida != null) setState(() => dataNascimento = escolhida);
  }

  Future<void> abrirPaginaCodigo() async {
    final contaCriada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ConfirmSignupEmailScreen(email: emailController.text.trim()),
      ),
    );
    if (contaCriada == true && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const LogoSobreNosWidget(
              assetPath: 'assets/images/logo.png',
              width: 130,
              height: 130,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: nomeController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                hintText: 'Digite seu nome',
                prefixIcon: Icon(
                  Icons.person,
                  color: AppTheme.darkBrown,
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
                fillColor: AppTheme.surfaceLight,
                hintText: 'Digite seu username',
                prefixIcon:
                    Icon(Icons.alternate_email, color: AppTheme.darkBrown),
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
                fillColor: AppTheme.surfaceLight,
                hintText: dataNascimento == null
                    ? 'Digite sua data de nascimento'
                    : 'Nascimento: ${dataNascimento!.day.toString().padLeft(2, '0')}/${dataNascimento!.month.toString().padLeft(2, '0')}/${dataNascimento!.year}',
                prefixIcon: Icon(
                  Icons.cake,
                  color: Theme.of(context).colorScheme.primary,
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
                fillColor: AppTheme.surfaceLight,
                hintText: 'Digite seu e-mail',
                prefixIcon: Icon(
                  Icons.email,
                  color: AppTheme.darkBrown,
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
                fillColor: AppTheme.surfaceLight,
                hintText: 'Digite sua senha',
                prefixIcon: Icon(
                  Icons.lock,
                  color: AppTheme.darkBrown,
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
                      color: AppTheme.darkBrown,
                    )),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: confirmaSenhaController,
              obscureText: esconderAfirmacao,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceLight,
                hintText: 'Confirme sua senha',
                prefixIcon: Icon(
                  Icons.lock,
                  color: AppTheme.darkBrown,
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
                    color: AppTheme.darkBrown,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            if (emailEnviado)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enviamos um código para ${emailController.text.trim()}. '
                    'Confirme seu e-mail com o código para criar sua conta.',
                    style: TextStyle(color: AppTheme.textPrimary, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: carregando ? null : abrirPaginaCodigo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.mediumBrown,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Inserir código de confirmação'),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: carregando ? null : cadastrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mediumBrown,
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
                  'Já tenho uma conta',
                  style: TextStyle(
                    color: AppTheme.mediumBrown,
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
