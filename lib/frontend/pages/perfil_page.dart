import 'package:flutter/material.dart';
import 'package:snaplock/services/api_service.dart';
import 'package:snaplock/models/post_model.dart';
import 'editarPerfil_page.dart';
import 'amigos_page.dart';
import '../../controller/controller.login.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPage();
}

class _PerfilPage extends State<PerfilPage> {
  final TextEditingController biografiaController = TextEditingController();

  int quantidadeAmigos = 0;
  List<PostModel> fotos = [];
  bool carregandoFotos = true;
  bool erroAoCarregarFotos = false;
  String nomeUsuario = '';
  String username = '';
  String fotoPerfilUrl = '';

  @override
  void initState() {
    super.initState();
    final usuario = LoginController.usuarioAtual;
    nomeUsuario = usuario?['name']?.toString() ?? '';
    username = usuario?['username']?.toString() ?? '';
    fotoPerfilUrl = usuario?['avatarUrl']?.toString() ?? '';
    biografiaController.text = usuario?['bio']?.toString() ?? '';
    carregarQuantidadeAmigos();
    carregarFotos();
  }

  Future<void> carregarQuantidadeAmigos() async {
    try {
      final amigos = await ApiService.getFriends();

      if (!mounted) {
        return;
      }

      setState(() {
        quantidadeAmigos = amigos.length;
      });
    } catch (_) {
      // Mantém o perfil disponível mesmo quando a API estiver indisponível.
    }
  }

  Future<void> carregarFotos() async {
  try {
    print('========================================');
    print('INICIANDO CARREGAMENTO DAS FOTOS');
    print('========================================');

    final galeria = await ApiService.getMyGallery();

    print('FOTOS RECEBIDAS: ${galeria.length}');

    for (final foto in galeria) {
      print('ID: ${foto.id}');
      print('URL: ${foto.imageUrl}');
      print('LEGENDA: ${foto.caption}');
      print('----------------------------------------');
    }

    if (!mounted) {
      return;
    }

    setState(() {
      fotos = galeria;
      erroAoCarregarFotos = false;
    });
  } catch (e, stackTrace) {
    print('========================================');
    print('ERRO AO CARREGAR FOTOS');
    print('========================================');
    print('ERRO: $e');
    print('STACK TRACE:');
    print(stackTrace);
    print('========================================');

    if (mounted) {
      setState(() {
        erroAoCarregarFotos = true;
      });
    }
  } finally {
    if (mounted) {
      setState(() {
        carregandoFotos = false;
      });
    }
  }
}

  Future<void> abrirEditarPerfil(BuildContext context) async {
    final usuario = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarPerfilPage(
          nomeInicial: nomeUsuario,
          usernameInicial: username,
          biografiaInicial: biografiaController.text,
          fotoPerfilUrlInicial: fotoPerfilUrl,
        ),
      ),
    );

    if (usuario != null && mounted) {
      setState(() {
        nomeUsuario = usuario['name']?.toString() ?? nomeUsuario;
        username = usuario['username']?.toString() ?? username;
        fotoPerfilUrl = usuario['avatarUrl']?.toString() ?? fotoPerfilUrl;
        biografiaController.text = usuario['bio']?.toString() ?? '';
      });
    }
  }

  void _abrirFoto(PostModel foto) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E9DC),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // FOTO
                    InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Image.network(
                        foto.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const SizedBox(
                            height: 300,
                            child: Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 50,
                                color: Color(0xFF895737),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // LEGENDA
                    if (foto.caption.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          foto.caption,
                          style: const TextStyle(
                            color: Color(0xFF5E3023),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // BOTÃO FECHAR
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.65),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ImageProvider<Object> get imagemPerfil {
    if (fotoPerfilUrl.isNotEmpty) {
      return NetworkImage(fotoPerfilUrl);
    }
    return const AssetImage('assets/images/monalisaPerfil.png');
  }

  @override
  void dispose() {
    biografiaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E9DC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AmigosPage(),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          '$quantidadeAmigos\nAmigos',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            color: Color(0xFF5E3023),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF895737),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image(
                          image: imagemPerfil,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            'assets/images/monalisaPerfil.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: IconButton(
                        onPressed: () => abrirEditarPerfil(context),
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
                Expanded(
                  child: Center(
                    child: Text(
                      '${fotos.length}\nMemórias',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Color(0xFF5E3023),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              nomeUsuario,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              username.isEmpty ? '@username' : '@$username',
              style: const TextStyle(color: Colors.black, fontSize: 10),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: TextField(
                controller: biografiaController,
                readOnly: true,
                showCursor: false,
                enableInteractiveSelection: false,
                minLines: 1,
                maxLines: null,
                maxLength: 150,
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFD7CBBD),
                  hintText: 'Biografia',
                  prefixIcon: const Icon(
                    Icons.chat_bubble,
                    color: Color(0xFF5E3023),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            if (carregandoFotos)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  color: Color(0xFF895737),
                ),
              )
            else if (erroAoCarregarFotos)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Não foi possível carregar suas memórias. Tente novamente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6F5C4A)),
                ),
              )
            else if (fotos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Nenhuma memória ainda.',
                  style: TextStyle(color: Color(0xFF6F5C4A)),
                ),
              )
            else
              _buildGalleryGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryGrid() {
    const columnCount = 3;
    const spacing = 4.0;
    const aspectRatios = [0.78, 1.2, 0.95, 1.35, 0.82, 1.05];
    final columns = List.generate(columnCount, (_) => <int>[]);
    final columnHeights = List<double>.filled(columnCount, 0);

    for (var index = 0; index < fotos.length; index++) {
      var shortestColumn = 0;
      for (var column = 1; column < columnCount; column++) {
        if (columnHeights[column] < columnHeights[shortestColumn]) {
          shortestColumn = column;
        }
      }

      final aspectRatio = aspectRatios[index % aspectRatios.length];
      columns[shortestColumn].add(index);
      columnHeights[shortestColumn] += 1 / aspectRatio + spacing;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var column = 0; column < columnCount; column++) ...[
          if (column > 0) const SizedBox(width: spacing),
          Expanded(
            child: Column(
              children: [
                for (final index in columns[column]) ...[
                  GestureDetector(
                    onTap: () {
                      _abrirFoto(fotos[index]);
                    },
                    child: AspectRatio(
                      aspectRatio: aspectRatios[index % aspectRatios.length],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          fotos[index].imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (
                            context,
                            child,
                            loadingProgress,
                          ) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return Container(
                              color: const Color(0xFFD7CBBD),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF895737),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Container(
                              color: const Color(0xFFD7CBBD),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: Color(0xFF895737),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: spacing),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
