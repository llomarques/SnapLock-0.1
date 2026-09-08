import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LoginException implements Exception {
  const LoginException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LoginController {
  LoginController({http.Client? client}) : _client = client ?? http.Client();

  static const _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  final http.Client _client;

  Future<Map<String, dynamic>> entrar({
    required String login, // aceita e-mail ou username
    required String senha,
  }) async {
    final response = await _client.post(
      Uri.parse('$apiBaseUrl/api/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'login': login.trim(),
        'senha': senha,
      }),
    );

    Map<String, dynamic>? body;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) body = decoded;
    } on FormatException {
      throw const LoginException('A API retornou uma resposta inválida.');
    }

    if (response.statusCode != 200) {
      throw LoginException(
        body?['erro']?.toString() ?? 'E-mail/usuário ou senha incorretos.',
      );
    }
    return body ?? <String, dynamic>{};
  }
}