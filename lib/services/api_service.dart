import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../controller/controller.login.dart';
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

  static Future<void> _saveSession(
      String token, Map<String, dynamic> userMap) async {
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

  static Map<String, String> get _friendHeaders {
    final headers = _headers;
    final loginToken = LoginController.tokenAtual;
    if (loginToken != null && loginToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $loginToken';
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

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
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

  static Future<void> resetPassword(
      String email, String token, String newPassword) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/recuperacao/redefinir'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'token': token,
        'nova_senha': newPassword,
        'confirmacao_senha': newPassword
      }),
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

  static Future<void> changePassword(
    String currentPassword,
    String newPassword, {
    String? confirmPassword,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/profile/password'),
      headers: _headers,
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword ?? newPassword,
      }),
    );

    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      } else if (decoded is Map) {
        data = Map<String, dynamic>.from(decoded);
      }
    } on FormatException {
      throw Exception(
          'Resposta inválida da API. Verifique o backend e o token de sessão.');
    }

    if (data['success'] != true) {
      throw Exception(
          data['message'] ?? data['erro'] ?? 'Erro ao alterar senha.');
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
      headers: _friendHeaders,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] == true) {
      final list = data['posts'] as List;
      return list
          .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(data['message'] ?? 'Erro ao carregar o feed.');
    }
  }

  static Future<List<PostModel>> getMyGallery() async {
    final url = '${ApiConfig.baseUrl}/fotos/minhas';


    final response = await http.get(
      Uri.parse(url),
      headers: _friendHeaders,
    );


    if (response.statusCode != 200) {
      throw Exception(
        'Erro HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['success'] == true) {
      final list = data['fotos'] as List;

      return list.map((item) {
        final foto = item as Map<String, dynamic>;

        return PostModel(
          id: foto['id_foto'].toString(),
          userId: foto['id_usuario'].toString(),
          imageUrl: foto['midia_url']?.toString() ?? '',
          caption: foto['legenda']?.toString() ?? '',
          createdAt: foto['data_postagem']?.toString() ?? '',
          aspectRatio: double.tryParse(foto['proporcao']?.toString() ?? ''),
        );
      }).toList();
    }

    throw Exception(
      data['message']?.toString() ?? 'Erro ao carregar galeria.',
    );
  }

  static Future<List<PostModel>> getFriendGallery(String friendId) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/friends/${Uri.encodeComponent(friendId)}/fotos',
      ),
      headers: _friendHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Erro ao carregar fotos do amigo.');
    }

    final fotos = data['fotos'] as List;
    return fotos.map((item) {
      final foto = item as Map<String, dynamic>;
      return PostModel(
        id: foto['id_foto']?.toString() ?? '',
        userId: foto['id_usuario']?.toString() ?? '',
        imageUrl: foto['midia_url']?.toString() ?? '',
        caption: foto['legenda']?.toString() ?? '',
        createdAt: foto['data_postagem']?.toString() ?? '',
        authorName: foto['nome']?.toString(),
        authorAvatar: foto['foto_perfil']?.toString(),
      );
    }).toList();
  }

  static Future<Map<String, dynamic>> createPost(
    String imageBase64,
    String caption,
    String fileName,
  ) {
    return createPostFromBytes(
      base64Decode(imageBase64),
      caption,
      fileName: fileName,
    );
  }

  static Future<Map<String, dynamic>> createPostFromBytes(
    Uint8List imageBytes,
    String caption, {
    String? filtroAplicado,
    String fileName = 'postagem.jpg',
    double? aspectRatio,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/fotos'),
    )
      ..fields['legenda'] = caption
      ..fields['filtro_aplicado'] = filtroAplicado ?? ''
      ..fields['proporcao'] = aspectRatio?.toString() ?? ''
      ..files.add(
        http.MultipartFile.fromBytes(
          'midia',
          imageBytes,
          filename: fileName,
        ),
      );

    final loginToken = LoginController.tokenAtual;
    final token = loginToken != null && loginToken.isNotEmpty
        ? loginToken
        : _currentToken;
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } on FormatException {
      throw Exception(
        'Erro HTTP ${response.statusCode}: ${response.body.trim()}',
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        data['success'] != true) {
      throw Exception(data['message'] ?? 'Erro ao publicar a memória.');
    }
    return data;
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
      Uri.parse(
          '${ApiConfig.baseUrl}/friends/search?q=${Uri.encodeComponent(query)}'),
      headers: _friendHeaders,
    );

    final decoded = jsonDecode(response.body);
    final data =
        decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (data['success'] == true) {
      final list = data['users'] as List;
      return list
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
          data['message'] ?? data['erro'] ?? 'Erro ao buscar usuários.');
    }
  }

  static Future<void> sendFriendRequest(String friendId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/friends/request'),
      headers: _friendHeaders,
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
      headers: _friendHeaders,
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
      headers: _friendHeaders,
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
      headers: _friendHeaders,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Erro ao remover amigo.');
    }
  }

  static Future<List<UserModel>> getFriends() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/friends'),
      headers: _friendHeaders,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] == true) {
      final list = data['friends'] as List;
      return list
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(data['message'] ?? 'Erro ao carregar lista de amigos.');
    }
  }

  static Future<List<Map<String, dynamic>>> getPendingRequests() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/friends/pending'),
      headers: _friendHeaders,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] == true) {
      final list = data['pending'] as List;
      return list.cast<Map<String, dynamic>>();
    } else {
      throw Exception(
          data['message'] ?? 'Erro ao carregar solicitações pendentes.');
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

  static Future<List<PostModel>> getFotos() => getMyGallery();
}
