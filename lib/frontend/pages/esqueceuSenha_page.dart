import 'package:flutter/material.dart';
import 'package:snaplock/theme/app_fonts.dart';
import '../../controller/controller.cadastrar.dart';
import 'recuperaSenha_page.dart';
import 'package:snaplock/frontend/utils/mensagem_utils.dart';

class esqueceuSenhaPage extends StatefulWidget {
  const esqueceuSenhaPage({super.key});

  @override
  State<esqueceuSenhaPage> createState() => _esqueceuSenhaPage();
}

class _esqueceuSenhaPage extends State<esqueceuSenhaPage> {
  final TextEditingController confirmaEmailController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final CadastroController cadastroController = CadastroController();
  bool carregando = false;
  bool tokenEnviado = false;

  @override
  void dispose() {
    confirmaEmailController.dispose();
    tokenController.dispose();
    super.dispose();
  }

  Future<void> solicitarToken() async {
    final email = confirmaEmailController.text.trim();
    if (email.isEmpty) {
      mostrarMensagem(context, 'Digite seu e-mail');
      return;
    }
    setState(() => carregando = true);
    try {
      await cadastroController.solicitarToken(email);
      if (mounted) {
        setState(() => tokenEnviado = true);
        mostrarMensagem(context, 'Confira seu e-mail e a pasta Spam.');
      }
    } catch (error) {
      if (mounted) mostrarMensagem(context, error.toString());
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> validarToken() async {
    final email = confirmaEmailController.text.trim();
    final token = tokenController.text.trim();
    if (token.length != 6) {
      mostrarMensagem(context, 'Digite o codigo de 6 numeros recebido por e-mail.');
      return;
    }
    setState(() => carregando = true);
    try {
      await cadastroController.validarToken(email: email, token: token);
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecuperaSenhaPage(email: email, token: token),
          ),
        );
      }
    } catch (error) {
      if (mounted) mostrarMensagem(context, error.toString());
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E9DC),
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
            const SizedBox(height: 37),
            Text(
              'Digite seu e-mail para receber o link de recuperacao',
              textAlign: TextAlign.center,
              style: AppFonts.poppinsRegular.copyWith(
                fontSize: 12.5,
                color: Color(0xFF3E3A36),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmaEmailController,
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
            const SizedBox(
              height: 20,
            ),
            if (!tokenEnviado)
              ElevatedButton(
                onPressed: carregando ? null : solicitarToken,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF895737),
                  foregroundColor: const Color(0xFFF3E9DC),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: carregando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enviar codigo'),
              ),
            if (tokenEnviado) ...[
              Text(
                'Digite o codigo de 6 numeros enviado para seu e-mail',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tokenController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFD7CBBD),
                  hintText: 'Codigo de 6 numeros',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: carregando ? null : validarToken,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF895737),
                  foregroundColor: const Color(0xFFF3E9DC),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: carregando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Validar token'),
              ),
            ],
            const SizedBox(height: 10),
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Voltar para o login',
                  style: TextStyle(
                    color: Color(0xFF895737),
                    fontWeight: FontWeight.bold, // Opcional: sublinha a palavra
                  ),
                  textAlign: TextAlign.center,
                )),
          ],
        ),
      ),
    );
  }
}