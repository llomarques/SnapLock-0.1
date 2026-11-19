import 'dart:convert';

import 'package:http/http.dart' as http;

import 'controller.login.dart';

class AlterarSenhaController {
	Future<void> alterarSenha({
		required String senhaAtual,
		required String novaSenha,
		required String confirmacaoSenha,
	}) async {
		final token = LoginController.tokenAtual;
		if (token == null || token.isEmpty) {
			throw const LoginException('Faça login novamente para alterar a senha.');
		}

		final response = await http.put(
			Uri.parse('${LoginController.apiBaseUrl}/api/profile/password'),
			headers: {
				'Content-Type': 'application/json; charset=utf-8',
				'Authorization': 'Bearer $token',
			},
			body: jsonEncode({
				'currentPassword': senhaAtual,
				'newPassword': novaSenha,
				'confirmPassword': confirmacaoSenha,
			}),
		);

		Map<String, dynamic> data = <String, dynamic>{};
		try {
			final decoded = jsonDecode(response.body);
			if (decoded is Map<String, dynamic>) {
				data = decoded;
			} else if (decoded is Map) {
				data = Map<String, dynamic>.from(decoded);
			}
		} on FormatException {
			if (response.statusCode >= 200 && response.statusCode < 300) {
				throw const LoginException('Resposta inválida da API ao alterar a senha.');
			}
		}

		if (response.statusCode < 200 || response.statusCode >= 300 || data['success'] != true) {
			throw LoginException(
				data['message']?.toString() ??
					data['erro']?.toString() ??
					'Erro ao alterar senha.',
			);
		}
	}
}
