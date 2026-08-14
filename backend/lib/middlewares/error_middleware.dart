import 'package:shelf/shelf.dart';
import '../utils/response_helper.dart';

Middleware errorMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        return await innerHandler(request);
      } catch (e, stackTrace) {
        print('❌ Erro de Execução [${request.method} ${request.requestedUri.path}]: $e');
        print(stackTrace);
        return ResponseHelper.internalError(message: 'Erro interno no servidor: ${e.toString()}');
      }
    };
  };
}
