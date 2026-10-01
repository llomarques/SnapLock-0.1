import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snaplock/frontend/utils/foto_utils.dart';
import 'package:snaplock/frontend/widgets/botoes_widget.dart';

class PostarPage extends StatefulWidget {
  const PostarPage({super.key});

  @override
  State<PostarPage> createState() => _PostarPageState();
}

class _PostarPageState extends State<PostarPage> {
  final TextEditingController legendaController = TextEditingController();
  final FocusNode legendaFocusNode = FocusNode();
  Uint8List? fotoPerfil;
  bool legendaConfirmada = false;
  double fotoAspectRatio = 4 / 5;
  bool selecionandoImagem = false;
  bool salvando = false;
  String fotoPerfilUrl = '';

  @override
  void initState() {
    super.initState();
    legendaController.addListener(_atualizarEstadoLegenda);
    legendaFocusNode.addListener(_atualizarEstadoLegenda);
  }

  void _atualizarEstadoLegenda() {
    if (mounted) {
      setState(() {});
    }
  }

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

      final decodedImage = await decodeImageFromList(bytes);
      final aspectRatio = decodedImage.width / decodedImage.height;
      decodedImage.dispose();

      if (!mounted) {
        return;
      }

      setState(() {
        fotoPerfil = bytes;
        fotoAspectRatio = aspectRatio;
      });
    } on PlatformException catch (error) {
      if (mounted && error.code != 'already_active') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Não foi possível selecionar a imagem.')),
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
    legendaController.removeListener(_atualizarEstadoLegenda);
    legendaFocusNode.removeListener(_atualizarEstadoLegenda);
    legendaFocusNode.dispose();
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final maxPhotoHeight =
                        MediaQuery.sizeOf(context).height * 0.55;
                    final photoWidth = math
                        .min(
                          300.0,
                          math.min(
                            constraints.maxWidth,
                            maxPhotoHeight * fotoAspectRatio,
                          ),
                        )
                        .toDouble();
                    final photoHeight = photoWidth / fotoAspectRatio;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: photoWidth,
                          height: photoHeight,
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
                                    fit: BoxFit.contain,
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
                    );
                  },
                ),
                const SizedBox(height: 18),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: legendaController,
                          focusNode: legendaFocusNode,
                          onTap: () {
                            if (legendaConfirmada) {
                              setState(() => legendaConfirmada = false);
                            }
                          },
                          maxLines: 3,
                          minLines: 1,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            hintText: 'Escreva sua legenda...',
                            filled: legendaController.text.trim().isNotEmpty,
                            fillColor: const Color(0xFFD7CBBD),
                            hintStyle: const TextStyle(
                              color: Color(0xFF6F5C4A),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                          style: const TextStyle(
                            color: Color(0xFF5E3023),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (legendaConfirmada && !legendaFocusNode.hasFocus)
                        const SizedBox(width: 8),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 180),
                        child: legendaFocusNode.hasFocus
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    legendaConfirmada = legendaController.text
                                        .trim()
                                        .isNotEmpty;
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                                tooltip: 'Concluir legenda',
                                color: const Color(0xFF895737),
                                icon: const Icon(Icons.check_circle),
                              )
                            : legendaConfirmada
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/images/efeitos.png',
                                        width: 32,
                                        height: 32,
                                        semanticLabel: 'Efeitos',
                                      ),
                                      const SizedBox(width: 8),
                                      Image.asset(
                                        'assets/images/proporcao.png',
                                        width: 32,
                                        height: 32,
                                        semanticLabel: 'Proporção',
                                      ),
                                    ],
                                  )
                                : const SizedBox(width: 0, height: 48),
                      ),
                    ],
                  ),
                ),
                BotoesWidget(
                  texto: 'Postar',
                  aoTocar: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
