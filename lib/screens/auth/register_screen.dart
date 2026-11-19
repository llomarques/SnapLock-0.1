import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'confirm_signup_email_screen.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();
  final _genderController = TextEditingController();

  DateTime? _selectedBirthdate;
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _selectBirthdate() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 16, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthdate ?? initialDate,
      firstDate: DateTime(1920),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _selectedBirthdate = picked;
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('A senha e a confirmação de senha não coincidem.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService.register(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        birthdate: _birthdateController.text,
        bio: _bioController.text.trim(),
        gender: _genderController.text.trim(),
      );
      if (mounted) {
        _passwordController.clear();
        _confirmPasswordController.clear();
        setState(() => _emailSent = true);
        await _openConfirmationPage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openConfirmationPage() async {
    final accountCreated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ConfirmSignupEmailScreen(email: _emailController.text.trim()),
      ),
    );
    if (accountCreated == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bioController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta SnapLock')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cadastre-se',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Apenas para maiores de 16 anos (RN01)',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _nameController,
                      label: 'Nome Completo',
                      prefixIcon: Icons.person_outline,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe seu nome' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _usernameController,
                      label: 'Username',
                      prefixIcon: Icons.alternate_email,
                      validator: (v) => v == null || v.trim().length < 3
                          ? 'Informe um username com pelo menos 3 caracteres'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      label: 'E-mail (RN08 - Único)',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe seu e-mail' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _birthdateController,
                      label: 'Data de Nascimento (RN01 >= 16 Anos)',
                      hint: 'YYYY-MM-DD',
                      prefixIcon: Icons.cake_outlined,
                      readOnly: true,
                      onTap: _selectBirthdate,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Selecione sua data de nascimento'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Senha (RN07 - Min 8, A-z, 0-9, @)',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe sua senha' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirmação de Senha (RN04)',
                      prefixIcon: Icons.lock_reset_outlined,
                      obscureText: true,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Confirme sua senha' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _bioController,
                      label: 'Biografia (Opcional)',
                      prefixIcon: Icons.description_outlined,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _genderController,
                      label: 'Gênero (Opcional)',
                      prefixIcon: Icons.wc_outlined,
                    ),
                    const SizedBox(height: 24),
                    if (_emailSent)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Enviamos um código de seis dígitos para '
                            '${_emailController.text.trim()}. Confirme seu e-mail '
                            'para criar sua conta.',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            text: 'Inserir código de confirmação',
                            isLoading: _isLoading,
                            onPressed: _openConfirmationPage,
                          ),
                        ],
                      )
                    else
                      CustomButton(
                        text: 'Enviar confirmação por e-mail',
                        isLoading: _isLoading,
                        onPressed: _handleRegister,
                      ),
                    if (_emailSent) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Voltar ao login'),
                      ),
                    ],
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
