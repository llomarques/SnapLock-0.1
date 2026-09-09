import 'package:flutter/material.dart';
import 'package:snaplock/theme/app_fonts.dart';

import '../controller/controller.cadastrar.dart';

class esqueceuSenhaPage extends StatefulWidget {
  const esqueceuSenhaPage({super.key});

  @override
  State<esqueceuSenhaPage> createState() => _esqueceuSenhaPage();
}

class TokenScreen extends StatefulWidget {
  const TokenScreen({super.key});

  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
// Controla se a animação deve iniciar
  bool _mostrarCampos = false;

// Lista de opacidades para cada um dos 6 campos
  final List<double> _opacidades = List.generate(6, (_) => 0.0);

  void _iniciarAnimacao() {
    setState(() {
      _mostrarCampos = true;
    });

// Revela cada campo com um pequeno atraso entre eles (efeito cascata)
    for (int i = 0; i < 6; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          setState(() {
            _opacidades[i] = 1.0;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animação de Token')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
// Botão que dispara a animação
            if (!_mostrarCampos)
              ElevatedButton(
                onPressed: _iniciarAnimacao,
                child: const Text('Gerar Token'),
              ),

            if (_mostrarCampos) ...[
              const Text(
                'Digite o código enviado:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

// Linha com os 6 campos de token
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return AnimatedOpacity(
                    opacity: _opacidades[index],
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    child: SizedBox(
                      width: 45,
                      child: TextField(
                        autofocus:
                            index == 0, // Foca no primeiro campo ao aparecer
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: const InputDecoration(
                          counterText:
                              '', // Remove o contador de caracteres interno
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
// Avança o foco automaticamente para o próximo campo
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(context).nextFocus();
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _esqueceuSenhaPage extends State<esqueceuSenhaPage> {
  final TextEditingController confirmaEmailController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController novaSenhaController = TextEditingController();
  final TextEditingController confirmacaoSenhaController = TextEditingController();
  final CadastroController cadastroController = CadastroController();
  bool carregando = false;
  bool tokenEnviado = false;

  @override
  void dispose() {
    confirmaEmailController.dispose();
    tokenController.dispose();
    novaSenhaController.dispose();
    confirmacaoSenhaController.dispose();
    super.dispose();
  }

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> solicitarToken() async {
    final email = confirmaEmailController.text.trim();
    if (email.isEmpty) {
      mostrarMensagem('Digite seu e-mail');
      return;
    }
    setState(() => carregando = true);
    try {
      await cadastroController.solicitarToken(email);
      if (mounted) {
        setState(() => tokenEnviado = true);
        mostrarMensagem('Confira seu e-mail e a pasta Spam.');
      }
    } catch (error) {
      if (mounted) mostrarMensagem(error.toString());
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> redefinirSenha() async {
    final email = confirmaEmailController.text.trim();
    final token = tokenController.text.trim();
    if (token.length != 6) {
      mostrarMensagem('Digite o código de 6 números recebido por e-mail.');
      return;
    }
    setState(() => carregando = true);
    try {
      await cadastroController.redefinirSenha(
        email: email,
        token: token,
        novaSenha: novaSenhaController.text,
        confirmacaoSenha: confirmacaoSenhaController.text,
      );
      if (mounted) {
        mostrarMensagem('Senha redefinida com sucesso.');
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) mostrarMensagem(error.toString());
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
              'Digite seu e-mail para receber o link de recuperação',
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
                hintText: 'Digite seu email',
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
                    : const Text('Enviar código'),
              ),
            if (tokenEnviado) ...[
              const Text(
                'Digite o código de 6 números enviado para seu e-mail',
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
                  hintText: 'Código de 6 números',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: novaSenhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFD7CBBD),
                  hintText: 'Nova senha',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmacaoSenhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFD7CBBD),
                  hintText: 'Confirme a nova senha',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: carregando ? null : redefinirSenha,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF895737),
                  foregroundColor: const Color(0xFFF3E9DC),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: carregando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Redefinir senha'),
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
