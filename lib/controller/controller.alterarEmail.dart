import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:snaplock/controller/controller.login.dart';
import 'package:snaplock/services/api_service.dart';

class AlterarEmailController {
  AlterarEmailController({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  void dispose() {
    _client.close();
  }

  Future<void> solicitarCodigo({
    required String novoEmail,
    required String senhaAtual,
  }) async {
    final token = LoginController.tokenAtual;
    if (token == null || token.isEmpty) {
      throw const LoginException(
        'Faça login novamente para alterar o e-mail.',
      );
    }

    final response = await _client.post(
      Uri.parse('${LoginController.apiBaseUrl}/api/profile/email/request'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': '******',
      },
      body: jsonEncode({
        'email': novoEmail.trim(),
        'senha': senhaAtual,
      }),
    );

    final data = _decodeResponse(response);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        data['success'] != true) {
      throw LoginException(
        data['message']?.toString() ??
            data['erro']?.toString() ??
            'Não foi possível enviar o código.',
      );
    }
  }

  Future<void> confirmarCodigo({
    required String novoEmail,
    required String codigo,
  }) async {
    final token = LoginController.tokenAtual;
    if (token == null || token.isEmpty) {
      throw const LoginException(
        'Faça login novamente para confirmar o e-mail.',
      );
    }

    final response = await _client.post(
      Uri.parse('${LoginController.apiBaseUrl}/api/profile/email/confirm'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': '******',
      },
      body: jsonEncode({
        'email': novoEmail.trim(),
        'token': codigo.trim(),
      }),
    );

    final data = _decodeResponse(response);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        data['success'] != true) {
      throw LoginException(
        data['message']?.toString() ??
            data['erro']?.toString() ??
            'Não foi possível confirmar o e-mail.',
      );
    }

    await ApiService.updateCurrentEmail(novoEmail.trim().toLowerCase());
    LoginController.atualizarEmailAtual(novoEmail.trim().toLowerCase());
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } on FormatException {
      throw const LoginException('A API retornou uma resposta inválida.');
    }
    throw const LoginException('A API retornou uma resposta inválida.');
  }
}
