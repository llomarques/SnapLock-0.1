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
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      authorName: json['authorName']?.toString(),
      authorAvatar: json['authorAvatar']?.toString(),
      reactionCount: int.tryParse(
            json['reactionCount']?.toString() ?? '0',
          ) ??
          0,
      userReaction: json['userReaction']?.toString(),
    );
  }
}