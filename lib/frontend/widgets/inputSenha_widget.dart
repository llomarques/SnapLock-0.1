import 'package:flutter/material.dart';

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
		return TextField(
			controller: widget.controller,
			obscureText: esconderSenha,
			decoration: InputDecoration(
				filled: true,
				fillColor: const Color(0xFFD7CBBD),
				hintText: widget.texto,
				prefixIcon: const Icon(Icons.lock, color: Color(0xFF5E3023)),
				suffixIcon: IconButton(
					onPressed: () {
						setState(() => esconderSenha = !esconderSenha);
					},
					icon: Icon(
						esconderSenha ? Icons.visibility : Icons.visibility_off,
						color: const Color(0xFF5E3023),
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