import 'package:flutter/material.dart';
import 'package:snaplock/services/api_service.dart';
import 'package:snaplock/models/post_model.dart';
import 'editarPerfil_page.dart';
import 'amigos_page.dart';
import 'post_page.dart';
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
      final galeria = await ApiService.getMyGallery();

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
      print('ERRO: $e');
      print('STACK TRACE:');
      print(stackTrace);

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
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PostMaximizadoPage(post: foto),
      ),
    ).then((excluido) {
      if (excluido == true && mounted) carregarFotos();
    });
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileDetailTextColor = isDark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;
    final profileStatsTextColor =
        isDark ? theme.colorScheme.onSurface : theme.colorScheme.primary;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                          style: TextStyle(
                            fontSize: 17,
                            color: profileStatsTextColor,
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
                          color: theme.colorScheme.primary,
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
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
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
                      style: TextStyle(
                        fontSize: 17,
                        color: profileStatsTextColor,
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
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              username.isEmpty ? '@username' : '@$username',
              style: TextStyle(
                color: profileDetailTextColor,
                fontSize: 10,
              ),
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
                style: isDark
                    ? TextStyle(color: theme.colorScheme.onSurface)
                    : null,
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  hintText: 'Biografia',
                  prefixIcon: Icon(
                    Icons.chat_bubble,
                    color: theme.colorScheme.primary,
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
            Divider(
              color: theme.colorScheme.outlineVariant,
              thickness: 2.0, // Espessura da linha
              height: 20.0, // Espaço ao redor da linha
            ),
            const SizedBox(
              height: 20,
            ),
            if (carregandoFotos)
              Padding(
                padding: EdgeInsets.all(24),
                child:
                    CircularProgressIndicator(color: theme.colorScheme.primary),
              )
            else if (erroAoCarregarFotos)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Não foi possível carregar suas memórias. Tente novamente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: profileDetailTextColor),
                ),
              )
            else if (fotos.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Nenhuma memória ainda.',
                  style: TextStyle(color: profileDetailTextColor),
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
    const columnCount = 2;
    const spacing = 4.0;
    final aspectRatios = List<double>.generate(fotos.length, (index) {
      final savedAspectRatio = fotos[index].aspectRatio;
      if (savedAspectRatio != null &&
          savedAspectRatio.isFinite &&
          savedAspectRatio > 0) {
        return savedAspectRatio;
      }
      return 4 / 5;
    });
    final columns = List.generate(columnCount, (_) => <int>[]);
    final columnHeights = List<double>.filled(columnCount, 0);

    for (var index = 0; index < fotos.length; index++) {
      var shortestColumn = 0;
      for (var column = 1; column < columnCount; column++) {
        if (columnHeights[column] < columnHeights[shortestColumn]) {
          shortestColumn = column;
        }
      }

      final aspectRatio = aspectRatios[index];
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
                      aspectRatio: aspectRatios[index],
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Theme.of(context).colorScheme.primary,
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
