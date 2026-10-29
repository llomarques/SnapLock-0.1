import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snaplock/controller/controller.alterarEmail.dart';
import 'package:snaplock/frontend/widgets/inputSenha_widget.dart';
import 'package:snaplock/frontend/widgets/input_widget.dart';

class AlterarEmailPage extends StatefulWidget {
  const AlterarEmailPage({super.key});

  @override
  State<AlterarEmailPage> createState() => _AlterarEmailPageState();
}

class _AlterarEmailPageState extends State<AlterarEmailPage> {
  final _alterarEmailController = AlterarEmailController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _codigoController = TextEditingController();
  bool _carregando = false;
  bool _codigoEnviado = false;
  String? _emailSolicitado;

  @override
  void dispose() {
    _alterarEmailController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _mostrarMensagem('Digite um e-mail válido.');
      return;
    }
    if (_senhaController.text.isEmpty) {
      _mostrarMensagem('Digite sua senha atual.');
      return;
    }

    setState(() => _carregando = true);
    try {
      await _alterarEmailController.solicitarCodigo(
        novoEmail: email,
        senhaAtual: _senhaController.text,
      );
      if (!mounted) return;

      setState(() {
        _emailSolicitado = email;
        _codigoEnviado = true;
      });
      _senhaController.clear();
      _mostrarMensagem('Código enviado para $email. Confira também o Spam.');
    } catch (error) {
      if (mounted) _mostrarMensagem(error.toString());
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _confirmarCodigo() async {
    final codigo = _codigoController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(codigo)) {
      _mostrarMensagem('Digite o código de 6 números recebido por e-mail.');
      return;
    }

    final email = _emailSolicitado;
    if (email == null) {
      _mostrarMensagem('Solicite um novo código para continuar.');
      return;
    }

    setState(() => _carregando = true);
    try {
      await _alterarEmailController.confirmarCodigo(
        novoEmail: email,
        codigo: codigo,
      );
      if (!mounted) return;

      _mostrarMensagem('E-mail alterado com sucesso.');
      Navigator.pop(context, email);
    } catch (error) {
      if (mounted) _mostrarMensagem(error.toString());
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem.replaceFirst('Exception: ', ''))),
    );
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
        title: const Text('Alterar e-mail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 40),
            Text(
              _codigoEnviado
                  ? 'Digite o código enviado para ${_emailSolicitado ?? 'seu novo e-mail'}.'
                  : 'Informe seu novo e-mail e confirme sua senha atual.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2F211C),
              ),
            ),
            const SizedBox(height: 24),
            if (!_codigoEnviado) ...[
              InputWidget(
                controller: _emailController,
                texto: 'Novo e-mail',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              InputsenhaWidget(
                controller: _senhaController,
                texto: 'Senha atual',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _carregando ? null : _enviarCodigo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF895737),
                  foregroundColor: const Color(0xFFF3E9DC),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _carregando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enviar código'),
              ),
            ] else ...[
              TextField(
                controller: _codigoController,
                enabled: !_carregando,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFD7CBBD),
                  hintText: 'Código de 6 números',
                  prefixIcon: const Icon(
                    Icons.verified_user,
                    color: Color(0xFF5E3023),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _carregando ? null : _confirmarCodigo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF895737),
                  foregroundColor: const Color(0xFFF3E9DC),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _carregando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirmar novo e-mail'),
              ),
              TextButton(
                onPressed: _carregando
                    ? null
                    : () => setState(() {
                          _codigoEnviado = false;
                          _emailSolicitado = null;
                          _codigoController.clear();
                        }),
                child: const Text('Corrigir e-mail'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
