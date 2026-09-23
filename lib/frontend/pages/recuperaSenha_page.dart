import 'package:flutter/material.dart';

import '../../controller/controller.cadastrar.dart';
import '../../services/app_localizations.dart';

class RecuperaSenhaPage extends StatefulWidget {
  final String email;
  final String token;

  const RecuperaSenhaPage({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<RecuperaSenhaPage> createState() => _RecuperaSenhaPageState();
}

class _RecuperaSenhaPageState extends State<RecuperaSenhaPage> {
  final TextEditingController novaSenhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();
  final CadastroController cadastroController = CadastroController();
  bool esconderNovaSenha = true;
  bool esconderConfirmarSenha = true;
  bool carregando = false;

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> alterarSenha() async {
    setState(() => carregando = true);
    try {
      await cadastroController.redefinirSenha(
        email: widget.email,
        token: widget.token,
        novaSenha: novaSenhaController.text,
        confirmacaoSenha: confirmarSenhaController.text,
      );
      if (mounted) {
        mostrarMensagem(AppLocalizations.of(context).passwordChanged);
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (error) {
      if (mounted) mostrarMensagem(error.toString());
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  void dispose() {
    novaSenhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3E9DC),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 60),
            TextField(
              controller: novaSenhaController,
              obscureText: esconderNovaSenha,
              decoration: _decoracaoSenha(
                AppLocalizations.of(context).newPassword,
                esconderNovaSenha,
                () => setState(() => esconderNovaSenha = !esconderNovaSenha),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmarSenhaController,
              obscureText: esconderConfirmarSenha,
              decoration: _decoracaoSenha(
                AppLocalizations.of(context).confirmPassword,
                esconderConfirmarSenha,
                () => setState(
                  () => esconderConfirmarSenha = !esconderConfirmarSenha,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: carregando ? null : alterarSenha,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF895737),
                foregroundColor: Color(0xFFF3E9DC),
              ),
              child: carregando
                  ? const CircularProgressIndicator()
                  : Text(AppLocalizations.of(context).changePassword),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoracaoSenha(
    String texto,
    bool esconderSenha,
    VoidCallback alternarVisibilidade,
  ) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFD7CBBD),
      hintText: texto,
      prefixIcon: const Icon(Icons.lock, color: Color(0xFF5E3023)),
      suffixIcon: IconButton(
        onPressed: alternarVisibilidade,
        icon: Icon(
          esconderSenha ? Icons.visibility : Icons.visibility_off,
          color: const Color(0xFF5E3023),
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}