class PostModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String caption;
  final String createdAt;
  final String? authorName;
  final String? authorAvatar;
  final int reactionCount;
  final String? userReaction;

  PostModel({
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

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      caption: (json['caption'] as String?) ?? '',
      createdAt: json['createdAt'] as String,
      authorName: json['authorName'] as String?,
      authorAvatar: json['authorAvatar'] as String?,
      reactionCount: (json['reactionCount'] as int?) ?? 0,
      userReaction: json['userReaction'] as String?,
    );
  }
}
