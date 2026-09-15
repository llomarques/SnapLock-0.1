import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AlterarSenhaPage extends StatefulWidget {
	const AlterarSenhaPage({super.key});

	@override
	State<AlterarSenhaPage> createState() => _AlterarSenhaPageState();
}

class _AlterarSenhaPageState extends State<AlterarSenhaPage> {
	final senhaAtualController = TextEditingController();
	final novaSenhaController = TextEditingController();
	final confirmarSenhaController = TextEditingController();
	bool esconderSenha = true;
	bool carregando = false;

	@override
	void dispose() {
		senhaAtualController.dispose();
		novaSenhaController.dispose();
		confirmarSenhaController.dispose();
		super.dispose();
	}

	Future<void> alterarSenha() async {
		if (novaSenhaController.text != confirmarSenhaController.text) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('As senhas não coincidem.')),
			);
			return;
		}

		setState(() => carregando = true);
		try {
			await ApiService.changePassword(
				senhaAtualController.text,
				novaSenhaController.text,
			);
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(content: Text('Senha alterada com sucesso.')),
				);
				Navigator.pop(context);
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
						TextField(
							controller: senhaAtualController,
							obscureText: esconderSenha,
							decoration: InputDecoration(
								filled: true,
								fillColor: const Color(0xFFD7CBBD),
								hintText: 'Senha atual',
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
						),
						const SizedBox(height: 20),
						TextField(
							controller: novaSenhaController,
							obscureText: esconderSenha,
							decoration: _decoracaoSenha('Digite sua nova senha'),
						),
						const SizedBox(height: 20),
						TextField(
							controller: confirmarSenhaController,
							obscureText: esconderSenha,
							decoration: _decoracaoSenha('Confirmar nova senha'),
						),
						const SizedBox(height: 20),
						ElevatedButton(
							onPressed: carregando ? null : alterarSenha,
							style: ElevatedButton.styleFrom(
								backgroundColor: const Color(0xFF895737),
								foregroundColor: const Color(0xFFF3E9DC),
							),
							child: carregando
									? const CircularProgressIndicator()
									: const Text('Alterar senha'),
						),
					],
				),
			),
		);
	}

	InputDecoration _decoracaoSenha(String texto) {
		return InputDecoration(
			filled: true,
			fillColor: const Color(0xFFD7CBBD),
			hintText: texto,
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
		);
	}
}

