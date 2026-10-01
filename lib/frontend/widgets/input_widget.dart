import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String texto;
  final IconData icon;
  final TextInputType? keyboardType;
  final int? maximoCaracteres;
  final int? maximoCaracteresSemContador;
  final int? linhasMinimas;
  final int? linhasMaximas;

  const InputWidget({
		super.key,
		required this.texto,
		required this.controller,
		required this.icon,
		this.keyboardType,
    this.maximoCaracteres,
    this.maximoCaracteresSemContador,
    this.linhasMinimas,
    this.linhasMaximas,
	});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maximoCaracteres,
      minLines: linhasMinimas,
      maxLines: linhasMaximas,
      inputFormatters: maximoCaracteresSemContador == null
          ? null
          : [LengthLimitingTextInputFormatter(maximoCaracteresSemContador)],
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFD7CBBD),
        hintText: texto,
        prefixIcon: Icon(icon, color: const Color(0xFF5E3023)),
        counterText: maximoCaracteresSemContador == null ? null : '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}