import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/api_config.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback onPostUpdated;

  const PostCard({
    super.key,
    required this.post,
    required this.onPostUpdated,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends _PostCardStateBase {
  @override
  Widget build(BuildContext context) {
    final isAuthor = widget.post.userId == ApiService.currentUser?.id;
    final imageUrl = widget.post.imageUrl.startsWith('http')
        ? widget.post.imageUrl
        : '${ApiConfig.mediaBaseUrl}${widget.post.imageUrl}';

    String formattedDate = '';
    try {
      final date = DateTime.parse(widget.post.createdAt);
      formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      formattedDate = widget.post.createdAt;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar: Autor e Data
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.darkBrown,
                  radius: 20,
                  child: Text(
                    (widget.post.authorName ?? 'U')[0].toUpperCase(),
                    style: GoogleFonts.cormorantGaramond(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.authorName ?? 'Usuário SnapLock',
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAuthor)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
                    onPressed: _showDeleteConfirmDialog,
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.flag_outlined, color: AppTheme.mediumBrown, size: 20),
                    onPressed: _showReportDialog,
                  ),
              ],
            ),
          ),

          // Foto da Publicação com bordas arredondadas (Figma)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 220,
                    color: AppTheme.surfaceLight,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: AppTheme.textSecondary, size: 44),
                    ),
                  );
                },
              ),
            ),
          ),

          // Legenda da Foto
          if (widget.post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: Text(
                widget.post.caption,
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),

          // Badge Oficial do Figma: "🔒 Visível apenas para amigos autorizados"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.lock_outline, size: 14, color: AppTheme.mediumBrown),
                const SizedBox(width: 6),
                Text(
                  'Visível apenas para amigos autorizados (RN13)',
                  style: GoogleFonts.poppins(
                    color: AppTheme.mediumBrown,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Barra de Reações (Figma: ❤️ 🔥 ⭐️ 😊 👍 + contagem)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 12, 12),
            child: Row(
              children: [
                _buildReactionButton('HEART', '❤️'),
                _buildReactionButton('FIRE', '🔥'),
                _buildReactionButton('STAR', '⭐️'),
                _buildReactionButton('SMILE', '😊'),
                _buildReactionButton('LIKE', '👍'),
                const Spacer(),
                Text(
                  '${widget.post.reactionCount} ${widget.post.reactionCount == 1 ? 'reação' : 'reações'}',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton(String type, String emoji) {
    final isSelected = widget.post.userReaction == type;
    return GestureDetector(
      onTap: () => _toggleReaction(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.darkBrown.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.darkBrown : Colors.transparent,
          ),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

abstract class _PostCardStateBase extends State<PostCard> {
  Future<void> _toggleReaction(String reactionType) async {
    try {
      if (widget.post.userReaction == reactionType) {
        await ApiService.removeReaction(widget.post.id);
      } else {
        await ApiService.reactToPost(widget.post.id, reactionType);
      }
      widget.onPostUpdated();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Excluir Publicação', style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold)),
        content: Text('Tem certeza que deseja excluir esta foto permanentemente?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Excluir', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deletePost(widget.post.id);
        widget.onPostUpdated();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
        }
      }
    }
  }

  Future<void> _showReportDialog() async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Denunciar Publicação (RN11)', style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informe o motivo da denúncia para análise da administração:', style: GoogleFonts.poppins(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Ex: Conteúdo impróprio ou ofensivo',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Enviar Denúncia', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirm == true && reasonController.text.trim().isNotEmpty) {
      try {
        await ApiService.reportPost(widget.post.id, reasonController.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Denúncia enviada com sucesso para a administração!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
        }
      }
    }
  }
}
