import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegisterSuccess;

  const RegisterScreen({super.key, required this.onRegisterSuccess});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();
  final _genderController = TextEditingController();

  DateTime? _selectedBirthdate;
  bool _isLoading = false;

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
        const SnackBar(content: Text('A senha e a confirmação de senha não coincidem.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        birthdate: _birthdateController.text,
        bio: _bioController.text.trim(),
        gender: _genderController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onRegisterSuccess();
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
                    const Text(
                      'Cadastre-se',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Apenas para maiores de 16 anos (RN01)',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    CustomTextField(
                      controller: _nameController,
                      label: 'Nome Completo',
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v == null || v.isEmpty ? 'Informe seu nome' : null,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _emailController,
                      label: 'E-mail (RN08 - Único)',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || v.isEmpty ? 'Informe seu e-mail' : null,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _birthdateController,
                      label: 'Data de Nascimento (RN01 >= 16 Anos)',
                      hint: 'YYYY-MM-DD',
                      prefixIcon: Icons.cake_outlined,
                      readOnly: true,
                      onTap: _selectBirthdate,
                      validator: (v) => v == null || v.isEmpty ? 'Selecione sua data de nascimento' : null,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _passwordController,
                      label: 'Senha (RN07 - Min 8, A-z, 0-9, @)',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (v) => v == null || v.isEmpty ? 'Informe sua senha' : null,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirmação de Senha (RN04)',
                      prefixIcon: Icons.lock_reset_outlined,
                      obscureText: true,
                      validator: (v) => v == null || v.isEmpty ? 'Confirme sua senha' : null,
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

                    CustomButton(
                      text: 'Criar Minha Conta',
                      isLoading: _isLoading,
                      onPressed: _handleRegister,
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
