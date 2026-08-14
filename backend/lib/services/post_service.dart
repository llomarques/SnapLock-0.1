import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import '../config/database.dart';
import '../models/post.dart';
import 'profanity_filter_service.dart';

class PostService {
  static final _uuid = const Uuid();

  /// Save uploaded photo and create post (RN02, RF08)
  static Post createPost({
    required String userId,
    required List<int> imageBytes,
    required String originalFileName,
    String caption = '',
  }) {
    // 1. Content moderation on caption (Page 2 PDF: script against hate speech and profanity)
    if (ProfanityFilterService.hasProfanity(caption)) {
      caption = ProfanityFilterService.filter(caption);
    }

    // 2. Save physical file to backend/uploads/
    final uploadsDir = Directory(p.join(Directory.current.path, 'uploads'));
    if (!uploadsDir.existsSync()) {
      uploadsDir.createSync(recursive: true);
    }

    final ext = p.extension(originalFileName).isEmpty ? '.jpg' : p.extension(originalFileName);
    final fileName = '${_uuid.v4()}$ext';
    final filePath = p.join(uploadsDir.path, fileName);

    final file = File(filePath);
    file.writeAsBytesSync(imageBytes);

    final imageUrl = '/uploads/$fileName';
    final postId = _uuid.v4();
    final createdAt = DateTime.now().toIso8601String();

    // 3. Save to database
    DatabaseConfig.db.execute(
      '''
      INSERT INTO posts (id, user_id, image_url, caption, created_at)
      VALUES (?, ?, ?, ?, ?)
      ''',
      [postId, userId, imageUrl, caption, createdAt],
    );

    // Retrieve post with author info
    final authorResult = DatabaseConfig.db.select(
      'SELECT name, avatar_url FROM users WHERE id = ? LIMIT 1',
      [userId],
    );

    final authorName = authorResult.isNotEmpty ? authorResult.first['name'] as String : null;
    final authorAvatar = authorResult.isNotEmpty ? authorResult.first['avatar_url'] as String? : null;

    return Post(
      id: postId,
      userId: userId,
      imageUrl: imageUrl,
      caption: caption,
      createdAt: createdAt,
      authorName: authorName,
      authorAvatar: authorAvatar,
    );
  }

  /// Get Private Feed (RN13, RF10, RNF01)
  /// Displays user's own posts + authorized friends' posts
  static List<Post> getFeed(String currentUserId) {
    final results = DatabaseConfig.db.select(
      '''
      SELECT 
        p.*,
        u.name as author_name,
        u.avatar_url as author_avatar,
        (SELECT COUNT(*) FROM reactions r WHERE r.post_id = p.id) as reaction_count,
        (SELECT r.reaction_type FROM reactions r WHERE r.post_id = p.id AND r.user_id = ?) as user_reaction
      FROM posts p
      JOIN users u ON u.id = p.user_id
      WHERE u.is_active = 1
        AND (
          p.user_id = ?
          OR p.user_id IN (
            SELECT CASE 
              WHEN f.user_id = ? THEN f.friend_id 
              ELSE f.user_id 
            END
            FROM friendships f
            WHERE (f.user_id = ? OR f.friend_id = ?) AND f.status = 'ACCEPTED'
          )
        )
      ORDER BY p.created_at DESC
      ''',
      [currentUserId, currentUserId, currentUserId, currentUserId, currentUserId],
    );

    return results.map((row) => Post.fromRow(row)).toList();
  }

  /// Get Current User's Gallery (RF05)
  static List<Post> getUserGallery(String userId) {
    final results = DatabaseConfig.db.select(
      '''
      SELECT 
        p.*,
        u.name as author_name,
        u.avatar_url as author_avatar,
        (SELECT COUNT(*) FROM reactions r WHERE r.post_id = p.id) as reaction_count,
        (SELECT r.reaction_type FROM reactions r WHERE r.post_id = p.id AND r.user_id = ?) as user_reaction
      FROM posts p
      JOIN users u ON u.id = p.user_id
      WHERE p.user_id = ?
      ORDER BY p.created_at DESC
      ''',
      [userId, userId],
    );

    return results.map((row) => Post.fromRow(row)).toList();
  }

  /// Edit Post Caption (RN09) - Only author can edit
  static Post editPostCaption({
    required String postId,
    required String userId,
    required String newCaption,
  }) {
    final postResult = DatabaseConfig.db.select(
      'SELECT user_id FROM posts WHERE id = ? LIMIT 1',
      [postId],
    );

    if (postResult.isEmpty) {
      throw FormatException('Publicação não encontrada.');
    }

    final authorId = postResult.first['user_id'] as String;
    if (authorId != userId) {
      throw FormatException('Somente o autor da publicação pode editá-la (RN09).');
    }

    // Moderate new caption
    if (ProfanityFilterService.hasProfanity(newCaption)) {
      newCaption = ProfanityFilterService.filter(newCaption);
    }

    DatabaseConfig.db.execute(
      'UPDATE posts SET caption = ? WHERE id = ?',
      [newCaption, postId],
    );

    final updated = DatabaseConfig.db.select(
      '''
      SELECT p.*, u.name as author_name, u.avatar_url as author_avatar
      FROM posts p JOIN users u ON u.id = p.user_id WHERE p.id = ?
      ''',
      [postId],
    );

    return Post.fromRow(updated.first);
  }

  /// Delete Post (RN09, RF09) - Only author can delete
  static void deletePost({
    required String postId,
    required String userId,
  }) {
    final postResult = DatabaseConfig.db.select(
      'SELECT user_id, image_url FROM posts WHERE id = ? LIMIT 1',
      [postId],
    );

    if (postResult.isEmpty) {
      throw FormatException('Publicação não encontrada.');
    }

    final authorId = postResult.first['user_id'] as String;
    if (authorId != userId) {
      throw FormatException('Somente o autor da publicação pode excluí-la (RN09).');
    }

    final imageUrl = postResult.first['image_url'] as String;

    // Delete post record (cascade deletes reactions and reports)
    DatabaseConfig.db.execute(
      'DELETE FROM posts WHERE id = ?',
      [postId],
    );

    // Remove physical file
    try {
      final fileName = imageUrl.split('/').last;
      final filePath = p.join(Directory.current.path, 'uploads', fileName);
      final file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (e) {
      print('⚠️ Erro ao deletar arquivo de imagem do post: $e');
    }
  }
}
