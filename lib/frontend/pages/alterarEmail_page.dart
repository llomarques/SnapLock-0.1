import 'package:flutter/material.dart';
import 'package:snaplock/frontend/widgets/inputSenha_widget.dart';

class AlterarEmailPage extends StatefulWidget {
  const AlterarEmailPage({super.key});

  @override
  State<AlterarEmailPage> createState() => _AlterarEmailPageState();
}

class _AlterarEmailPageState extends State<AlterarEmailPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool carregando = false;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> enviarCodigo() async {
    if (emailController.text.trim().isEmpty || senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha email e senha.')),
      );
      return;
    }

    setState(() => carregando = true);
    try {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código enviado com sucesso.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E9DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3E9DC),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF5E3023),
          tooltip: 'Voltar',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 60),
            const Text(
              'Digite o seu novo email e sua senha',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF2F211C),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFD7CBBD),
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF5E3023)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: InputsenhaWidget(
                controller: senhaController,
                texto: 'Senha',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 205,
              child: ElevatedButton(
                onPressed: carregando ? null : enviarCodigo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF895737),
                  foregroundColor: const Color(0xFFF3E9DC),
                ),
                child: carregando
                    ? const CircularProgressIndicator()
                    : const Text('Enviar código'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
