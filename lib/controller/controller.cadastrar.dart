import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CadastroException implements Exception {
	const CadastroException(this.message);

	final String message;

	@override
	String toString() => message;
}

class CadastroController {
	CadastroController({http.Client? client}) : _client = client ?? http.Client();

	static const String _apiBaseUrlOverride = String.fromEnvironment(
		'API_BASE_URL',
		defaultValue: '',
	);

	static String get apiBaseUrl {
		if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
		if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
			return 'http://10.0.2.2:3000';
		}
		return 'http://localhost:3000';
	}

	final http.Client _client;

	Future<void> cadastrarUsuario({
		required String nome,
		required String email,
		required String senha,
		required String confirmacaoSenha,
		required DateTime dataNascimento,
	}) async {
		if (!_senhaValida(senha)) {
			throw const CadastroException(
				'A senha deve ter 8 caracteres, uma maiúscula, uma minúscula, um número e um caractere especial.',
			);
		}
		if (senha != confirmacaoSenha) {
			throw const CadastroException('As senhas não conferem.');
		}
		final hoje = DateTime.now();
		final dataLimite = DateTime(hoje.year - 16, hoje.month, hoje.day);
		if (dataNascimento.isAfter(dataLimite)) {
			throw const CadastroException('O usuário precisa ter 16 anos ou mais.');
		}

		final uri = Uri.parse('$apiBaseUrl/api/usuarios');
		final response = await _client.post(
			uri,
			headers: const {'Content-Type': 'application/json'},
			body: jsonEncode({
				'nome': nome.trim(),
				'email': email.trim().toLowerCase(),
				'senha': senha,
				'confirmacao_senha': confirmacaoSenha,
				'data_nascimento': _formatarData(dataNascimento),
			}),
		);

		Map<String, dynamic>? body;
		if (response.body.isNotEmpty) {
			final decoded = jsonDecode(response.body);
			if (decoded is Map<String, dynamic>) {
				body = decoded;
			}
		}

		if (response.statusCode < 200 || response.statusCode >= 300) {
			throw CadastroException(
				body?['erro']?.toString() ?? 'Não foi possível cadastrar o usuário.',
			);
		}
	}

	Future<void> solicitarToken(String email) async {
		await _enviar('/api/recuperacao/solicitar', {'email': email.trim().toLowerCase()});
	}

	Future<void> redefinirSenha({
		required String email,
		required String token,
		required String novaSenha,
		required String confirmacaoSenha,
	}) async {
		if (!_senhaValida(novaSenha)) {
			throw const CadastroException(
				'A senha deve ter 8 caracteres, uma maiúscula, uma minúscula, um número e um caractere especial.',
			);
		}
		if (novaSenha != confirmacaoSenha) {
			throw const CadastroException('As senhas não conferem.');
		}
		await _enviar('/api/recuperacao/redefinir', {
			'email': email.trim().toLowerCase(),
			'token': token,
			'nova_senha': novaSenha,
			'confirmacao_senha': confirmacaoSenha,
		});
	}

	Future<void> _enviar(String caminho, Map<String, String> dados) async {
		final response = await _client.post(
			Uri.parse('$apiBaseUrl$caminho'),
			headers: const {'Content-Type': 'application/json'},
			body: jsonEncode(dados),
		);
		Map<String, dynamic>? body;
		if (response.body.isNotEmpty) {
			final decoded = jsonDecode(response.body);
			if (decoded is Map<String, dynamic>) body = decoded;
		}
		if (response.statusCode < 200 || response.statusCode >= 300) {
			throw CadastroException(body?['erro']?.toString() ?? 'Não foi possível concluir a operação.');
		}
	}

	bool _senhaValida(String senha) => RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$').hasMatch(senha);

	String _formatarData(DateTime data) {
		final mes = data.month.toString().padLeft(2, '0');
		final dia = data.day.toString().padLeft(2, '0');
		return '${data.year}-$mes-$dia';
	}
}
