class Reaction {
  final String id;
  final String postId;
  final String userId;
  final String reactionType;
  final String createdAt;

  Reaction({
    required this.id,
    required this.postId,
    required this.userId,
    required this.reactionType,
    required this.createdAt,
  });

  factory Reaction.fromRow(Map<String, dynamic> row) {
    return Reaction(
      id: row['id'] as String,
      postId: row['post_id'] as String,
      userId: row['user_id'] as String,
      reactionType: row['reaction_type'] as String,
      createdAt: row['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'reactionType': reactionType,
      'createdAt': createdAt,
    };
  }
}
