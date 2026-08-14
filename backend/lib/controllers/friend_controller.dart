import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../middlewares/auth_middleware.dart';
import '../services/friend_service.dart';
import '../utils/response_helper.dart';

class FriendController {
  Router get router {
    final router = Router();

    // GET /api/friends/search?q=nome (RN17, RF14)
    router.get('/search', (Request request) async {
      try {
        final userId = getUserIdFromRequest(request);
        final query = request.requestedUri.queryParameters['q'] ?? '';

        final users = FriendService.searchUsers(query, userId);
        return ResponseHelper.success({
          'users': users.map((u) => u.toJson()).toList(),
        });
      } catch (e) {
        return ResponseHelper.error('Erro ao buscar usuários: ${e.toString()}');
      }
    });

    // POST /api/friends/request
    router.post('/request', (Request request) async {
      try {
        final userId = getUserIdFromRequest(request);
        final bodyStr = await request.readAsString();
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;

        final friendId = body['friendId'] as String?;
        if (friendId == null) {
          return ResponseHelper.error('Informe o ID do amigo para enviar a solicitação.');
        }

        FriendService.sendRequest(userId, friendId);
        return ResponseHelper.success({'message': 'Solicitação de amizade enviada com sucesso!'});
      } on FormatException catch (e) {
        return ResponseHelper.error(e.message);
      } catch (e) {
        return ResponseHelper.error('Erro ao enviar solicitação: ${e.toString()}');
      }
    });

    // POST /api/friends/accept
    router.post('/accept', (Request request) async {
      try {
        final userId = getUserIdFromRequest(request);
        final bodyStr = await request.readAsString();
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;

        final requestId = body['requestId'] as String?;
        if (requestId == null) {
          return ResponseHelper.error('Informe o ID da solicitação de amizade.');
        }

        FriendService.acceptRequest(userId, requestId);
        return ResponseHelper.success({'message': 'Solicitação de amizade aceita com sucesso!'});
      } on FormatException catch (e) {
        return ResponseHelper.error(e.message);
      } catch (e) {
        return ResponseHelper.error('Erro ao aceitar solicitação: ${e.toString()}');
      }
    });

    // POST /api/friends/decline
    router.post('/decline', (Request request) async {
      try {
        final userId = getUserIdFromRequest(request);
        final bodyStr = await request.readAsString();
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;

        final requestId = body['requestId'] as String?;
        if (requestId == null) {
          return ResponseHelper.error('Informe o ID da solicitação.');
        }

        FriendService.declineRequest(userId, requestId);
        return ResponseHelper.success({'message': 'Solicitação de amizade recusada.'});
      } catch (e) {
        return ResponseHelper.error('Erro ao recusar solicitação: ${e.toString()}');
      }
    });

    // DELETE /api/friends/<friendId>
    router.delete('/<friendId>', (Request request, String friendId) async {
      try {
        final userId = getUserIdFromRequest(request);
        FriendService.removeFriend(userId, friendId);

        return ResponseHelper.success({'message': 'Amigo removido.'});
      } catch (e) {
        return ResponseHelper.error('Erro ao remover amigo: ${e.toString()}');
      }
    });

    // GET /api/friends
    router.get('/', (Request request) async {
      try {
        final userId = getUserIdFromRequest(request);
        final friends = FriendService.getFriends(userId);

        return ResponseHelper.success({
          'friends': friends.map((f) => f.toJson()).toList(),
        });
      } catch (e) {
        return ResponseHelper.error('Erro ao listar amigos: ${e.toString()}');
      }
    });

    // GET /api/friends/pending
    router.get('/pending', (Request request) async {
      try {
        final userId = getUserIdFromRequest(request);
        final pending = FriendService.getPendingRequests(userId);

        return ResponseHelper.success({'pending': pending});
      } catch (e) {
        return ResponseHelper.error('Erro ao listar solicitações pendentes: ${e.toString()}');
      }
    });

    return router;
  }
}
