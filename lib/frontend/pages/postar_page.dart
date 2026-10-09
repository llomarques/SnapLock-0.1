import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:snaplock/frontend/utils/foto_utils.dart';
import 'package:snaplock/frontend/widgets/botoes_widget.dart';
import 'package:snaplock/services/api_service.dart';

class PostarPage extends StatefulWidget {
  const PostarPage({super.key});

  @override
  State<PostarPage> createState() => _PostarPageState();
}

class _PostarPageState extends State<PostarPage> {
  static const _aspectRatioOptions = <({String label, double? ratio})>[
    (label: 'Original', ratio: null),
    (label: 'Quadrada 1:1', ratio: 1),
    (label: 'Retrato 4:5', ratio: 4 / 5),
    (label: 'Paisagem 16:9', ratio: 16 / 9),
    (label: 'Personalizada', ratio: null),
  ];

  final TextEditingController legendaController = TextEditingController();
  final FocusNode legendaFocusNode = FocusNode();
  Uint8List? _imagemOriginal;
  Uint8List? fotoPerfil;
  bool legendaConfirmada = false;
  double fotoAspectRatio = 4 / 5;
  double _originalAspectRatio = 4 / 5;
  int _selectedAspectRatioIndex = 0;
  bool selecionandoImagem = false;
  bool salvando = false;
  String fotoPerfilUrl = '';
  String? filtroAplicado;

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

      final originalAspectRatio = await _aspectRatioDaImagem(bytes);
      final targetAspectRatio = _aspectRatioDaOpcao(
        _selectedAspectRatioIndex,
        originalAspectRatio: originalAspectRatio,
      );
      final croppedImage = await _abrirEditorDeCorte(bytes, targetAspectRatio);

      if (croppedImage == null || !mounted) {
        return;
      }

      final croppedAspectRatio = await _aspectRatioDaImagem(croppedImage);
      if (!mounted) return;

      setState(() {
        _imagemOriginal = bytes;
        fotoPerfil = croppedImage;
        _originalAspectRatio = originalAspectRatio;
        fotoAspectRatio = croppedAspectRatio;
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

  double? _aspectRatioDaOpcao(
    int index, {
    double? originalAspectRatio,
  }) {
    if (index == 0) return originalAspectRatio ?? _originalAspectRatio;
    return _aspectRatioOptions[index].ratio;
  }

  Future<double> _aspectRatioDaImagem(Uint8List bytes) async {
    final image = await decodeImageFromList(bytes);
    final aspectRatio = image.width / image.height;
    image.dispose();
    return aspectRatio;
  }

  Future<Uint8List?> _abrirEditorDeCorte(
    Uint8List imageBytes,
    double? aspectRatio,
  ) {
    final controller = CropController();
    var editorPronto = false;
    var cortando = false;

    return showDialog<Uint8List>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Ajustar foto'),
          content: SizedBox(
            width: MediaQuery.sizeOf(dialogContext).width * 0.82,
            height: MediaQuery.sizeOf(dialogContext).height * 0.52,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Crop(
                image: imageBytes,
                controller: controller,
                aspectRatio: aspectRatio,
                interactive: true,
                baseColor: const Color(0xFF241A14),
                maskColor: Colors.black.withValues(alpha: 0.65),
                progressIndicator: const CircularProgressIndicator(
                  color: Color(0xFFC08552),
                ),
                onStatusChanged: (status) {
                  if (!dialogContext.mounted) return;
                  setDialogState(() {
                    editorPronto = status == CropStatus.ready;
                    cortando = status == CropStatus.cropping;
                  });
                },
                onCropped: (result) {
                  if (result is CropSuccess) {
                    Navigator.of(dialogContext).pop(result.croppedImage);
                  } else if (result is CropFailure) {
                    if (dialogContext.mounted) {
                      setDialogState(() => cortando = false);
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Não foi possível cortar a imagem: ${result.cause}',
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  cortando ? null : () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: editorPronto && !cortando ? controller.crop : null,
              child: cortando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Aplicar corte'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarProporcao() async {
    final selectedIndex = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF3E9DC),
      builder: (context) {
        final maxHeight = MediaQuery.sizeOf(context).height * 0.75;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Proporção da foto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  for (var index = 0;
                      index < _aspectRatioOptions.length;
                      index++)
                    ListTile(
                      title: Text(_aspectRatioOptions[index].label),
                      trailing: index == _selectedAspectRatioIndex
                          ? const Icon(Icons.check, color: Color(0xFF895737))
                          : null,
                      onTap: () => Navigator.pop(context, index),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selectedIndex == null || !mounted) return;

    final sourceImage = _imagemOriginal;
    if (sourceImage != null) {
      final targetAspectRatio = _aspectRatioDaOpcao(selectedIndex);
      final croppedImage = await _abrirEditorDeCorte(
        sourceImage,
        targetAspectRatio,
      );
      if (croppedImage == null || !mounted) return;

      final croppedAspectRatio = await _aspectRatioDaImagem(croppedImage);
      if (!mounted) return;

      setState(() {
        _selectedAspectRatioIndex = selectedIndex;
        fotoPerfil = croppedImage;
        fotoAspectRatio = croppedAspectRatio;
      });
      return;
    }

    setState(() {
      _selectedAspectRatioIndex = selectedIndex;
      fotoAspectRatio = _aspectRatioDaOpcao(selectedIndex) ?? fotoAspectRatio;
    });
  }

  Future<void> publicar() async {
    if (salvando) return;
    final imagem = fotoPerfil;
    if (imagem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma foto para publicar.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => salvando = true);
    try {
      // Processa a imagem aplicando o filtro nos bytes antes do envio, se houver filtro selecionado
      Uint8List imagemParaPostar = imagem;
      if (filtroAplicado != null) {
        final filtroCor = _obterFiltroDeCor(filtroAplicado);
        imagemParaPostar = await _processarBytesComFiltro(imagem, filtroCor);
      }

      await ApiService.createPostFromBytes(
        imagemParaPostar,
        legendaController.text.trim(),
        filtroAplicado: filtroAplicado,
        aspectRatio: fotoAspectRatio,
      );
      if (!mounted) return;

      legendaController.clear();
      setState(() {
        _imagemOriginal = null;
        fotoPerfil = null;
        fotoAspectRatio = 4 / 5;
        _originalAspectRatio = 4 / 5;
        _selectedAspectRatioIndex = 0;
        legendaConfirmada = false;
        filtroAplicado = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memória publicada com sucesso.')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  Future<Uint8List> _processarBytesComFiltro(
    Uint8List imageBytes,
    ColorFilter colorFilter,
  ) async {
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..colorFilter = colorFilter;

    canvas.drawImage(image, Offset.zero, paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(image.width, image.height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    image.dispose();
    img.dispose();

    return byteData!.buffer.asUint8List();
  }

  Future<void> _aplicarEfeito() async {
    if (fotoPerfil == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma foto antes de aplicar um efeito.'),
        ),
      );
      return;
    }

    // Lista com a definição explícita do tipo ColorFilter
    final filtrosDisponiveis = <({
      String nome,
      String? id,
      ColorFilter colorFilter,
    })>[
      (
        nome: 'Original',
        id: null,
        colorFilter: const ColorFilter.mode(Colors.transparent, BlendMode.dst),
      ),
      (
        nome: 'Preto & Branco',
        id: 'pb',
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
      ),
      (
        nome: 'Sépia',
        id: 'sepia',
        colorFilter: ColorFilter.mode(
          const Color(0xFF704214).withValues(alpha: 0.35),
          BlendMode.color,
        ),
      ),
      (
        nome: 'Vintage',
        id: 'vintage',
        colorFilter: ColorFilter.mode(
          const Color(0xFFFFB703).withValues(alpha: 0.25),
          BlendMode.color,
        ),
      ),
      (
        nome: 'Frio',
        id: 'frio',
        colorFilter: ColorFilter.mode(
          const Color(0xFF0077B6).withValues(alpha: 0.25),
          BlendMode.color,
        ),
      ),
    ];

    final filtroSelecionado = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: const Color(0xFFF3E9DC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Escolha um efeito',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5E3023),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filtrosDisponiveis.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = filtrosDisponiveis[index];
                      final isSelected = filtroAplicado == item.id;

                      return GestureDetector(
                        onTap: () => Navigator.pop(modalContext, item.id),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF895737)
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: ColorFiltered(
                                  colorFilter: item.colorFilter,
                                  child: Image.memory(
                                    fotoPerfil!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.nome,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: const Color(0xFF5E3023),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (mounted && filtroSelecionado != filtroAplicado) {
      setState(() {
        filtroAplicado = filtroSelecionado;
      });
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
                                  ? Center(
                                      child: IconButton(
                                        onPressed: escolherDaGaleria,
                                        tooltip: 'Adicionar foto',
                                        icon: const Icon(
                                            Icons.add_photo_alternate,
                                            size: 40),
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF895737),
                                          foregroundColor:
                                              const Color(0xFFF3E9DC),
                                          fixedSize: const Size(72, 72),
                                        ),
                                      ),
                                    )
                                  : ColorFiltered(
                                      colorFilter:
                                          _obterFiltroDeCor(filtroAplicado),
                                      child: Image(
                                        image: imagemPerfil!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            )),
                        if (imagemPerfil != null)
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: IconButton(
                              onPressed: escolherDaGaleria,
                              tooltip: 'Trocar foto',
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
                          textInputAction: TextInputAction.send,
                          onFieldSubmitted: (_) => publicar(),
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
                      const SizedBox(width: 4),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 180),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (legendaFocusNode.hasFocus)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    legendaConfirmada = true;
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                                tooltip: 'Concluir legenda',
                                color: const Color(0xFF895737),
                                icon: const Icon(Icons.check_circle),
                              ),
                            IconButton(
                              onPressed: _aplicarEfeito,
                              icon: Image.asset(
                                'assets/images/efeitos.png',
                                width: 32,
                                height: 32,
                                semanticLabel: 'Efeitos',
                              ),
                              tooltip: 'Aplicar efeitos',
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: _selecionarProporcao,
                              tooltip:
                                  'Proporção: ${_aspectRatioOptions[_selectedAspectRatioIndex].label}',
                              constraints: const BoxConstraints.tightFor(
                                width: 40,
                                height: 40,
                              ),
                              padding: EdgeInsets.zero,
                              icon: Image.asset(
                                'assets/images/proporcao.png',
                                width: 32,
                                height: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                BotoesWidget(
                  texto: salvando ? 'Publicando...' : 'Postar',
                  aoTocar: publicar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ColorFilter _obterFiltroDeCor(String? filtro) {
    switch (filtro) {
      case 'pb':
        return const ColorFilter.mode(Colors.black, BlendMode.color);
      case 'sepia':
        return ColorFilter.mode(
          const Color(0xFF704214).withValues(alpha: 0.35),
          BlendMode.color,
        );
      case 'vintage':
        return ColorFilter.mode(
          const Color(0xFFFFB703).withValues(alpha: 0.25),
          BlendMode.color,
        );
      case 'frio':
        return ColorFilter.mode(
          const Color(0xFF0077B6).withValues(alpha: 0.25),
          BlendMode.color,
        );
      default:
        return const ColorFilter.mode(Colors.transparent, BlendMode.dst);
    }
  }
}
