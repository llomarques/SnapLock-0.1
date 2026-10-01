import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/post_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<PostModel> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final posts = await ApiService.getFeed();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _showCreatePostDialog() async {
    final picker = ImagePicker();
    XFile? pickedFile;
    Uint8List? imageBytes;
    final captionController = TextEditingController();
    bool isUploading = false;

    try {
      pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (pickedFile == null) return;
      imageBytes = await pickedFile.readAsBytes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')),
        );
      }
      return;
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Postar/editar foto (RN02)',
            style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageBytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(imageBytes, height: 180, fit: BoxFit.cover),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: captionController,
                  maxLines: 3,
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Escreva uma legenda...',
                    hintStyle: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 12),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 14, color: AppTheme.mediumBrown),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Visível apenas para amigos autorizados (RN13)',
                        style: GoogleFonts.poppins(color: AppTheme.mediumBrown, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUploading ? null : () => Navigator.pop(ctx),
              child: Text('Cancelar', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkBrown),
              onPressed: isUploading
                  ? null
                  : () async {
                      setDialogState(() => isUploading = true);
                      try {
                        final base64Image = base64Encode(imageBytes!);
                        final fileName = pickedFile?.name ?? 'photo.jpg';

                        await ApiService.createPost(
                          base64Image,
                          captionController.text.trim(),
                          fileName,
                        );

                        if (context.mounted) Navigator.pop(ctx);
                        _loadFeed();
                      } catch (e) {
                        setDialogState(() => isUploading = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                          );
                        }
                      }
                    },
              child: isUploading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Postar', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: _loadFeed,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.darkBrown))
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!, style: GoogleFonts.poppins(color: AppTheme.danger)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkBrown),
                          onPressed: _loadFeed,
                          child: Text('Tentar Novamente', style: GoogleFonts.poppins(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : _posts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.photo_library_outlined, size: 60, color: AppTheme.mediumBrown),
                              const SizedBox(height: 16),
                              Text(
                                'Sua Tela Inicial está vazia',
                                style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Poste fotos e adicione seus amigos mais próximos para compartilhar momentos em um ambiente seguro e sem cyberbullying (RN13).',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkBrown),
                                icon: const Icon(Icons.add_a_photo, color: Colors.white, size: 18),
                                label: Text('Postar Primeira Foto', style: GoogleFonts.poppins(color: Colors.white)),
                                onPressed: _showCreatePostDialog,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          return PostCard(
                            post: _posts[index],
                            onPostUpdated: _loadFeed,
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: AppTheme.darkBrown,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }
}
