import 'package:flutter/material.dart';

import '../controller/controller.cadastrar.dart';

class AlterarSenhaPage extends StatefulWidget {
  final String email;
  final String token;

  const AlterarSenhaPage({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<AlterarSenhaPage> createState() => _AlterarSenhaPageState();
}

class _AlterarSenhaPageState extends State<AlterarSenhaPage> {
  final TextEditingController novaSenhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();
  final CadastroController cadastroController = CadastroController();
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
        mostrarMensagem('Senha alterada com sucesso.');
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
      appBar: AppBar(
        title: const Text('Alterar Senha'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: novaSenhaController,
              decoration: const InputDecoration(labelText: 'Nova Senha'),
              obscureText: true,
            ),
            TextField(
              controller: confirmarSenhaController,
              decoration:
                  const InputDecoration(labelText: 'Confirmar Nova Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: carregando ? null : alterarSenha,
              child: carregando
                  ? const CircularProgressIndicator()
                  : const Text('Alterar Senha'),
            ),
          ],
        ),
      ),
    );
  }
}