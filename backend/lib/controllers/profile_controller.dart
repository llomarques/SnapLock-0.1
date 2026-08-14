import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../middlewares/auth_middleware.dart';
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../utils/response_helper.dart';

class ProfileController {
  Router get router {
    final router = Router();

    // GET /api/profile (RF05)
    router.get('/', (Request request) async {
      try {
        final userId = getUserIdFromRequest(request);
        final user = AuthService.getProfile(userId);
        final gallery = PostService.getUserGallery(userId);

        return ResponseHelper.success({
          'user': user.toJson(),
          'gallery': gallery.map((p) => p.toJson()).toList(),
        });
      } on FormatException catch (e) {
        return ResponseHelper.error(e.message);
      } catch (e) {
        return ResponseHelper.error('Erro ao buscar perfil: ${e.toString()}');
      }
    });

    // PUT /api/profile (RF06)
    router.put('/', (Request request) async {
      try {
        final userId = getUserIdFromRequest(request);
        final bodyStr = await request.readAsString();
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;

        final name = body['name'] as String?;
        final bio = body['bio'] as String?;
        final gender = body['gender'] as String?;
        final avatarUrl = body['avatarUrl'] as String?;

        if (name == null || bio == null || gender == null) {
          return ResponseHelper.error('Informe nome, biografia e gênero.');
        }

        final updatedUser = AuthService.updateProfile(
          userId: userId,
          name: name,
          bio: bio,
          gender: gender,
          avatarUrl: avatarUrl,
        );

        return ResponseHelper.success({
          'message': 'Perfil atualizado com sucesso!',
          'user': updatedUser.toJson(),
        });
      } on FormatException catch (e) {
        return ResponseHelper.error(e.message);
      } catch (e) {
        return ResponseHelper.error('Erro ao atualizar perfil: ${e.toString()}');
      }
    });

    // PUT /api/profile/password (RN14)
    router.put('/password', (Request request) async {
      try {
        final userId = getUserIdFromRequest(request);
        final bodyStr = await request.readAsString();
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;

        final currentPassword = body['currentPassword'] as String?;
        final newPassword = body['newPassword'] as String?;

        if (currentPassword == null || newPassword == null) {
          return ResponseHelper.error('Informe a senha atual e a nova senha.');
        }

        AuthService.changePassword(
          userId: userId,
          currentPassword: currentPassword,
          newPassword: newPassword,
        );

        return ResponseHelper.success({'message': 'Senha alterada com sucesso!'});
      } on FormatException catch (e) {
        return ResponseHelper.error(e.message);
      } catch (e) {
        return ResponseHelper.error('Erro ao alterar senha: ${e.toString()}');
      }
    });

    // DELETE /api/profile (RN10, RF07)
    router.delete('/', (Request request) async {
      try {
        final userId = getUserIdFromRequest(request);
        AuthService.deleteAccount(userId);

        return ResponseHelper.success({
          'message': 'Sua conta e todas as suas fotos foram removidas permanentemente do aplicativo (RN10).',
        });
      } on FormatException catch (e) {
        return ResponseHelper.error(e.message);
      } catch (e) {
        return ResponseHelper.error('Erro ao excluir conta: ${e.toString()}');
      }
    });

    return router;
  }
}
