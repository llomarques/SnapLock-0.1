import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../middlewares/auth_middleware.dart';
import '../services/auth_service.dart';
import '../utils/response_helper.dart';

class AuthController {
  Router get router {
    final router = Router();

    // POST /api/auth/register (RN01, RN04, RN07, RN08, RF02)
    router.post('/register', (Request request) async {
      try {
        final bodyStr = await request.readAsString();
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;

        final name = body['name'] as String?;
        final email = body['email'] as String?;
        final password = body['password'] as String?;
        final confirmPassword = body['confirmPassword'] as String?;
        final birthdate = body['birthdate'] as String?;

        if (name == null || email == null || password == null || confirmPassword == null || birthdate == null) {
          return ResponseHelper.error('Todos os campos obrigatórios (nome, e-mail, senha, confirmação de senha e data de nascimento) devem ser informados.');
        }

        final result = AuthService.register(
          name: name,
          email: email,
          password: password,
          confirmPassword: confirmPassword,
          birthdate: birthdate,
          bio: (body['bio'] as String?) ?? '',
          gender: (body['gender'] as String?) ?? '',
        );

        final userMap = result['user'] as Map<String, dynamic>;
        final token = JwtHelper.generateToken(userMap['id'] as String);

        return ResponseHelper.success({
          'message': 'Usuário cadastrado com sucesso!',
          'user': userMap,
          'token': token,
        }, statusCode: 201);
      } on FormatException catch (e) {
        return ResponseHelper.error(e.message);
      } catch (e) {
        return ResponseHelper.error('Erro ao registrar usuário: ${e.toString()}');
      }
    });

    // POST /api/auth/login (RN06, RF01)
    router.post('/login', (Request request) async {
      try {
        final bodyStr = await request.readAsString();
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;

        final email = body['email'] as String?;
        final password = body['password'] as String?;

        if (email == null || password == null) {
          return ResponseHelper.error('Informe o e-mail e a senha para realizar o login.');
        }

        final result = AuthService.login(email, password);
        final userMap = result['user'] as Map<String, dynamic>;
        final token = JwtHelper.generateToken(userMap['id'] as String);

        return ResponseHelper.success({
          'message': 'Login realizado com sucesso!',
          'user': userMap,
          'token': token,
        });
      } on FormatException catch (e) {
        return ResponseHelper.error(e.message, statusCode: 401);
      } catch (e) {
        return ResponseHelper.error('Erro ao realizar login: ${e.toString()}');
      }
    });

    // POST /api/auth/forgot-password (RN05, RF04)
    router.post('/forgot-password', (Request request) async {
      try {
        final bodyStr = await request.readAsString();
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;

        final email = body['email'] as String?;
        if (email == null || email.trim().isEmpty) {
          return ResponseHelper.error('Informe o e-mail cadastrado.');
        }

        final result = AuthService.forgotPassword(email);
        return ResponseHelper.success(result);
      } on FormatException catch (e) {
        return ResponseHelper.error(e.message);
      } catch (e) {
        return ResponseHelper.error('Erro ao solicitar redefinição de senha: ${e.toString()}');
      }
    });

    // POST /api/auth/reset-password (RN05, RN14)
    router.post('/reset-password', (Request request) async {
      try {
        final bodyStr = await request.readAsString();
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;

        final email = body['email'] as String?;
        final token = body['token'] as String?;
        final newPassword = body['newPassword'] as String?;

        if (email == null || token == null || newPassword == null) {
          return ResponseHelper.error('Informe o e-mail, o token recebido e a nova senha.');
        }

        AuthService.resetPassword(email, token, newPassword);
        return ResponseHelper.success({'message': 'Senha redefinida com sucesso! Você já pode realizar login.'});
      } on FormatException catch (e) {
        return ResponseHelper.error(e.message);
      } catch (e) {
        return ResponseHelper.error('Erro ao redefinir senha: ${e.toString()}');
      }
    });

    return router;
  }
}
