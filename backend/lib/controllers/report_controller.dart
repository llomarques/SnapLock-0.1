import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../middlewares/auth_middleware.dart';
import '../services/report_service.dart';
import '../utils/response_helper.dart';

class ReportController {
  Router get router {
    final router = Router();

    // POST /api/reports (RN11, RF11)
    router.post('/', (Request request) async {
      try {
        final userId = getUserIdFromRequest(request);
        final bodyStr = await request.readAsString();
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;

        final postId = body['postId'] as String?;
        final reason = body['reason'] as String?;

        if (postId == null || reason == null) {
          return ResponseHelper.error('Informe o ID da publicação e o motivo da denúncia.');
        }

        final report = ReportService.reportPost(
          postId: postId,
          reporterId: userId,
          reason: reason,
        );

        return ResponseHelper.success({
          'message': 'Denúncia enviada com sucesso! A publicação passará pela análise da administração (RN11).',
          'report': report.toJson(),
        }, statusCode: 201);
      } on FormatException catch (e) {
        return ResponseHelper.error(e.message);
      } catch (e) {
        return ResponseHelper.error('Erro ao enviar denúncia: ${e.toString()}');
      }
    });

    // GET /api/reports
    router.get('/', (Request request) async {
      try {
        final reports = ReportService.getAllReports();
        return ResponseHelper.success({
          'reports': reports.map((r) => r.toJson()).toList(),
        });
      } catch (e) {
        return ResponseHelper.error('Erro ao buscar denúncias: ${e.toString()}');
      }
    });

    return router;
  }
}
