import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import '../utils/response_helper.dart';

const String _jwtSecret = 'SNAPLOCK_CYBERSISTERS_SECRET_KEY_2026';

class JwtHelper {
  static String generateToken(String userId) {
    final jwt = JWT(
      {'userId': userId},
      issuer: 'snaplock',
    );
    return jwt.sign(SecretKey(_jwtSecret), expiresIn: const Duration(days: 30));
  }

  static String? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_jwtSecret));
      final payload = jwt.payload as Map<String, dynamic>;
      return payload['userId'] as String?;
    } catch (_) {
      return null;
    }
  }
}

Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return ResponseHelper.unauthorized();
      }

      final token = authHeader.substring(7);
      final userId = JwtHelper.verifyToken(token);

      if (userId == null) {
        return ResponseHelper.unauthorized(message: 'Token expirado ou inválido.');
      }

      // Adiciona o userId ao contexto da requisição
      final updatedRequest = request.change(context: {'userId': userId});
      return innerHandler(updatedRequest);
    };
  };
}

String getUserIdFromRequest(Request request) {
  final userId = request.context['userId'] as String?;
  if (userId == null) {
    throw StateError('Usuário não autenticado no contexto da requisição.');
  }
  return userId;
}
