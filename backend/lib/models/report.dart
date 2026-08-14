class Report {
  final String id;
  final String postId;
  final String reporterId;
  final String reason;
  final String status;
  final String createdAt;

  Report({
    required this.id,
    required this.postId,
    required this.reporterId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory Report.fromRow(Map<String, dynamic> row) {
    return Report(
      id: row['id'] as String,
      postId: row['post_id'] as String,
      reporterId: row['reporter_id'] as String,
      reason: row['reason'] as String,
      status: row['status'] as String,
      createdAt: row['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'reporterId': reporterId,
      'reason': reason,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
