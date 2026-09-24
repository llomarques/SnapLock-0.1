import 'dart:convert';
import 'dart:typed_data';
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

  static Map<String, dynamic>? usuarioAtual;
  static String? tokenAtual;

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

    final resposta = body ?? <String, dynamic>{};
    final usuario = resposta['user'];
    usuarioAtual = usuario is Map<String, dynamic>
        ? usuario
        : {
            'id': resposta['id_usuario']?.toString() ?? '',
            'name': resposta['nome']?.toString() ?? '',
            'username': resposta['username']?.toString() ?? '',
            'usernameChangedAt': resposta['usernameChangedAt']?.toString() ?? '',
            'email': resposta['email']?.toString() ?? '',
            'bio': resposta['bio']?.toString() ?? '',
            'avatarUrl': resposta['avatarUrl']?.toString() ?? '',
          };
    tokenAtual = resposta['token']?.toString();
    return resposta;
  }

  static Future<String> atualizarFotoPerfil(Uint8List bytesImagem) async {
  if (tokenAtual == null || tokenAtual!.isEmpty) {
    throw const LoginException('Faça login novamente para editar o perfil.');
  }

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('$apiBaseUrl/api/profile/foto'),
  )
    ..headers['Authorization'] = 'Bearer $tokenAtual'
    ..files.add(
      http.MultipartFile.fromBytes(
        'foto',
        bytesImagem,
        filename: 'foto_perfil.jpg',
      ),
    );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  final decoded = jsonDecode(response.body);
  final data = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

  if (response.statusCode < 200 || response.statusCode >= 300 || data['success'] != true) {
    throw LoginException(data['message']?.toString() ?? 'Erro ao enviar a foto de perfil.');
  }

  final novaUrl = data['foto_perfil']?.toString() ?? '';

  // Atualiza o usuário em memória com a nova foto
  if (usuarioAtual != null) {
    usuarioAtual = {
      ...usuarioAtual!,
      'avatarUrl': novaUrl,
    };
  }

  return novaUrl;
}

  static Future<Map<String, dynamic>> atualizarPerfil({
    required String nome,
    required String username,
    required String biografia,
  }) async {
    if (tokenAtual == null || tokenAtual!.isEmpty) {
      throw const LoginException('Faça login novamente para editar o perfil.');
    }

    final response = await http.put(
      Uri.parse('$apiBaseUrl/api/profile'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $tokenAtual',
      },
      body: jsonEncode({
        'name': nome,
        'username': username,
        'bio': biografia,
      }),
    );

    final decoded = jsonDecode(response.body);
    final data = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (response.statusCode < 200 || response.statusCode >= 300 || data['success'] != true) {
      throw LoginException(data['message']?.toString() ?? 'Erro ao salvar o perfil.');
    }

    final usuario = data['user'];
    if (usuario is Map<String, dynamic>) {
      usuarioAtual = usuario;
    }
    return data;
  }

}