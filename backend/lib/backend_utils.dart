import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shelf/shelf.dart';

Map<String, dynamic>? decodeJson(String body) {
  try {
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : null;
  } on FormatException {
    return null;
  }
}

Future<Map<String, dynamic>?> readJson(Request request) async {
  return decodeJson(await request.readAsString());
}

Response jsonResponse(
  int status,
  Map<String, Object?> body,
  Map<String, String> headers,
) => Response(
      status,
      body: jsonEncode(body),
      headers: headers,
    );

Map<String, String> publicUser(Map<String, String?> user) => {
      'id': user['id_usuario'] ?? '',
      'name': user['nome'] ?? '',
      'username': user['username'] ?? '',
      'email': user['email'] ?? '',
      'bio': user['biografia'] ?? '',
      'avatarUrl': user['foto_perfil'] ?? '',
    };

bool validEmail(String email) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

bool validUsername(String username) =>
    RegExp(r'^[a-z0-9_]{3,30}$').hasMatch(username);

bool validPassword(String password) =>
    RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$')
        .hasMatch(password);

String generateRecoveryToken() =>
    (100000 + Random.secure().nextInt(900000)).toString();

String hashToken(String token) =>
    sha256.convert(utf8.encode(token)).toString();

String generateSessionToken() => base64UrlEncode(
      List<int>.generate(32, (_) => Random.secure().nextInt(256)),
    );

int? authenticatedUserId(Request request, Map<String, int> sessions) {
  final authorization = request.headers['authorization'];
  if (authorization == null || !authorization.startsWith('Bearer ')) {
    return null;
  }
  return sessions[authorization.substring(7).trim()];
}

String extensionForContentType(String? contentType) {
  switch (contentType) {
    case 'image/png':
      return '.png';
    case 'image/webp':
      return '.webp';
    case 'image/gif':
      return '.gif';
    default:
      return '.jpg';
  }
}

bool validDate(String value) {
  final date = DateTime.tryParse(value);
  return date != null &&
      value.length == 10 &&
      date.toIso8601String().startsWith(value);
}

bool validMinimumAge(String value) {
  final birthdate = DateTime.parse(value);
  final today = DateTime.now();
  final minimumDate = DateTime(today.year - 16, today.month, today.day);
  return !birthdate.isAfter(minimumDate);
}
