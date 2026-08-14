import 'dart:convert';
import 'package:shelf/shelf.dart';

class ResponseHelper {
  static const Map<String, String> jsonHeaders = {
    'content-type': 'application/json; charset=utf-8',
  };

  static Response success(Map<String, dynamic> data, {int statusCode = 200}) {
    return Response(
      statusCode,
      body: jsonEncode({
        'success': true,
        ...data,
      }),
      headers: jsonHeaders,
    );
  }

  static Response error(String message, {int statusCode = 400, dynamic errors}) {
    return Response(
      statusCode,
      body: jsonEncode({
        'success': false,
        'message': message,
        if (errors != null) 'errors': errors,
      }),
      headers: jsonHeaders,
    );
  }

  static Response unauthorized({String message = 'Acesso não autorizado ou token inválido'}) {
    return error(message, statusCode: 401);
  }

  static Response forbidden({String message = 'Acesso proibido'}) {
    return error(message, statusCode: 403);
  }

  static Response notFound({String message = 'Recurso não encontrado'}) {
    return error(message, statusCode: 404);
  }

  static Response internalError({String message = 'Erro interno no servidor'}) {
    return error(message, statusCode: 500);
  }
}
