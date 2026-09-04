import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

Future<void> main() async {
  final connection = await MySQLConnection.createConnection(
    host: Platform.environment['DB_HOST'] ?? '127.0.0.1',
    port: int.tryParse(Platform.environment['DB_PORT'] ?? '3306') ?? 3306,
    userName: Platform.environment['DB_USER'] ?? 'root',
    password: Platform.environment['DB_PASSWORD'] ?? 'senai2026',
    databaseName: Platform.environment['DB_NAME'] ?? 'snaplock_db',
  );
  await connection.connect();

  final router = Router()
    ..post('/api/usuarios', (Request request) async {
      final dados = await _lerJson(request);
      if (dados == null) return _json(400, {'erro': 'JSON inválido.'});

      final nome = (dados['nome'] as String? ?? '').trim();
      final username = (dados['username'] as String? ?? '').trim().toLowerCase();
      final email = (dados['email'] as String? ?? '').trim().toLowerCase();
      final senha = dados['senha'] as String? ?? '';
      final confirmacaoSenha = dados['confirmacao_senha'] as String? ?? '';
      final dataNascimento = dados['data_nascimento'] as String? ?? '';

      if (nome.isEmpty || nome.length > 100 || !_usernameValido(username) || !_emailValido(email) || email.length > 150 || !_senhaValida(senha) || senha != confirmacaoSenha || !_dataValida(dataNascimento)) {
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
        return _json(201, {'id_usuario': int.parse(result.lastInsertID.toString())});
      } catch (error, stackTrace) {
        final mensagem = error.toString();
        print('Erro ao cadastrar usuário: $mensagem');
        print(stackTrace);
        if (mensagem.toLowerCase().contains('duplicate') || mensagem.toLowerCase().contains('1062')) {
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
      if (!_emailValido(email)) return _json(422, {'erro': 'Informe um e-mail válido.'});

      final usuarios = await connection.execute(
        'SELECT id_usuario, nome FROM usuario WHERE email = :email AND ativo = 1 LIMIT 1',
        {'email': email},
      );
      if (usuarios.rows.isEmpty) return _json(200, {'mensagem': 'Se o e-mail existir, um token será enviado.'});

      final linhaUsuario = usuarios.rows.first.assoc();
      final idUsuario = int.parse(linhaUsuario['id_usuario']!);
      final nomeUsuario = linhaUsuario['nome'] ?? 'usuário';

      final recentes = await connection.execute(
        'SELECT enviado_em FROM recuperacao_senha WHERE id_usuario = :id_usuario AND enviado_em > DATE_SUB(NOW(), INTERVAL 30 SECOND) ORDER BY enviado_em DESC LIMIT 1',
        {'id_usuario': idUsuario},
      );
      if (recentes.rows.isNotEmpty) return _json(429, {'erro': 'Aguarde 30 segundos para solicitar outro token.'});

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
        return _json(502, {'erro': 'Não foi possível enviar o e-mail. Confira as configurações SMTP.'});
      }
      return _json(200, {'mensagem': 'Se o e-mail existir, um token será enviado.'});
    })
    ..post('/api/recuperacao/redefinir', (Request request) async {
      final dados = await _lerJson(request);
      final email = (dados?['email'] as String? ?? '').trim().toLowerCase();
      final token = dados?['token'] as String? ?? '';
      final novaSenha = dados?['nova_senha'] as String? ?? '';
      final confirmacaoSenha = dados?['confirmacao_senha'] as String? ?? '';
      if (!_emailValido(email) || token.isEmpty || !_senhaValida(novaSenha) || novaSenha != confirmacaoSenha) {
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
      if (resultados.rows.isEmpty) return _json(422, {'erro': 'Token inválido ou expirado.'});

      final recuperacao = resultados.rows.first.assoc();
      final idRecuperacao = int.parse(recuperacao['id_recuperacao']!);
      final idUsuario = int.parse(recuperacao['id_usuario']!);
      await connection.execute('UPDATE usuario SET senha_hash = :senha_hash WHERE id_usuario = :id_usuario', {'senha_hash': BCrypt.hashpw(novaSenha, BCrypt.gensalt()), 'id_usuario': idUsuario});
      await connection.execute('UPDATE recuperacao_senha SET usado_em = NOW() WHERE id_recuperacao = :id_recuperacao', {'id_recuperacao': idRecuperacao});
      return _json(200, {'mensagem': 'Senha redefinida com sucesso.'});
    });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_cors())
      .addHandler(router.call);
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, int.tryParse(Platform.environment['PORT'] ?? '3000') ?? 3000);
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
  'access-control-allow-headers': 'Content-Type',
  'access-control-allow-methods': 'POST, OPTIONS',
};

Future<Map<String, dynamic>?> _lerJson(Request request) async {
  try {
    final body = jsonDecode(await request.readAsString());
    return body is Map<String, dynamic> ? body : null;
  } on FormatException {
    return null;
  }
}

Response _json(int status, Map<String, Object?> body) => Response(status, body: jsonEncode(body), headers: {'content-type': 'application/json; charset=utf-8'});

bool _emailValido(String email) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

bool _usernameValido(String username) => RegExp(r'^[a-z0-9_]{3,30}$').hasMatch(username);

bool _senhaValida(String senha) => RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$').hasMatch(senha);

String _gerarToken() => (100000 + Random.secure().nextInt(900000)).toString();

String _hashToken(String token) => sha256.convert(utf8.encode(token)).toString();

Future<void> _enviarToken(String email, String nomeUsuario, String token) async {
  final host = Platform.environment['SMTP_HOST'];
  final username = Platform.environment['SMTP_USER'];
  final password = Platform.environment['SMTP_PASSWORD'];
  if (host == null || username == null || password == null) {
    throw StateError('Configure SMTP_HOST, SMTP_USER e SMTP_PASSWORD para enviar tokens.');
  }
  final smtpServer = SmtpServer(
    host,
    username: username,
    password: password,
    port: int.tryParse(Platform.environment['SMTP_PORT'] ?? '587') ?? 587,
    ssl: Platform.environment['SMTP_SSL'] == 'true',
  );

  final message = Message()
    ..from = Address(username, 'SnapLock')
    ..recipients.add(email)
    ..subject = 'Token para redefinir sua senha'
    ..html = '''
      <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 24px; background-color: #f4f4f7;">
        <div style="background-color: #ffffff; border-radius: 8px; padding: 32px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
          <h2 style="color: #1a1a1a; margin-top: 0;">Olá, $nomeUsuario!</h2>
          <p style="color: #444; font-size: 15px; line-height: 1.5;">
            Você solicitou a redefinição da sua senha. Use o código abaixo para continuar:
          </p>
          <div style="background-color: #f0f0f5; border-radius: 6px; padding: 16px; text-align: center; margin: 24px 0;">
            <span style="font-size: 28px; font-weight: bold; letter-spacing: 6px; color: #2b2b2b;">$token</span>
          </div>
          <p style="color: #666; font-size: 14px;">⏱️ O código expira em <strong>15 minutos</strong>.</p>
          <p style="color: #666; font-size: 14px;">Não compartilhe este código com ninguém.</p>
          <p style="color: #999; font-size: 13px; margin-top: 24px;">
            Caso você não tenha feito essa solicitação, pode ignorar este e-mail com segurança.
          </p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 24px 0;">
          <p style="color: #bbb; font-size: 12px; text-align: center;">
            &copy; 2026 SnapLock. Todos os direitos reservados.
          </p>
        </div>
      </div>
    ''';

  await send(message, smtpServer);
}

bool _dataValida(String value) {
  final data = DateTime.tryParse(value);
  return data != null && value.length == 10 && data.toIso8601String().startsWith(value);
}

bool _idadeMinimaValida(String value) {
  final nascimento = DateTime.parse(value);
  final hoje = DateTime.now();
  final dataLimite = DateTime(hoje.year - 16, hoje.month, hoje.day);
  return !nascimento.isAfter(dataLimite);
}