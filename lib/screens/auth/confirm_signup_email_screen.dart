import 'package:flutter/material.dart';

import '../../controller/controller.cadastrar.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ConfirmSignupEmailScreen extends StatefulWidget {
  const ConfirmSignupEmailScreen({super.key, required this.email});

  final String email;

  @override
  State<ConfirmSignupEmailScreen> createState() =>
      _ConfirmSignupEmailScreenState();
}

class _ConfirmSignupEmailScreenState extends State<ConfirmSignupEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _cadastroController = CadastroController();

  bool _isLoading = false;
  bool _accountCreated = false;

  Future<void> _confirmEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _cadastroController.confirmarCadastro(
        email: widget.email,
        token: _tokenController.text,
      );
      if (mounted) setState(() => _accountCreated = true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar e-mail')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: _accountCreated
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'E-mail confirmado e conta criada! Agora você já pode entrar.',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'Ir para o login',
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Confirme seu e-mail',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Enviamos um código de seis dígitos para ${widget.email}. '
                            'Digite-o abaixo para confirmar seu e-mail e criar sua conta. '
                            'O código expira em 15 minutos.',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            controller: _tokenController,
                            label: 'Código de confirmação',
                            hint: '000000',
                            prefixIcon: Icons.pin_outlined,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            validator: (value) => value == null ||
                                    !RegExp(r'^\d{6}$').hasMatch(value.trim())
                                ? 'Digite o código de 6 dígitos'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            text: 'Confirmar e criar conta',
                            isLoading: _isLoading,
                            onPressed: _confirmEmail,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
