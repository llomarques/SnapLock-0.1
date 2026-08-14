class Post {
  final String id;
  final String userId;
  final String imageUrl;
  final String caption;
  final String createdAt;
  final String? authorName;
  final String? authorAvatar;
  final int reactionCount;
  final String? userReaction;

  Post({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.caption,
    required this.createdAt,
    this.authorName,
    this.authorAvatar,
    this.reactionCount = 0,
    this.userReaction,
  });

  factory Post.fromRow(Map<String, dynamic> row) {
    return Post(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      imageUrl: row['image_url'] as String,
      caption: (row['caption'] as String?) ?? '',
      createdAt: row['created_at'] as String,
      authorName: row['author_name'] as String?,
      authorAvatar: row['author_avatar'] as String?,
      reactionCount: (row['reaction_count'] as int?) ?? 0,
      userReaction: row['user_reaction'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'caption': caption,
      'createdAt': createdAt,
      if (authorName != null) 'authorName': authorName,
      if (authorAvatar != null) 'authorAvatar': authorAvatar,
      'reactionCount': reactionCount,
      if (userReaction != null) 'userReaction': userReaction,
    };
  }
}
