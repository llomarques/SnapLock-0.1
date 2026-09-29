import 'package:flutter/material.dart';
import 'package:snaplock/frontend/widgets/inputSenha_widget.dart';
import '../../services/api_service.dart';
import '../../controller/controller.alterarSenha.dart';

class AlterarSenhaPage extends StatefulWidget {
	const AlterarSenhaPage({super.key});

	@override
	State<AlterarSenhaPage> createState() => _AlterarSenhaPageState();
}

class _AlterarSenhaPageState extends State<AlterarSenhaPage> {
	final AlterarSenhaController alterarSenhaController = AlterarSenhaController();
	final senhaAtualController = TextEditingController();
	final novaSenhaController = TextEditingController();
	final confirmarSenhaController = TextEditingController();
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
			await alterarSenhaController.alterarSenha(
				senhaAtual: senhaAtualController.text,
				novaSenha: novaSenhaController.text,
				confirmacaoSenha: confirmarSenhaController.text,
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
			appBar: AppBar(
				backgroundColor: const Color(0xFFF3E9DC),
				 elevation: 0,
				leading: IconButton(
					onPressed: () => Navigator.pop(context),
					icon: const Icon(Icons.arrow_back),
					color: const Color(0xFF5E3023),
					tooltip: 'Voltar',
				),
			),
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
						InputsenhaWidget(
							controller: senhaAtualController,
							texto: 'Senha atual',
						),
						const SizedBox(height: 20),
						InputsenhaWidget(
							controller: novaSenhaController,
							texto: 'Nova senha',
						),
						const SizedBox(height: 20),
						InputsenhaWidget(
							controller: confirmarSenhaController,
							texto: 'Confirma senha',
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

}

