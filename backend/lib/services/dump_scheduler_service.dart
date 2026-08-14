import 'dart:async';
import 'package:cron/cron.dart';
import 'package:uuid/uuid.dart';
import '../config/database.dart';
import '../models/dump.dart';

class DumpSchedulerService {
  static final _cron = Cron();
  static final _uuid = const Uuid();

  /// Starts the background scheduler for monthly dumps (RN15, RF12, RNF02).
  /// Runs on the last day of every month at 23:59 BRT (UTC-3).
  static void startScheduler() {
    print('⏰ Iniciando agendador de Dump Mensal (RN15)...');
    
    // Check every day at 23:59
    _cron.schedule(Schedule.parse('59 23 * * *'), () async {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      // Check if tomorrow is the 1st day of next month (which means today is the last day of the month)
      if (tomorrow.day == 1) {
        print('📅 Geração de dump mensal disparada automaticamente no último dia do mês às 23:59.');
        generateMonthlyDump(now.year, now.month);
      }
    });
  }

  /// Generates or refreshes a monthly retrospective dump for a given year and month (RN15, RF12).
  static MonthlyDump generateMonthlyDump(int year, int month) {
    // 1. Calculate start and end date for target month
    final startDate = DateTime(year, month, 1).toIso8601String();
    final nextMonth = month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    final endDate = nextMonth.toIso8601String();

    // 2. Count posts created during that month
    final countResult = DatabaseConfig.db.select(
      '''
      SELECT COUNT(*) as total FROM posts
      WHERE created_at >= ? AND created_at < ?
      ''',
      [startDate, endDate],
    );

    final postCount = (countResult.first['total'] as int?) ?? 0;
    final generatedAt = DateTime.now().toIso8601String();
    final dumpId = _uuid.v4();

    // 3. Save or Update in monthly_dumps
    DatabaseConfig.db.execute(
      '''
      INSERT INTO monthly_dumps (id, year, month, post_count, generated_at)
      VALUES (?, ?, ?, ?, ?)
      ON CONFLICT(year, month) DO UPDATE SET
        post_count = excluded.post_count,
        generated_at = excluded.generated_at
      ''',
      [dumpId, year, month, postCount, generatedAt],
    );

    print('✨ Dump mensal para $month/$year gerado com sucesso! Total de fotos no período: $postCount');

    return MonthlyDump(
      id: dumpId,
      year: year,
      month: month,
      postCount: postCount,
      generatedAt: generatedAt,
    );
  }

  /// Retrieve all generated dumps
  static List<MonthlyDump> getDumps() {
    final results = DatabaseConfig.db.select(
      'SELECT * FROM monthly_dumps ORDER BY year DESC, month DESC',
    );

    return results.map((row) => MonthlyDump.fromRow(row)).toList();
  }

  static void stopScheduler() {
    _cron.close();
  }
}
