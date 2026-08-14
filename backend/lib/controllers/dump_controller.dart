import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/dump_scheduler_service.dart';
import '../utils/response_helper.dart';

class DumpController {
  Router get router {
    final router = Router();

    // GET /api/dumps/monthly (RN15, RF12)
    router.get('/monthly', (Request request) async {
      try {
        final dumps = DumpSchedulerService.getDumps();
        return ResponseHelper.success({
          'dumps': dumps.map((d) => d.toJson()).toList(),
        });
      } catch (e) {
        return ResponseHelper.error('Erro ao buscar retrospectivas mensais: ${e.toString()}');
      }
    });

    // POST /api/dumps/generate (RN15, RF12, RNF02)
    router.post('/generate', (Request request) async {
      try {
        final bodyStr = await request.readAsString();
        final body = bodyStr.isNotEmpty ? jsonDecode(bodyStr) as Map<String, dynamic> : <String, dynamic>{};

        final now = DateTime.now();
        final year = (body['year'] as int?) ?? now.year;
        final month = (body['month'] as int?) ?? now.month;

        final dump = DumpSchedulerService.generateMonthlyDump(year, month);
        return ResponseHelper.success({
          'message': 'Dump mensal gerado com sucesso!',
          'dump': dump.toJson(),
        });
      } catch (e) {
        return ResponseHelper.error('Erro ao gerar dump mensal: ${e.toString()}');
      }
    });

    return router;
  }
}
