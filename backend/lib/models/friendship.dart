class Friendship {
  final String id;
  final String userId;
  final String friendId;
  final String status;
  final String createdAt;

  Friendship({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.status,
    required this.createdAt,
  });

  factory Friendship.fromRow(Map<String, dynamic> row) {
    return Friendship(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      friendId: row['friend_id'] as String,
      status: row['status'] as String,
      createdAt: row['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'friendId': friendId,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
