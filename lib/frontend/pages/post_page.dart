import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snaplock/controller/controller.login.dart';
import 'package:snaplock/frontend/pages/feed_page.dart';
import 'package:snaplock/models/post_model.dart';
import 'package:snaplock/services/api_service.dart';

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
      builder: (context) => AlertDialog(
        title: const Text('Excluir publicação?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
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
          title: const Text('Editar publicação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: captionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Legenda',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final image = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      setDialogState(() => selectedImage = image);
                    }
                  } catch (error) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Não foi possível abrir a galeria: $error',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(selectedImage?.name ?? 'Trocar foto'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Salvar'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Denunciar publicação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informe o motivo da denúncia para análise da administração:',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Ex.: conteúdo impróprio ou ofensivo',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Enviar denúncia'),
          ),
        ],
      ),
    );

    final reason = reasonController.text.trim();
    reasonController.dispose();
    if (confirmed != true || reason.isEmpty || !mounted) return;

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
                    children: [
                      Expanded(
                        child: Text(
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
