import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:path/path.dart' as p;

import '../lib/config/database.dart';
import '../lib/controllers/auth_controller.dart';
import '../lib/controllers/dump_controller.dart';
import '../lib/controllers/friend_controller.dart';
import '../lib/controllers/post_controller.dart';
import '../lib/controllers/profile_controller.dart';
import '../lib/controllers/report_controller.dart';
import '../lib/middlewares/auth_middleware.dart';
import '../lib/middlewares/cors_middleware.dart';
import '../lib/middlewares/error_middleware.dart';
import '../lib/services/dump_scheduler_service.dart';
import '../lib/utils/response_helper.dart';

void main(List<String> args) async {
  print('🚀 Iniciando Servidor Backend SnapLock em Dart (CyberSisters)...');

  // 1. Inicializa o Banco de Dados SQLite
  DatabaseConfig.init();

  // 2. Garante que o diretório de uploads existe
  final uploadsPath = p.join(Directory.current.path, 'uploads');
  final uploadsDir = Directory(uploadsPath);
  if (!uploadsDir.existsSync()) {
    uploadsDir.createSync(recursive: true);
  }

  // 3. Inicia o agendador automático dos Dumps Mensais (RN15, RF12)
  DumpSchedulerService.startScheduler();

  // 4. Configura as Rotas REST API
  final mainRouter = Router();

  // Rota Health Check
  mainRouter.get('/api/health', (Request request) {
    return ResponseHelper.success({
      'status': 'online',
      'app': 'SnapLock Backend API (CyberSisters SENAI)',
      'timestamp': DateTime.now().toIso8601String(),
    });
  });

  // Rotas de Autenticação (Públicas)
  mainRouter.mount('/api/auth', AuthController().router.call);

  // Controller de Postagens e Feed
  final postController = PostController();
  final protectedPostHandler = Pipeline()
      .addMiddleware(authMiddleware())
      .addHandler(postController.router.call);

  mainRouter.mount('/api/posts', protectedPostHandler);
  mainRouter.mount('/api/feed', protectedPostHandler);

  // Rotas Protegidas com Autenticação JWT
  mainRouter.mount(
    '/api/profile',
    Pipeline().addMiddleware(authMiddleware()).addHandler(ProfileController().router.call),
  );

  mainRouter.mount(
    '/api/friends',
    Pipeline().addMiddleware(authMiddleware()).addHandler(FriendController().router.call),
  );

  mainRouter.mount(
    '/api/reports',
    Pipeline().addMiddleware(authMiddleware()).addHandler(ReportController().router.call),
  );

  mainRouter.mount(
    '/api/dumps',
    Pipeline().addMiddleware(authMiddleware()).addHandler(DumpController().router.call),
  );

  // Servidor de Arquivos Estáticos de Mídia (/uploads)
  final staticFileHandler = createStaticHandler(
    uploadsPath,
    defaultDocument: null,
    serveFilesOutsidePath: false,
  );

  final cascade = Cascade()
      .add(mainRouter.call)
      .add((Request request) {
        if (request.url.path.startsWith('uploads/')) {
          final newPath = request.url.path.replaceFirst('uploads/', '');
          final modifiedRequest = Request(
            request.method,
            request.requestedUri.replace(path: newPath),
            headers: request.headers,
            body: request.read(),
            context: request.context,
          );
          return staticFileHandler(modifiedRequest);
        }
        return ResponseHelper.notFound(message: 'Rota não encontrada no servidor SnapLock.');
      });

  // Pipeline com Middlewares Globais (CORS, Error, Log)
  final handler = Pipeline()
      .addMiddleware(corsMiddleware())
      .addMiddleware(errorMiddleware())
      .addMiddleware(logRequests())
      .addHandler(cascade.handler);

  // Porta do servidor (padrão 8080 ou via variável de ambiente PORT)
  final portEnv = Platform.environment['PORT'];
  final port = portEnv != null ? int.parse(portEnv) : 8080;
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);

  print('✅ Servidor SnapLock rodando em: http://${server.address.host}:${server.port}');
  print('📌 Health Check: http://localhost:${server.port}/api/health');
}
