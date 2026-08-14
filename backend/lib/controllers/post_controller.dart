import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../middlewares/auth_middleware.dart';
import '../services/post_service.dart';
import '../services/reaction_service.dart';
import '../utils/response_helper.dart';

class PostController {
  Router get router {
    final router = Router();

    // POST /api/posts (RN02, RF08)
    // Supports JSON with Base64 image data or file fields for Web & Mobile compatibility
    router.post('/', (Request request) async {
      try {
        final userId = getUserIdFromRequest(request);
        final bodyStr = await request.readAsString();
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;

        final caption = (body['caption'] as String?) ?? '';
        final base64Image = body['imageBase64'] as String?;
        final fileName = (body['fileName'] as String?) ?? 'photo.jpg';

        if (base64Image == null || base64Image.isEmpty) {
          return ResponseHelper.error('A foto é obrigatória (informe o campo imageBase64).');
        }

        // Clean header if base64 data URI pattern is passed
        final cleanBase64 = base64Image.contains(',') ? base64Image.split(',').last : base64Image;
        final imageBytes = base64Decode(cleanBase64);

        final post = PostService.createPost(
          userId: userId,
          imageBytes: imageBytes,
          originalFileName: fileName,
          caption: caption,
        );

        return ResponseHelper.success({
          'message': 'Foto publicada com sucesso!',
          'post': post.toJson(),
        }, statusCode: 201);
      } on FormatException catch (e) {
        return ResponseHelper.error(e.message);
      } catch (e) {
        return ResponseHelper.error('Erro ao publicar foto: ${e.toString()}');
      }
    });

    // GET /api/feed (RN13, RF10, RNF01)
    router.get('/feed', (Request request) async {
      try {
        final userId = getUserIdFromRequest(request);
        final feed = PostService.getFeed(userId);

        return ResponseHelper.success({
          'posts': feed.map((p) => p.toJson()).toList(),
        });
      } catch (e) {
        return ResponseHelper.error('Erro ao carregar o feed: ${e.toString()}');
      }
    });

    // GET /api/posts/my-gallery (RF05)
    router.get('/my-gallery', (Request request) async {
      try {
        final userId = getUserIdFromRequest(request);
        final gallery = PostService.getUserGallery(userId);

        return ResponseHelper.success({
          'posts': gallery.map((p) => p.toJson()).toList(),
        });
      } catch (e) {
        return ResponseHelper.error('Erro ao carregar galeria: ${e.toString()}');
      }
    });

    // PUT /api/posts/<id> (RN09)
    router.put('/<id>', (Request request, String id) async {
      try {
        final userId = getUserIdFromRequest(request);
        final bodyStr = await request.readAsString();
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;

        final caption = body['caption'] as String?;
        if (caption == null) {
          return ResponseHelper.error('Informe a nova legenda.');
        }

        final updatedPost = PostService.editPostCaption(
          postId: id,
          userId: userId,
          newCaption: caption,
        );

        return ResponseHelper.success({
          'message': 'Legenda da publicação atualizada com sucesso!',
          'post': updatedPost.toJson(),
        });
      } on FormatException catch (e) {
        return ResponseHelper.error(e.message);
      } catch (e) {
        return ResponseHelper.error('Erro ao editar publicação: ${e.toString()}');
      }
    });

    // DELETE /api/posts/<id> (RN09, RF09)
    router.delete('/<id>', (Request request, String id) async {
      try {
        final userId = getUserIdFromRequest(request);
        PostService.deletePost(postId: id, userId: userId);

        return ResponseHelper.success({'message': 'Publicação excluída com sucesso!'});
      } on FormatException catch (e) {
        return ResponseHelper.error(e.message);
      } catch (e) {
        return ResponseHelper.error('Erro ao excluir publicação: ${e.toString()}');
      }
    });

    // POST /api/posts/<id>/reactions (RN16, RF13)
    router.post('/<id>/reactions', (Request request, String id) async {
      try {
        final userId = getUserIdFromRequest(request);
        final bodyStr = await request.readAsString();
        final body = jsonDecode(bodyStr) as Map<String, dynamic>;

        final reactionType = body['reactionType'] as String?;
        if (reactionType == null || reactionType.isEmpty) {
          return ResponseHelper.error('Informe o tipo da reação (ex: LIKE, HEART, SMILE, FIRE, STAR).');
        }

        final reaction = ReactionService.setReaction(
          postId: id,
          userId: userId,
          reactionType: reactionType.toUpperCase(),
        );

        return ResponseHelper.success({
          'message': 'Reação registrada com sucesso!',
          'reaction': reaction.toJson(),
        });
      } on FormatException catch (e) {
        return ResponseHelper.error(e.message);
      } catch (e) {
        return ResponseHelper.error('Erro ao reagir à publicação: ${e.toString()}');
      }
    });

    // DELETE /api/posts/<id>/reactions (RN16)
    router.delete('/<id>/reactions', (Request request, String id) async {
      try {
        final userId = getUserIdFromRequest(request);
        ReactionService.removeReaction(postId: id, userId: userId);

        return ResponseHelper.success({'message': 'Reação removida.'});
      } catch (e) {
        return ResponseHelper.error('Erro ao remover reação: ${e.toString()}');
      }
    });

    // GET /api/posts/<id>/reactions
    router.get('/<id>/reactions', (Request request, String id) async {
      try {
        final reactions = ReactionService.getPostReactions(id);
        return ResponseHelper.success({
          'reactions': reactions.map((r) => r.toJson()).toList(),
        });
      } catch (e) {
        return ResponseHelper.error('Erro ao carregar reações: ${e.toString()}');
      }
    });

    return router;
  }
}
