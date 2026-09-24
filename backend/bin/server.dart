import 'dart:convert';
import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_multipart/form_data.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
import 'package:cloudinary_api/src/request/model/uploader_params.dart';

import '../lib/backend_config.dart';
import '../lib/backend_utils.dart';
import '../lib/email_service.dart';

Future<void> main() async {
  cloudinary.config.urlConfig.secure = true;
  // await upload();
  // transform();

  final sessoes = <String, int>{};
  final connection = await MySQLConnection.createConnection(
    host: env['DB_HOST'] ?? '127.0.0.1',
    port: int.tryParse(env['DB_PORT'] ?? '3306') ?? 3306,
    userName: env['DB_USER'] ?? 'root',
    password: env['DB_PASSWORD'] ?? 'senai2026',
    databaseName: env['DB_NAME'] ?? 'snaplock_db',
  );
  await connection.connect();

  final router = Router()
    ..post('/api/login', (Request request) async {
      final dados = await _lerJson(request);
      if (dados == null) return _json(400, {'erro': 'JSON inválido.'});

      final login =
          (dados['login'] ?? dados['email'] ?? dados['username'] ?? '')
              .toString()
              .trim()
              .toLowerCase();
      final senha = dados['senha'] as String? ?? '';
      if (login.isEmpty || senha.isEmpty) {
        return _json(422, {'erro': 'Informe o e-mail ou username e a senha.'});
      }

      final usuarios = await connection.execute(
        '''SELECT id_usuario, nome, username, username_alterado_em, email, senha_hash, biografia, foto_perfil
           FROM usuario
           WHERE (email = :email OR username = :username) AND ativo = 1
           LIMIT 1''',
        {'email': login, 'username': login},
      );
      if (usuarios.rows.isEmpty) {
        return _json(401, {'erro': 'E-mail/usuário ou senha incorretos.'});
      }

      final usuario = usuarios.rows.first.assoc();
      if (!BCrypt.checkpw(senha, usuario['senha_hash']!)) {
        return _json(401, {'erro': 'E-mail/usuário ou senha incorretos.'});
      }

      final token = _gerarTokenSessao();
      sessoes[token] = int.parse(usuario['id_usuario']!);
      return _json(200, {
        'success': true,
        'token': token,
        'user': _usuarioPublico(usuario),
        'id_usuario': int.parse(usuario['id_usuario']!),
        'nome': usuario['nome'],
        'username': usuario['username'],
        'email': usuario['email'],
      });
    })
    ..post('/api/usuarios', (Request request) async {
      final dados = await _lerJson(request);
      if (dados == null) return _json(400, {'erro': 'JSON inválido.'});

      final nome = (dados['nome'] as String? ?? '').trim();
      final username =
          (dados['username'] as String? ?? '').trim().toLowerCase();
      final email = (dados['email'] as String? ?? '').trim().toLowerCase();
      final senha = dados['senha'] as String? ?? '';
      final confirmacaoSenha = dados['confirmacao_senha'] as String? ?? '';
      final dataNascimento = dados['data_nascimento'] as String? ?? '';

      if (nome.isEmpty ||
          nome.length > 100 ||
          !_usernameValido(username) ||
          !_emailValido(email) ||
          email.length > 150 ||
          !_senhaValida(senha) ||
          senha != confirmacaoSenha ||
          !_dataValida(dataNascimento)) {
        return _json(422, {'erro': 'Confira os dados informados.'});
      }
      if (!_idadeMinimaValida(dataNascimento)) {
        return _json(422, {'erro': 'O usuário precisa ter 16 anos ou mais.'});
      }

      try {
        final usernameExistente = await connection.execute(
          'SELECT id_usuario FROM usuario WHERE username = :username LIMIT 1',
          {'username': username},
        );
        if (usernameExistente.rows.isNotEmpty) {
          return _json(409, {'erro': 'Este username já está em uso.'});
        }

        final result = await connection.execute(
          'INSERT INTO usuario (nome, username, email, senha_hash, data_nascimento) VALUES (:nome, :username, :email, :senha_hash, :data_nascimento)',
          {
            'nome': nome,
            'username': username,
            'email': email,
            'senha_hash': BCrypt.hashpw(senha, BCrypt.gensalt()),
            'data_nascimento': dataNascimento,
          },
        );
        return _json(
            201, {'id_usuario': int.parse(result.lastInsertID.toString())});
      } catch (error, stackTrace) {
        final mensagem = error.toString();
        print('Erro ao cadastrar usuário: $mensagem');
        print(stackTrace);
        if (mensagem.toLowerCase().contains('duplicate') ||
            mensagem.toLowerCase().contains('1062')) {
          if (mensagem.toLowerCase().contains('username')) {
            return _json(409, {'erro': 'Este username já está em uso.'});
          }
          return _json(409, {'erro': 'Este e-mail já está cadastrado.'});
        }
        return _json(500, {'erro': 'Erro interno ao salvar o usuário.'});
      }
    })
    ..post('/api/recuperacao/solicitar', (Request request) async {
      final dados = await _lerJson(request);
      final email = (dados?['email'] as String? ?? '').trim().toLowerCase();
      if (!_emailValido(email))
        return _json(422, {'erro': 'Informe um e-mail válido.'});

      final usuarios = await connection.execute(
        'SELECT id_usuario, nome FROM usuario WHERE email = :email AND ativo = 1 LIMIT 1',
        {'email': email},
      );
      if (usuarios.rows.isEmpty)
        return _json(
            200, {'mensagem': 'Se o e-mail existir, um token será enviado.'});

      final linhaUsuario = usuarios.rows.first.assoc();
      final idUsuario = int.parse(linhaUsuario['id_usuario']!);
      final nomeUsuario = linhaUsuario['nome'] ?? 'usuário';

      final recentes = await connection.execute(
        'SELECT enviado_em FROM recuperacao_senha WHERE id_usuario = :id_usuario AND enviado_em > DATE_SUB(NOW(), INTERVAL 30 SECOND) ORDER BY enviado_em DESC LIMIT 1',
        {'id_usuario': idUsuario},
      );
      if (recentes.rows.isNotEmpty)
        return _json(
            429, {'erro': 'Aguarde 30 segundos para solicitar outro token.'});

      final token = _gerarToken();
      try {
        await connection.execute(
          'INSERT INTO recuperacao_senha (id_usuario, token_hash, expira_em) VALUES (:id_usuario, :token_hash, DATE_ADD(NOW(), INTERVAL 15 MINUTE))',
          {'id_usuario': idUsuario, 'token_hash': _hashToken(token)},
        );
        await _enviarToken(email, nomeUsuario, token);
      } catch (error, stackTrace) {
        await connection.execute(
          'DELETE FROM recuperacao_senha WHERE id_usuario = :id_usuario AND token_hash = :token_hash',
          {'id_usuario': idUsuario, 'token_hash': _hashToken(token)},
        );
        print('Erro ao enviar token: $error');
        print(stackTrace);
        return _json(502, {
          'erro':
              'Não foi possível enviar o e-mail. Confira as configurações SMTP.'
        });
      }
      return _json(
          200, {'mensagem': 'Se o e-mail existir, um token será enviado.'});
    })
    ..post('/api/recuperacao/validar-token', (Request request) async {
      final dados = await _lerJson(request);
      final email = (dados?['email'] as String? ?? '').trim().toLowerCase();
      final token = dados?['token'] as String? ?? '';
      if (!_emailValido(email) || token.length != 6) {
        return _json(422, {'erro': 'Token inválido ou expirado.'});
      }

      final resultados = await connection.execute(
        '''SELECT r.id_recuperacao
           FROM recuperacao_senha r JOIN usuario u ON u.id_usuario = r.id_usuario
           WHERE u.email = :email AND r.token_hash = :token_hash
             AND r.usado_em IS NULL AND r.expira_em > NOW()
           ORDER BY r.id_recuperacao DESC LIMIT 1''',
        {'email': email, 'token_hash': _hashToken(token)},
      );
      if (resultados.rows.isEmpty)
        return _json(422, {'erro': 'Token inválido ou expirado.'});
      return _json(200, {'mensagem': 'Token válido.'});
    })
    ..post('/api/recuperacao/redefinir', (Request request) async {
      final dados = await _lerJson(request);
      final email = (dados?['email'] as String? ?? '').trim().toLowerCase();
      final token = dados?['token'] as String? ?? '';
      final novaSenha = dados?['nova_senha'] as String? ?? '';
      final confirmacaoSenha = dados?['confirmacao_senha'] as String? ?? '';
      if (!_emailValido(email) ||
          token.isEmpty ||
          !_senhaValida(novaSenha) ||
          novaSenha != confirmacaoSenha) {
        return _json(422, {'erro': 'Confira os dados informados.'});
      }

      final resultados = await connection.execute(
        '''SELECT r.id_recuperacao, r.id_usuario
           FROM recuperacao_senha r JOIN usuario u ON u.id_usuario = r.id_usuario
           WHERE u.email = :email AND r.token_hash = :token_hash
             AND r.usado_em IS NULL AND r.expira_em > NOW()
           ORDER BY r.id_recuperacao DESC LIMIT 1''',
        {'email': email, 'token_hash': _hashToken(token)},
      );
      if (resultados.rows.isEmpty)
        return _json(422, {'erro': 'Token inválido ou expirado.'});

      final recuperacao = resultados.rows.first.assoc();
      final idRecuperacao = int.parse(recuperacao['id_recuperacao']!);
      final idUsuario = int.parse(recuperacao['id_usuario']!);
      await connection.execute(
          'UPDATE usuario SET senha_hash = :senha_hash WHERE id_usuario = :id_usuario',
          {
            'senha_hash': BCrypt.hashpw(novaSenha, BCrypt.gensalt()),
            'id_usuario': idUsuario
          });
      await connection.execute(
          'UPDATE recuperacao_senha SET usado_em = NOW() WHERE id_recuperacao = :id_recuperacao',
          {'id_recuperacao': idRecuperacao});
      return _json(200, {'mensagem': 'Senha redefinida com sucesso.'});
    })
    ..post('/api/postagens', (Request request) async {
      final idUsuario = _idUsuarioAutenticado(request, sessoes);
      if (idUsuario == null) return _json(401, {'message': 'Sessão inválida.'});

      if (!request.isMultipart) {
        return _json(422, {'message': 'Envie como multipart/form-data.'});
      }

      String? legenda;
      File? tempFile;

      await for (final formData in request.multipartFormData) {
        if (formData.name == 'legenda') {
          legenda = await _coletarString(formData.part);
        } else if (formData.name == 'midia') {
          final bytes = await _coletarBytes(formData.part);
          final contentType = formData.part.headers['content-type'];
          final extensao = _extensaoPorContentType(contentType);
          tempFile = File(
              '${Directory.systemTemp.path}/upload_${DateTime.now().microsecondsSinceEpoch}$extensao');
          await tempFile.writeAsBytes(bytes);
        }
      }

      if (tempFile == null) {
        return _json(422, {
          'message': 'Envie o arquivo no campo "midia" (multipart/form-data).'
        });
      }

      String? midiaUrl;
      try {
        final response = await cloudinary.uploader().upload(
              tempFile,
              params: UploadParams(folder: 'postagens'),
            );
        midiaUrl = response?.data?.secureUrl;
      } catch (error, stackTrace) {
        print('Erro no upload da mídia: $error');
        print(stackTrace);
        return _json(
            502, {'message': 'Falha ao enviar a mídia para o Cloudinary.'});
      } finally {
        if (await tempFile.exists()) await tempFile.delete();
      }

      if (midiaUrl == null) {
        return _json(502, {'message': 'Falha ao processar a mídia.'});
      }

      final result = await connection.execute(
        'INSERT INTO postagem (id_usuario, legenda, midia_url) VALUES (:id_usuario, :legenda, :midia_url)',
        {
          'id_usuario': idUsuario,
          'legenda': legenda ?? '',
          'midia_url': midiaUrl
        },
      );

      return _json(201, {
        'success': true,
        'id_postagem': int.parse(result.lastInsertID.toString()),
        'midia_url': midiaUrl,
      });
    })
    ..post('/api/profile/foto', (Request request) async {
      final idUsuario = _idUsuarioAutenticado(request, sessoes);
      if (idUsuario == null) return _json(401, {'message': 'Sessão inválida.'});

      if (!request.isMultipart) {
        return _json(
            422, {'message': 'Envie o arquivo como multipart/form-data.'});
      }

      File? tempFile;

      await for (final formData in request.multipartFormData) {
        if (formData.name == 'foto') {
          final bytes = await _coletarBytes(formData.part);
          final contentType = formData.part.headers['content-type'];
          final extensao = _extensaoPorContentType(contentType);
          tempFile = File(
              '${Directory.systemTemp.path}/upload_${DateTime.now().microsecondsSinceEpoch}$extensao');
          await tempFile.writeAsBytes(bytes);
        }
      }

      if (tempFile == null) {
        return _json(422, {
          'message': 'Envie o arquivo no campo "foto" (multipart/form-data).'
        });
      }

      String? url;
      try {
        final response = await cloudinary.uploader().upload(
              tempFile,
              params: UploadParams(folder: 'perfil'),
            );

        // DEBUG TEMPORÁRIO
        print('--- DEBUG CLOUDINARY ---');
        print('response.error: ${response?.error?.message}');
        print('response.data: ${response?.data}');
        // print('response.statusCode: ${response?.statusCode}');
        print('------------------------');

        url = response?.data?.secureUrl;
      } catch (error, stackTrace) {
        print('Erro no upload da foto de perfil: $error');
        print(stackTrace);
        return _json(
            502, {'message': 'Falha ao enviar a imagem para o Cloudinary.'});
      } finally {
        if (await tempFile.exists()) await tempFile.delete();
      }

      if (url == null) {
        print('Cloudinary não retornou uma URL para a foto de perfil.');
        return _json(502, {'message': 'Falha ao processar a imagem.'});
      }

      await connection.execute(
        'UPDATE usuario SET foto_perfil = :url WHERE id_usuario = :id_usuario AND ativo = 1',
        {'url': url, 'id_usuario': idUsuario},
      );

      return _json(200, {'success': true, 'foto_perfil': url});
    })
    ..put('/api/profile/password', (Request request) async {
      final idUsuario = _idUsuarioAutenticado(request, sessoes);
      if (idUsuario == null) return _json(401, {'message': 'Sessão inválida.'});

      final dados = await _lerJson(request);
      if (dados == null) return _json(400, {'message': 'JSON inválido.'});

      final senhaAtual = (dados['currentPassword'] ?? '').toString();
      final novaSenha = (dados['newPassword'] ?? '').toString();
      final confirmacaoSenha = (dados['confirmPassword'] ?? '').toString();

      if (senhaAtual.isEmpty || !_senhaValida(novaSenha)) {
        return _json(422, {
          'message': 'A nova senha deve ter 8 caracteres, uma maiúscula, uma minúscula, um número e um caractere especial.'
        });
      }
      if (novaSenha != confirmacaoSenha) {
        return _json(422, {'message': 'As senhas novas não conferem.'});
      }

      final usuarios = await connection.execute(
        'SELECT senha_hash FROM usuario WHERE id_usuario = :id_usuario AND ativo = 1 LIMIT 1',
        {'id_usuario': idUsuario},
      );
      if (usuarios.rows.isEmpty) {
        return _json(404, {'message': 'Usuário não encontrado.'});
      }

      final senhaHash = usuarios.rows.first.assoc()['senha_hash'];
      if (senhaHash == null || !BCrypt.checkpw(senhaAtual, senhaHash)) {
        return _json(401, {'message': 'A senha atual está incorreta.'});
      }

      await connection.execute(
        'UPDATE usuario SET senha_hash = :senha_hash WHERE id_usuario = :id_usuario AND ativo = 1',
        {
          'senha_hash': BCrypt.hashpw(novaSenha, BCrypt.gensalt()),
          'id_usuario': idUsuario,
        },
      );

      return _json(200, {
        'success': true,
        'message': 'Senha alterada com sucesso.',
      });
    })
    ..put('/api/profile', (Request request) async {
      final idUsuario = _idUsuarioAutenticado(request, sessoes);
      if (idUsuario == null) return _json(401, {'message': 'Sessão inválida.'});

      final dados = await _lerJson(request);
      if (dados == null) return _json(400, {'message': 'JSON inválido.'});

      final nome = (dados['name'] ?? '').toString().trim();
      final username = (dados['username'] ?? '').toString().trim().toLowerCase();
      final biografia = (dados['bio'] ?? '').toString().trim();
      if (nome.isEmpty ||
          nome.length > 100 ||
          !_usernameValido(username) ||
          biografia.length > 500) {
        return _json(422, {'message': 'Confira os dados do perfil.'});
      }

      final usernameExistente = await connection.execute(
        '''SELECT id_usuario FROM usuario
           WHERE username = :username AND id_usuario <> :id_usuario
           LIMIT 1''',
        {'username': username, 'id_usuario': idUsuario},
      );
      if (usernameExistente.rows.isNotEmpty) {
        return _json(409, {'message': 'Este username já está em uso.'});
      }

      final usuarioAtual = await connection.execute(
        'SELECT username, username_alterado_em FROM usuario WHERE id_usuario = :id_usuario AND ativo = 1 LIMIT 1',
        {'id_usuario': idUsuario},
      );
      if (usuarioAtual.rows.isEmpty) {
        return _json(404, {'message': 'Usuário não encontrado.'});
      }

      final dadosAtuais = usuarioAtual.rows.first.assoc();
      final usernameAtual = dadosAtuais['username'] ?? '';
      final usernameAlteradoEm = dadosAtuais['username_alterado_em'];
      if (username != usernameAtual && usernameAlteradoEm != null) {
        final liberadoEm = DateTime.parse(usernameAlteradoEm).add(const Duration(days: 30));
        if (DateTime.now().isBefore(liberadoEm)) {
          return _json(422, {
            'message': 'O username só pode ser alterado novamente após 30 dias.',
            'usernameChangedAt': usernameAlteradoEm,
          });
        }
      }

      await connection.execute(
        '''UPDATE usuario
             SET nome = :nome,
               username = :username,
               username_alterado_em = IF(username <> :username, NOW(), username_alterado_em),
               biografia = :biografia
           WHERE id_usuario = :id_usuario AND ativo = 1''',
        {
          'nome': nome,
          'username': username,
          'biografia': biografia,
          'id_usuario': idUsuario,
        },
      );

      final usuarios = await connection.execute(
        '''SELECT id_usuario, nome, username, username_alterado_em, email, biografia, foto_perfil
           FROM usuario WHERE id_usuario = :id_usuario LIMIT 1''',
        {'id_usuario': idUsuario},
      );
      if (usuarios.rows.isEmpty)
        return _json(404, {'message': 'Usuário não encontrado.'});
      final usuario = usuarios.rows.first.assoc();
      return _json(200, {
        'success': true,
        'user': _usuarioPublico(usuario),
      });
    });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_cors())
      .addHandler(router.call);
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4,
      int.tryParse(env['PORT'] ?? '3000') ?? 3000);
  print('SnapLock API em http://${server.address.host}:${server.port}');
}

Middleware _cors() => (handler) => (request) async {
      if (request.method == 'OPTIONS') {
        return Response(204, headers: _corsHeaders);
      }
      final response = await handler(request);
      return response.change(headers: {...response.headers, ..._corsHeaders});
    };

const _corsHeaders = {
  'access-control-allow-origin': '*',
  'access-control-allow-headers': 'Content-Type, Authorization',
  'access-control-allow-methods': 'GET, POST, PUT, DELETE, OPTIONS',
};

Future<Map<String, dynamic>?> _lerJson(Request request) => readJson(request);

Future<List<int>> _coletarBytes(Stream<List<int>> stream) async {
  final bytes = <int>[];
  await for (final chunk in stream) {
    bytes.addAll(chunk);
  }
  return bytes;
}

Future<String> _coletarString(Stream<List<int>> stream) =>
    utf8.decoder.bind(stream).join();

String _extensaoPorContentType(String? contentType) =>
    extensionForContentType(contentType);

Response _json(int status, Map<String, Object?> body) =>
  jsonResponse(status, body, jsonHeaders);

Map<String, String> _usuarioPublico(Map<String, String?> usuario) =>
    publicUser(usuario);

bool _emailValido(String email) => validEmail(email);

bool _usernameValido(String username) => validUsername(username);

bool _senhaValida(String senha) => validPassword(senha);

String _gerarToken() => generateRecoveryToken();

String _hashToken(String token) => hashToken(token);

String _gerarTokenSessao() => generateSessionToken();

int? _idUsuarioAutenticado(Request request, Map<String, int> sessoes) =>
    authenticatedUserId(request, sessoes);

Future<void> _enviarToken(
  String email,
  String nomeUsuario,
  String token,
) => sendRecoveryToken(email, nomeUsuario, token);

bool _dataValida(String value) => validDate(value);

bool _idadeMinimaValida(String value) => validMinimumAge(value);
