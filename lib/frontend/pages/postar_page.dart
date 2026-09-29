import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snaplock/frontend/utils/foto_utils.dart';

class PostarPage extends StatefulWidget {
  const PostarPage({super.key});

  @override
  State<PostarPage> createState() => _PostarPageState();
}

class _PostarPageState extends State<PostarPage> {
  final TextEditingController legendaController = TextEditingController();
  Uint8List? fotoPerfil;
  bool selecionandoImagem = false;
  bool salvando = false;
  String fotoPerfilUrl = '';

  Future<void> escolherDaGaleria() async {
    if (selecionandoImagem) {
      return;
    }

    setState(() => selecionandoImagem = true);
    try {
      final bytes = await FotoUtils.selecionarDaGaleria();

      if (bytes == null || !mounted) {
        return;
      }

      setState(() {
        fotoPerfil = bytes;
      });
    } on PlatformException catch (error) {
      if (mounted && error.code != 'already_active') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível selecionar a imagem.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => selecionandoImagem = false);
      }
    }
  }

  ImageProvider<Object>? get imagemPerfil {
    if (fotoPerfil != null) {
      return MemoryImage(fotoPerfil!);
    }
    if (fotoPerfilUrl.isNotEmpty) {
      return NetworkImage(fotoPerfilUrl);
    }
    return null;
  }

  @override
  void dispose() {
    legendaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3E9DC),
        body: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                const Text('Nova memória', style: TextStyle(fontSize: 17)),
                const SizedBox(height: 18),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 300,
                      height: 375,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7CBBD),
                        border: Border.all(
                          color: const Color(0xFF895737),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: imagemPerfil == null
                            ? const Center(
                                child: Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 42,
                                  color: Color(0xFF895737),
                                ),
                              )
                            : Image(
                                image: imagemPerfil!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: IconButton(
                        onPressed: escolherDaGaleria,
                        icon: const Icon(Icons.edit, size: 17),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: const Color(0xFFF3E9DC),
                          minimumSize: const Size(32, 32),
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: IntrinsicWidth(
                      child: TextFormField(
                        controller: legendaController,
                        maxLines: 3,
                        minLines: 1,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          hintText: 'Escreva sua legenda...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF6F5C4A),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF5E3023),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
