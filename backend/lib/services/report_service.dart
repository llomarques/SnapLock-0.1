import 'package:uuid/uuid.dart';
import '../config/database.dart';
import '../models/report.dart';

class ReportService {
  static final _uuid = const Uuid();

  /// Report a post (RN11, RF11)
  static Report reportPost({
    required String postId,
    required String reporterId,
    required String reason,
  }) {
    final postCheck = DatabaseConfig.db.select(
      'SELECT id FROM posts WHERE id = ? LIMIT 1',
      [postId],
    );

    if (postCheck.isEmpty) {
      throw FormatException('Publicação não encontrada.');
    }

    if (reason.trim().isEmpty) {
      throw FormatException('O motivo da denúncia deve ser informado.');
    }

    final reportId = _uuid.v4();
    final createdAt = DateTime.now().toIso8601String();

    DatabaseConfig.db.execute(
      '''
      INSERT INTO reports (id, post_id, reporter_id, reason, status, created_at)
      VALUES (?, ?, ?, ?, 'PENDING', ?)
      ''',
      [reportId, postId, reporterId, reason.trim(), createdAt],
    );

    return Report(
      id: reportId,
      postId: postId,
      reporterId: reporterId,
      reason: reason.trim(),
      status: 'PENDING',
      createdAt: createdAt,
    );
  }

  /// List all reports for admin review
  static List<Report> getAllReports() {
    final results = DatabaseConfig.db.select(
      'SELECT * FROM reports ORDER BY created_at DESC',
    );

    return results.map((row) => Report.fromRow(row)).toList();
  }
}
