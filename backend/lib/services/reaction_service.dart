import 'package:uuid/uuid.dart';
import '../config/database.dart';
import '../models/reaction.dart';

class ReactionService {
  static final _uuid = const Uuid();

  /// Add or update reaction on a post (RN16, RF13)
  /// Enforces 1 reaction per user per post. Editing or re-reacting updates existing reaction.
  static Reaction setReaction({
    required String postId,
    required String userId,
    required String reactionType,
  }) {
    // 1. Verify post exists & user is allowed to view it (author or accepted friend)
    final postCheck = DatabaseConfig.db.select(
      'SELECT user_id FROM posts WHERE id = ? LIMIT 1',
      [postId],
    );

    if (postCheck.isEmpty) {
      throw FormatException('Publicação não encontrada.');
    }

    final authorId = postCheck.first['user_id'] as String;

    if (authorId != userId) {
      final friendship = DatabaseConfig.db.select(
        '''
        SELECT id FROM friendships
        WHERE status = 'ACCEPTED'
          AND ((user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?))
        LIMIT 1
        ''',
        [userId, authorId, authorId, userId],
      );

      if (friendship.isEmpty) {
        throw FormatException('Você só pode reagir a postagens de seus amigos autorizados (RN13).');
      }
    }

    // 2. Insert or Replace reaction (RN16)
    final existing = DatabaseConfig.db.select(
      'SELECT id FROM reactions WHERE post_id = ? AND user_id = ? LIMIT 1',
      [postId, userId],
    );

    final createdAt = DateTime.now().toIso8601String();
    late String reactionId;

    if (existing.isNotEmpty) {
      reactionId = existing.first['id'] as String;
      DatabaseConfig.db.execute(
        'UPDATE reactions SET reaction_type = ?, created_at = ? WHERE id = ?',
        [reactionType, createdAt, reactionId],
      );
    } else {
      reactionId = _uuid.v4();
      DatabaseConfig.db.execute(
        '''
        INSERT INTO reactions (id, post_id, user_id, reaction_type, created_at)
        VALUES (?, ?, ?, ?, ?)
        ''',
        [reactionId, postId, userId, reactionType, createdAt],
      );
    }

    return Reaction(
      id: reactionId,
      postId: postId,
      userId: userId,
      reactionType: reactionType,
      createdAt: createdAt,
    );
  }

  /// Remove reaction from a post (RN16)
  static void removeReaction({
    required String postId,
    required String userId,
  }) {
    DatabaseConfig.db.execute(
      'DELETE FROM reactions WHERE post_id = ? AND user_id = ?',
      [postId, userId],
    );
  }

  /// List reactions for a post
  static List<Reaction> getPostReactions(String postId) {
    final results = DatabaseConfig.db.select(
      'SELECT * FROM reactions WHERE post_id = ? ORDER BY created_at DESC',
      [postId],
    );

    return results.map((row) => Reaction.fromRow(row)).toList();
  }
}
