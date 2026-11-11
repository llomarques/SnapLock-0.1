import 'package:flutter/material.dart';
import 'package:snaplock/theme/app_theme.dart';

class InputsenhaWidget extends StatefulWidget {
  final TextEditingController? controller;
  final String texto;

  const InputsenhaWidget({
    super.key,
    required this.texto,
    this.controller,
  });

  @override
  State<InputsenhaWidget> createState() => _InputsenhaWidgetState();
}

class _InputsenhaWidgetState extends State<InputsenhaWidget> {
  bool esconderSenha = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: widget.controller,
      obscureText: esconderSenha,
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        hintText: widget.texto,
        prefixIcon: Icon(Icons.lock, color: AppTheme.darkBrown),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() => esconderSenha = !esconderSenha);
          },
          icon: Icon(
            esconderSenha ? Icons.visibility : Icons.visibility_off,
            color: AppTheme.darkBrown,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
