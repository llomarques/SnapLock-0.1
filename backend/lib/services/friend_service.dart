import 'package:uuid/uuid.dart';
import '../config/database.dart';
import '../models/user.dart';

class FriendService {
  static final _uuid = const Uuid();

  /// Search active users (RN17, RF14)
  static List<User> searchUsers(String query, String currentUserId) {
    if (query.trim().isEmpty) return [];

    final searchTerm = '%${query.trim().toLowerCase()}%';
    final results = DatabaseConfig.db.select(
      '''
      SELECT * FROM users
      WHERE is_active = 1
        AND id != ?
        AND (LOWER(name) LIKE ? OR LOWER(email) LIKE ?)
      ORDER BY name ASC LIMIT 20
      ''',
      [currentUserId, searchTerm, searchTerm],
    );

    return results.map((row) => User.fromRow(row)).toList();
  }

  /// Send friend request
  static void sendRequest(String currentUserId, String friendId) {
    if (currentUserId == friendId) {
      throw FormatException('Você não pode enviar uma solicitação de amizade para você mesmo.');
    }

    // Check if target user is active (RN17)
    final target = DatabaseConfig.db.select(
      'SELECT id FROM users WHERE id = ? AND is_active = 1 LIMIT 1',
      [friendId],
    );
    if (target.isEmpty) {
      throw FormatException('Usuário não encontrado ou inativo.');
    }

    // Check existing relationship
    final existing = DatabaseConfig.db.select(
      '''
      SELECT status FROM friendships
      WHERE (user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)
      LIMIT 1
      ''',
      [currentUserId, friendId, friendId, currentUserId],
    );

    if (existing.isNotEmpty) {
      final status = existing.first['status'] as String;
      if (status == 'ACCEPTED') {
        throw FormatException('Vocês já são amigos.');
      } else {
        throw FormatException('Já existe uma solicitação de amizade pendente entre vocês.');
      }
    }

    final id = _uuid.v4();
    final createdAt = DateTime.now().toIso8601String();

    DatabaseConfig.db.execute(
      '''
      INSERT INTO friendships (id, user_id, friend_id, status, created_at)
      VALUES (?, ?, ?, 'PENDING', ?)
      ''',
      [id, currentUserId, friendId, createdAt],
    );
  }

  /// Accept friend request
  static void acceptRequest(String currentUserId, String requestId) {
    final result = DatabaseConfig.db.select(
      'SELECT * FROM friendships WHERE id = ? AND friend_id = ? AND status = \'PENDING\' LIMIT 1',
      [requestId, currentUserId],
    );

    if (result.isEmpty) {
      throw FormatException('Solicitação de amizade não encontrada ou já processada.');
    }

    DatabaseConfig.db.execute(
      'UPDATE friendships SET status = \'ACCEPTED\' WHERE id = ?',
      [requestId],
    );
  }

  /// Decline friend request
  static void declineRequest(String currentUserId, String requestId) {
    DatabaseConfig.db.execute(
      'DELETE FROM friendships WHERE id = ? AND friend_id = ? AND status = \'PENDING\'',
      [requestId, currentUserId],
    );
  }

  /// Remove friend
  static void removeFriend(String currentUserId, String friendId) {
    DatabaseConfig.db.execute(
      '''
      DELETE FROM friendships
      WHERE (user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)
      ''',
      [currentUserId, friendId, friendId, currentUserId],
    );
  }

  /// List accepted friends
  static List<User> getFriends(String userId) {
    final results = DatabaseConfig.db.select(
      '''
      SELECT u.* FROM users u
      JOIN friendships f ON (
        (f.user_id = ? AND f.friend_id = u.id) OR
        (f.friend_id = ? AND f.user_id = u.id)
      )
      WHERE f.status = 'ACCEPTED' AND u.is_active = 1
      ORDER BY u.name ASC
      ''',
      [userId, userId],
    );

    return results.map((row) => User.fromRow(row)).toList();
  }

  /// List pending requests received by the user
  static List<Map<String, dynamic>> getPendingRequests(String userId) {
    final results = DatabaseConfig.db.select(
      '''
      SELECT f.id as request_id, f.created_at, u.id as user_id, u.name, u.email, u.avatar_url
      FROM friendships f
      JOIN users u ON u.id = f.user_id
      WHERE f.friend_id = ? AND f.status = 'PENDING' AND u.is_active = 1
      ORDER BY f.created_at DESC
      ''',
      [userId],
    );

    return results.map((row) => {
      'requestId': row['request_id'] as String,
      'createdAt': row['created_at'] as String,
      'sender': {
        'id': row['user_id'] as String,
        'name': row['name'] as String,
        'email': row['email'] as String,
        'avatarUrl': row['avatar_url'] as String?,
      }
    }).toList();
  }
}
