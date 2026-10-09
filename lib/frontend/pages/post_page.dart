import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:snaplock/controller/controller.login.dart';
import 'package:snaplock/frontend/pages/feed_page.dart';
import 'package:snaplock/models/post_model.dart';
import 'package:snaplock/services/api_service.dart';
import 'package:snaplock/theme/app_theme.dart';

class PostMaximizadoPage extends StatefulWidget {
  const PostMaximizadoPage({super.key, required this.post});

  final PostModel post;

  @override
  State<PostMaximizadoPage> createState() => _PostMaximizadoPageState();
}

class _PostMaximizadoPageState extends State<PostMaximizadoPage> {
  late String? _reaction;
  late int _reactionCount;
  late String _caption;
  late String _imageUrl;
  bool _reacting = false;
  bool _deleting = false;
  bool _editing = false;
  bool _postUpdated = false;

  bool get _isAuthor {
    final currentUserId =
        (ApiService.currentUser?.id ?? LoginController.usuarioAtual?['id'])
            ?.toString()
            .trim();
    return currentUserId != null &&
        currentUserId.isNotEmpty &&
        widget.post.userId.trim() == currentUserId;
  }

  @override
  void initState() {
    super.initState();
    _reaction = widget.post.userReaction;
    _reactionCount = widget.post.reactionCount;
    _caption = widget.post.caption;
    _imageUrl = widget.post.imageUrl;
  }

  void _navigateToTab(int index) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FeedPage(initialIndex: index)),
    );
  }

  Future<void> _toggleReaction(String type) async {
    if (_reacting) return;
    setState(() => _reacting = true);

    final reactionBefore = _reaction;
    try {
      if (reactionBefore == type) {
        await ApiService.removeReaction(widget.post.id);
        if (!mounted) return;
        setState(() {
          _reaction = null;
          if (_reactionCount > 0) _reactionCount--;
        });
      } else {
        await ApiService.reactToPost(widget.post.id, type);
        if (!mounted) return;
        setState(() {
          _reaction = type;
          if (reactionBefore == null) _reactionCount++;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _reacting = false);
    }
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.cardBorder),
        ),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppTheme.danger,
                size: 23,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Excluir publicação?',
                style: GoogleFonts.cormorantGaramond(
                  color: AppTheme.background,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Essa ação não pode ser desfeita.',
          style: GoogleFonts.poppins(
            color: AppTheme.surface,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.surface,
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await ApiService.deletePost(widget.post.id);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _editPost() async {
    if (_editing) return;
    final captionController = TextEditingController(text: _caption);
    XFile? selectedImage;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.textPrimary,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppTheme.cardBorder),
          ),
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.lightBrown.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: AppTheme.lightBrown,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Editar publicação',
                  style: GoogleFonts.cormorantGaramond(
                    color: AppTheme.background,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: captionController,
                maxLines: 4,
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF999999),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.surface),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.surface,
                textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.mediumBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) {
      captionController.dispose();
      return;
    }

    setState(() => _editing = true);
    try {
      final response = await ApiService.updatePost(
        postId: widget.post.id,
        caption: captionController.text.trim(),
        imageBytes:
            selectedImage == null ? null : await selectedImage!.readAsBytes(),
        fileName: selectedImage?.name ?? 'publicacao.jpg',
      );
      if (!mounted) return;
      setState(() {
        _caption = response['caption']?.toString() ?? captionController.text;
        _imageUrl = response['imageUrl']?.toString() ?? _imageUrl;
        _postUpdated = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicação atualizada.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      captionController.dispose();
      if (mounted) setState(() => _editing = false);
    }
  }

  Future<void> _reportPost() async {
    final reasonController = TextEditingController();
    final selectedReasons = <String>{};
    const reasonOptions = [
      'Inapropriado',
      'Ofensivo',
      'Indesejado',
      'Violência',
      'Spam',
      'Outro',
    ];
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          Widget reasonOption(String value) {
            return SizedBox(
              height: 32,
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Checkbox(
                      value: selectedReasons.contains(value),
                      activeColor: AppTheme.background,
                      checkColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.background),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (selected) {
                        setDialogState(() {
                          if (selected == true) {
                            selectedReasons.add(value);
                          } else {
                            selectedReasons.remove(value);
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(
                        color: AppTheme.background,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final canSubmit = selectedReasons.isNotEmpty ||
              reasonController.text.trim().isNotEmpty;

          return AlertDialog(
            backgroundColor: AppTheme.textPrimary,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppTheme.cardBorder),
            ),
            title: Text(
              'Por que deseja reportar esse post?',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                color: AppTheme.background,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children:
                              reasonOptions.take(3).map(reasonOption).toList(),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children:
                              reasonOptions.skip(3).map(reasonOption).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: reasonController,
                          autofocus: true,
                          minLines: 3,
                          maxLines: 3,
                          onChanged: (_) => setDialogState(() {}),
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Escreva aqui o motivo...',
                            hintStyle: GoogleFonts.poppins(
                              color:
                                  AppTheme.textPrimary,
                              fontSize: 12,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF999999),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppTheme.background,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Enviar denúncia',
                        onPressed: canSubmit
                            ? () {
                                final details = reasonController.text.trim();
                                final selected = reasonOptions
                                    .where(selectedReasons.contains)
                                    .join(', ');
                                final combinedReason = [
                                  selected,
                                  if (details.isNotEmpty) details,
                                ].join(': ');
                                Navigator.pop(dialogContext, combinedReason);
                              }
                            : null,
                        color: AppTheme.background,
                        icon: const Icon(Icons.send, size: 28),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.surface,
                  textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      ),
    );

    reasonController.dispose();
    if (reason == null || reason.isEmpty || !mounted) return;

    try {
      await ApiService.reportPost(widget.post.id, reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Denúncia enviada para análise da administração.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Widget _reactionButton({
    required String type,
    required IconData icon,
    required String tooltip,
  }) {
    final selected = _reaction == type;
    return IconButton(
      onPressed: _reacting ? null : () => _toggleReaction(type),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        icon,
        size: 25,
        color: selected ? const Color(0xFF5E3023) : Colors.black45,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final username = post.authorUsername;
    const menuTextStyle = TextStyle(color: Color(0xFFF3E9DC));
    var formattedDate = post.createdAt;
    try {
      formattedDate = DateFormat(
        'dd/MM/yyyy',
      ).format(DateTime.parse(post.createdAt));
    } on FormatException {
      // Keep the original value when the server returns an unexpected date.
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3E9DC),
      drawer: Drawer(
        backgroundColor: const Color(0xFFC08552),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 60, bottom: 12),
              child: Image.asset('assets/images/logo.png', height: 80),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              onTap: () => _navigateToTab(0),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificações'),
              onTap: () => _navigateToTab(1),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () => _navigateToTab(4),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Builder(
            builder: (context) => FeedHeader(
              onMenuPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          SizedBox(
            height: 58,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context, _postUpdated),
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                if (_isAuthor)
                  PopupMenuButton<String>(
                    enabled: !_deleting && !_editing,
                    color: const Color(0xFF3E3A36),
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') _editPost();
                      if (value == 'delete') _deletePost();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text(
                          'Editar',
                          style: TextStyle(color: Color(0xFFF3E9DC)),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        enabled: !_deleting,
                        child: Text(
                          _deleting ? 'Excluindo...' : 'Excluir',
                          style: menuTextStyle,
                        ),
                      ),
                    ],
                    icon: const Icon(
                      Icons.more_vert,
                      color: Color(0xFF3E3A36),
                      size: 26,
                    ),
                  )
                else
                  const SizedBox(width: 12),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 16, 16),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.48,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(27),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          InteractiveViewer(
                            minScale: 1,
                            maxScale: 4,
                            child: Image.network(
                              _imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const ColoredBox(
                                color: Color(0xFFD7CBBD),
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 50,
                                    color: Color(0xFF895737),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (username?.isNotEmpty ?? false)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  28,
                                  16,
                                  16,
                                ),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Color(0xB3000000),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  '@$username',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _caption.isEmpty ? 'Legenda/Título' : _caption,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _caption.isEmpty
                                      ? Colors.black45
                                      : const Color(0xFF5E3023),
                                  fontSize: 15,
                                ),
                              ),
                              if (formattedDate.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      _reactionButton(
                        type: 'HEART',
                        icon: _reaction == 'HEART'
                            ? Icons.favorite
                            : Icons.favorite_border,
                        tooltip: 'Curtir',
                      ),
                      if (!_isAuthor)
                        IconButton(
                          onPressed: _reportPost,
                          tooltip: 'Denunciar publicação',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.report_gmailerrorred_outlined,
                            size: 25,
                            color: Colors.black45,
                          ),
                        ),
                    ],
                  ),
                  if (_reactionCount > 0)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          '$_reactionCount ${_reactionCount == 1 ? 'reação' : 'reações'}',
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
