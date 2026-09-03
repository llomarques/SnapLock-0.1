import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class ApiService {
  static const String _tokenKey = 'snaplock_jwt_token';
  static const String _userKey = 'snaplock_user_json';

  static String? _currentToken;
  static UserModel? _currentUser;

  static UserModel? get currentUser => _currentUser;
  static String? get token => _currentToken;

  /// Inicializa sessão salva no SharedPreferences
  static Future<bool> initSession() async {
    final prefs = await SharedPreferences.getInstance();
    _currentToken = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);

    if (_currentToken != null && userJson != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
        return true;
      } catch (_) {
        await logout();
        return false;
      }
    }
    return false;
  }

  static Future<void> _saveSession(String token, Map<String, dynamic> userMap) async {
    _currentToken = token;
    _currentUser = UserModel.fromJson(userMap);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(userMap));
  }

  static Future<void> logout() async {
    _currentToken = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json; charset=utf-8'};
    if (_currentToken != null) {
      headers['Authorization'] = 'Bearer $_currentToken';
    }
    return headers;
  }

  // --- AUTENTICAÇÃO ---

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String birthdate,
    String bio = '',
    String gender = '',
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/usuarios'),
      headers: _headers,
      body: jsonEncode({
        'nome': name,
        'email': email,
        'senha': password,
        'confirmacao_senha': confirmPassword,
        'data_nascimento': birthdate,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['erro'] ?? 'Erro no cadastro.');
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['success'] == true) {
      final token = data['token'] as String;
      final userMap = data['user'] as Map<String, dynamic>;
      await _saveSession(token, userMap);
      return data;
    } else {
      throw Exception(data['message'] ?? 'E-mail ou senha incorretos.');
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/recuperacao/solicitar'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['erro'] ?? 'Erro ao solicitar token.');
    }
  }

  static Future<void> resetPassword(String email, String token, String newPassword) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/recuperacao/redefinir'),
      headers: _headers,
      body: jsonEncode({'email': email, 'token': token, 'nova_senha': newPassword, 'confirmacao_senha': newPassword}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['erro'] ?? 'Erro ao redefinir senha.');
    }
  }

  // --- PERFIL ---

  static Future<UserModel> updateProfile({
    required String name,
    required String bio,
    required String gender,
    String? avatarUrl,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/profile'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'bio': bio,
        'gender': gender,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] == true) {
      final userMap = data['user'] as Map<String, dynamic>;
      _currentUser = UserModel.fromJson(userMap);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(userMap));
      return _currentUser!;
    } else {
      throw Exception(data['message'] ?? 'Erro ao atualizar perfil.');
    }
  }

  static Future<void> changePassword(String currentPassword, String newPassword) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/profile/password'),
      headers: _headers,
      body: jsonEncode({'currentPassword': currentPassword, 'newPassword': newPassword}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Erro ao alterar senha.');
    }
  }

  static Future<void> deleteAccount() async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/profile'),
      headers: _headers,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] == true) {
      await logout();
    } else {
      throw Exception(data['message'] ?? 'Erro ao excluir conta.');
    }
  }

  // --- FEED & POSTAGENS ---

  static Future<List<PostModel>> getFeed() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/feed'),
      headers: _headers,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] == true) {
      final list = data['posts'] as List;
      return list.map((item) => PostModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception(data['message'] ?? 'Erro ao carregar o feed.');
    }
  }

  static Future<List<PostModel>> getMyGallery() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/posts/my-gallery'),
      headers: _headers,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] == true) {
      final list = data['posts'] as List;
      return list.map((item) => PostModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception(data['message'] ?? 'Erro ao carregar galeria.');
    }
  }

  static Future<PostModel> createPost(String imageBase64, String caption, String fileName) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/posts'),
      headers: _headers,
      body: jsonEncode({
        'imageBase64': imageBase64,
        'caption': caption,
        'fileName': fileName,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 201 && data['success'] == true) {
      return PostModel.fromJson(data['post'] as Map<String, dynamic>);
    } else {
      throw Exception(data['message'] ?? 'Erro ao criar publicação.');
    }
  }

  static Future<void> deletePost(String postId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/posts/$postId'),
      headers: _headers,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Erro ao excluir post.');
    }
  }

  static Future<void> reactToPost(String postId, String reactionType) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/posts/$postId/reactions'),
      headers: _headers,
      body: jsonEncode({'reactionType': reactionType}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Erro ao reagir à publicação.');
    }
  }

  static Future<void> removeReaction(String postId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/posts/$postId/reactions'),
      headers: _headers,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Erro ao remover reação.');
    }
  }

  // --- AMIZADES ---

  static Future<List<UserModel>> searchUsers(String query) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/friends/search?q=${Uri.encodeComponent(query)}'),
      headers: _headers,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] == true) {
      final list = data['users'] as List;
      return list.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception(data['message'] ?? 'Erro ao buscar usuários.');
    }
  }

  static Future<void> sendFriendRequest(String friendId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/friends/request'),
      headers: _headers,
      body: jsonEncode({'friendId': friendId}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Erro ao enviar solicitação.');
    }
  }

  static Future<void> acceptFriendRequest(String requestId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/friends/accept'),
      headers: _headers,
      body: jsonEncode({'requestId': requestId}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Erro ao aceitar solicitação.');
    }
  }

  static Future<void> declineFriendRequest(String requestId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/friends/decline'),
      headers: _headers,
      body: jsonEncode({'requestId': requestId}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Erro ao recusar solicitação.');
    }
  }

  static Future<void> removeFriend(String friendId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/friends/$friendId'),
      headers: _headers,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Erro ao remover amigo.');
    }
  }

  static Future<List<UserModel>> getFriends() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/friends'),
      headers: _headers,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] == true) {
      final list = data['friends'] as List;
      return list.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception(data['message'] ?? 'Erro ao carregar lista de amigos.');
    }
  }

  static Future<List<Map<String, dynamic>>> getPendingRequests() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/friends/pending'),
      headers: _headers,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] == true) {
      final list = data['pending'] as List;
      return list.cast<Map<String, dynamic>>();
    } else {
      throw Exception(data['message'] ?? 'Erro ao carregar solicitações pendentes.');
    }
  }

  // --- DENÚNCIAS & DUMPS ---

  static Future<void> reportPost(String postId, String reason) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/reports'),
      headers: _headers,
      body: jsonEncode({'postId': postId, 'reason': reason}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Erro ao enviar denúncia.');
    }
  }

  static Future<List<Map<String, dynamic>>> getMonthlyDumps() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/dumps/monthly'),
      headers: _headers,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] == true) {
      final list = data['dumps'] as List;
      return list.cast<Map<String, dynamic>>();
    } else {
      throw Exception(data['message'] ?? 'Erro ao carregar retrospectivas.');
    }
  }

  static Future<Map<String, dynamic>> generateMonthlyDump() async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/dumps/generate'),
      headers: _headers,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] == true) {
      return data['dump'] as Map<String, dynamic>;
    } else {
      throw Exception(data['message'] ?? 'Erro ao gerar dump.');
    }
  }
}
