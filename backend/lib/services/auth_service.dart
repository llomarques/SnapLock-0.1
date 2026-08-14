import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:uuid/uuid.dart';
import '../config/database.dart';
import '../models/user.dart';
import '../utils/age_calculator.dart';
import '../utils/password_validator.dart';

class AuthService {
  static final _uuid = const Uuid();

  /// Register a new user (RN01, RN04, RN07, RN08, RF02)
  static Map<String, dynamic> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String birthdate,
    String bio = '',
    String gender = '',
  }) {
    // 1. Password confirmation check (RN04)
    if (password != confirmPassword) {
      throw FormatException('A senha e a confirmação de senha não coincidem.');
    }

    // 2. Password complexity validation (RN07)
    final passwordError = PasswordValidator.validate(password);
    if (passwordError != null) {
      throw FormatException(passwordError);
    }

    // 3. Minimum age check >= 16 (RN01)
    final parsedBirthdate = AgeCalculator.parseBirthdate(birthdate);
    if (parsedBirthdate == null) {
      throw FormatException('Data de nascimento inválida. Use o formato YYYY-MM-DD.');
    }
    if (!AgeCalculator.isAtLeast16(parsedBirthdate)) {
      throw FormatException('Somente usuários maiores de 16 anos podem se cadastrar no aplicativo (RN01).');
    }

    // 4. Email uniqueness check (RN08)
    final existingUser = DatabaseConfig.db.select(
      'SELECT id FROM users WHERE email = ? LIMIT 1',
      [email.trim().toLowerCase()],
    );
    if (existingUser.isNotEmpty) {
      throw FormatException('Já existe um usuário cadastrado com este e-mail (RN08).');
    }

    // 5. Password hashing (RNF03)
    final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

    // 6. Save user to SQLite DB
    final userId = _uuid.v4();
    final createdAt = DateTime.now().toIso8601String();

    DatabaseConfig.db.execute(
      '''
      INSERT INTO users (id, name, email, password_hash, birthdate, bio, gender, is_active, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, 1, ?)
      ''',
      [userId, name.trim(), email.trim().toLowerCase(), passwordHash, birthdate, bio.trim(), gender.trim(), createdAt],
    );

    final userObj = User(
      id: userId,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      birthdate: birthdate,
      bio: bio.trim(),
      gender: gender.trim(),
      createdAt: createdAt,
    );

    return {'user': userObj.toJson()};
  }

  /// Login user with email & password (RN06, RF01)
  static Map<String, dynamic> login(String email, String password) {
    final results = DatabaseConfig.db.select(
      'SELECT * FROM users WHERE email = ? AND is_active = 1 LIMIT 1',
      [email.trim().toLowerCase()],
    );

    if (results.isEmpty) {
      throw FormatException('E-mail ou senha incorretos.');
    }

    final row = results.first;
    final storedHash = row['password_hash'] as String;

    if (!BCrypt.checkpw(password, storedHash)) {
      throw FormatException('E-mail ou senha incorretos.');
    }

    final userObj = User.fromRow(row);
    return {'user': userObj.toJson()};
  }

  /// Request password reset token (RN05, RF04)
  static Map<String, dynamic> forgotPassword(String email) {
    final results = DatabaseConfig.db.select(
      'SELECT id FROM users WHERE email = ? AND is_active = 1 LIMIT 1',
      [email.trim().toLowerCase()],
    );

    if (results.isEmpty) {
      throw FormatException('Nenhum usuário ativo encontrado com este e-mail.');
    }

    final userId = results.first['id'] as String;
    final now = DateTime.now();

    // Check 30 seconds cooldown rule (RN05)
    final existingReset = DatabaseConfig.db.select(
      'SELECT last_sent_at FROM password_resets WHERE user_id = ? ORDER BY last_sent_at DESC LIMIT 1',
      [userId],
    );

    if (existingReset.isNotEmpty) {
      final lastSent = DateTime.parse(existingReset.first['last_sent_at'] as String);
      final secondsSince = now.difference(lastSent).inSeconds;
      if (secondsSince < 30) {
        final remaining = 30 - secondsSince;
        throw FormatException('Aguarde $remaining segundos antes de solicitar um novo token (RN05).');
      }
    }

    // Generate token valid for 15 minutes (RN05)
    final token = (100000 + (now.microsecondsSinceEpoch % 900000)).toString();
    final expiresAt = now.add(const Duration(minutes: 15)).toIso8601String();
    final lastSentAt = now.toIso8601String();
    final resetId = _uuid.v4();

    DatabaseConfig.db.execute(
      '''
      INSERT INTO password_resets (id, user_id, token, expires_at, last_sent_at)
      VALUES (?, ?, ?, ?, ?)
      ''',
      [resetId, userId, token, expiresAt, lastSentAt],
    );

    print('📧 [SIMULAÇÃO DE EMAIL] Token de redefinição para $email: $token (Válido até 15 min)');

    return {
      'message': 'Token de redefinição de senha enviado para seu e-mail.',
      'token': token, // Exposto no retorno para facilitar testes em dev
      'expiresInMinutes': 15,
    };
  }

  /// Reset password using token (RN05, RN14)
  static void resetPassword(String email, String token, String newPassword) {
    // Validate password complexity
    final passwordError = PasswordValidator.validate(newPassword);
    if (passwordError != null) {
      throw FormatException(passwordError);
    }

    final results = DatabaseConfig.db.select(
      '''
      SELECT pr.id, pr.expires_at, pr.user_id
      FROM password_resets pr
      JOIN users u ON u.id = pr.user_id
      WHERE u.email = ? AND pr.token = ?
      ORDER BY pr.last_sent_at DESC LIMIT 1
      ''',
      [email.trim().toLowerCase(), token.trim()],
    );

    if (results.isEmpty) {
      throw FormatException('Token de redefinição inválido.');
    }

    final row = results.first;
    final expiresAt = DateTime.parse(row['expires_at'] as String);

    if (DateTime.now().isAfter(expiresAt)) {
      throw FormatException('Token de redefinição expirou. Solicite um novo token (RN05).');
    }

    final userId = row['user_id'] as String;
    final newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());

    // Update password
    DatabaseConfig.db.execute(
      'UPDATE users SET password_hash = ? WHERE id = ?',
      [newHash, userId],
    );

    // Clear used reset tokens
    DatabaseConfig.db.execute(
      'DELETE FROM password_resets WHERE user_id = ?',
      [userId],
    );
  }

  /// Get Profile (RF05)
  static User getProfile(String userId) {
    final results = DatabaseConfig.db.select(
      'SELECT * FROM users WHERE id = ? AND is_active = 1 LIMIT 1',
      [userId],
    );

    if (results.isEmpty) {
      throw FormatException('Usuário não encontrado.');
    }

    return User.fromRow(results.first);
  }

  /// Update Profile (RF06)
  static User updateProfile({
    required String userId,
    required String name,
    required String bio,
    required String gender,
    String? avatarUrl,
  }) {
    DatabaseConfig.db.execute(
      '''
      UPDATE users
      SET name = ?, bio = ?, gender = ? ${avatarUrl != null ? ', avatar_url = ?' : ''}
      WHERE id = ?
      ''',
      avatarUrl != null
          ? [name.trim(), bio.trim(), gender.trim(), avatarUrl, userId]
          : [name.trim(), bio.trim(), gender.trim(), userId],
    );

    return getProfile(userId);
  }

  /// Change Password (RN14)
  static void changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) {
    final results = DatabaseConfig.db.select(
      'SELECT password_hash FROM users WHERE id = ? LIMIT 1',
      [userId],
    );

    if (results.isEmpty) {
      throw FormatException('Usuário não encontrado.');
    }

    final currentHash = results.first['password_hash'] as String;
    if (!BCrypt.checkpw(currentPassword, currentHash)) {
      throw FormatException('Senha atual incorreta.');
    }

    final passwordError = PasswordValidator.validate(newPassword);
    if (passwordError != null) {
      throw FormatException(passwordError);
    }

    final newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
    DatabaseConfig.db.execute(
      'UPDATE users SET password_hash = ? WHERE id = ?',
      [newHash, userId],
    );
  }

  /// Delete Account Permanently (RN10, RF07)
  static void deleteAccount(String userId) {
    // Retrieve image URLs to delete physical files from storage
    final posts = DatabaseConfig.db.select(
      'SELECT image_url FROM posts WHERE user_id = ?',
      [userId],
    );

    for (final row in posts) {
      final imageUrl = row['image_url'] as String;
      _deletePhysicalFile(imageUrl);
    }

    // Delete user (Foreign keys ON DELETE CASCADE will auto-delete posts, reactions, friendships, reports, resets)
    DatabaseConfig.db.execute(
      'DELETE FROM users WHERE id = ?',
      [userId],
    );
  }

  static void _deletePhysicalFile(String fileRelativeUrl) {
    try {
      final fileName = fileRelativeUrl.split('/').last;
      final filePath = pJoin(Directory.current.path, 'uploads', fileName);
      final file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (e) {
      print('⚠️ Não foi possível excluir o arquivo de imagem: $e');
    }
  }

  static String pJoin(String p1, String p2, String p3) {
    return '$p1${Platform.pathSeparator}$p2${Platform.pathSeparator}$p3';
  }
}
