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
    final token = _resolvedToken();
    if (token == null || token.isEmpty) {
      throw const LoginException(
        'Faça login novamente para alterar o e-mail.',
      );
    }

    final response = await _client.post(
      Uri.parse('${LoginController.apiBaseUrl}/api/profile/email/request'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
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
      final mensagem = data['message']?.toString() ??
          data['erro']?.toString() ??
          'Não foi possível enviar o código.';
      throw LoginException(
        _mensagemSessaoExpirada(mensagem),
      );
    }
  }

  Future<void> confirmarCodigo({
    required String novoEmail,
    required String codigo,
  }) async {
    final token = _resolvedToken();
    if (token == null || token.isEmpty) {
      throw const LoginException(
        'Faça login novamente para confirmar o e-mail.',
      );
    }

    final response = await _client.post(
      Uri.parse('${LoginController.apiBaseUrl}/api/profile/email/confirm'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
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
      final mensagem = data['message']?.toString() ??
          data['erro']?.toString() ??
          'Não foi possível confirmar o e-mail.';
      throw LoginException(
        _mensagemSessaoExpirada(mensagem),
      );
    }

    await ApiService.updateCurrentEmail(novoEmail.trim().toLowerCase());
    LoginController.atualizarEmailAtual(novoEmail.trim().toLowerCase());
  }

  String? _resolvedToken() {
    final apiToken = ApiService.token?.trim();
    if (apiToken != null && apiToken.isNotEmpty) return apiToken;
    final loginToken = LoginController.tokenAtual?.trim();
    return loginToken?.isNotEmpty == true ? loginToken : null;
  }

  String _mensagemSessaoExpirada(String mensagem) {
    final normalized = mensagem.toLowerCase();
    if (normalized.contains('sessão inválida') ||
        normalized.contains('sessao invalida') ||
        normalized.contains('token') ||
        normalized.contains('não autorizado')) {
      return 'Sua sessão expirou. Faça login novamente e tente alterar o e-mail.';
    }
    return mensagem;
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
