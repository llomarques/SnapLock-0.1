import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/snaplock_logo.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      widget.onLoginSuccess();
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

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController(text: _emailController.text);
    final tokenCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    int step = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            step == 1 ? 'Esqueceu a senha' : 'Redefinir Senha',
            style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (step == 1) ...[
                Text(
                  'Digite seu e-mail para receber um link de recuperação (RN05):',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: emailCtrl,
                  label: 'E-mail',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
              ] else ...[
                Text(
                  'Informe o token recebido e sua nova senha (RN07):',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: tokenCtrl,
                  label: 'Token Recebido',
                  prefixIcon: Icons.key_outlined,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: newPasswordCtrl,
                  label: 'Nova Senha',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Voltar para login', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkBrown),
              onPressed: () async {
                if (step == 1) {
                  try {
                    final res = await ApiService.forgotPassword(emailCtrl.text.trim());
                    setDialogState(() => step = 2);
                    if (res['token'] != null) {
                      tokenCtrl.text = res['token'].toString();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                      );
                    }
                  }
                } else {
                  try {
                    await ApiService.resetPassword(
                      emailCtrl.text.trim(),
                      tokenCtrl.text.trim(),
                      newPasswordCtrl.text,
                    );
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Senha redefinida com sucesso!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                      );
                    }
                  }
                }
              },
              child: Text(step == 1 ? 'Enviar link' : 'Confirmar Nova Senha', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppTheme.cardBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkBrown.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Emblema do Figma: SnapLock • FOR YOU ONLY •
                    const SnapLockLogo(size: 130),
                    const SizedBox(height: 20),

                    Text(
                      'Seja bem-vindo!',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Faça login ou crie sua conta para continuar',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 24),

                    // Inputs
                    CustomTextField(
                      controller: _emailController,
                      label: 'E-mail',
                      hint: 'seuemail@exemplo.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => val == null || val.isEmpty ? 'Informe seu e-mail' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Senha',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (val) => val == null || val.isEmpty ? 'Informe sua senha' : null,
                    ),

                    // Link Esqueceu a senha
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: Text(
                          'Esqueceu a minha senha?',
                          style: GoogleFonts.poppins(color: AppTheme.mediumBrown, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botão Fazer Login (Figma: #5E3023)
                    CustomButton(
                      text: 'Entrar',
                      color: AppTheme.darkBrown,
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: 16),

                    // Botão Criar Conta (Figma: #895737)
                    CustomButton(
                      text: 'Criar conta',
                      color: AppTheme.mediumBrown,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterScreen(onRegisterSuccess: widget.onLoginSuccess),
                          ),
                        );
                      },
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
