class MonthlyDump {
  final String id;
  final int year;
  final int month;
  final int postCount;
  final String generatedAt;

  MonthlyDump({
    required this.id,
    required this.year,
    required this.month,
    required this.postCount,
    required this.generatedAt,
  });

  factory MonthlyDump.fromRow(Map<String, dynamic> row) {
    return MonthlyDump(
      id: row['id'] as String,
      year: row['year'] as int,
      month: row['month'] as int,
      postCount: row['post_count'] as int,
      generatedAt: row['generated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'month': month,
      'postCount': postCount,
      'generatedAt': generatedAt,
    };
  }
}
