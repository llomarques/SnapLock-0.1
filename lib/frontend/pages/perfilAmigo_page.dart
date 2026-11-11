import 'package:flutter/material.dart';
import 'package:snaplock/theme/app_theme.dart';
import 'package:snaplock/frontend/widgets/logo_sobre_nos_widget.dart';
import 'package:snaplock/frontend/pages/configuracoes_page.dart';
import 'package:snaplock/frontend/pages/feed_page.dart';
import 'package:snaplock/frontend/pages/inicio_page.dart';
import 'package:snaplock/models/post_model.dart';
import 'package:snaplock/models/user_model.dart';
import 'package:snaplock/services/api_service.dart';
import 'post_page.dart';

class PerfilAmigoPage extends StatefulWidget {
  const PerfilAmigoPage({super.key, required this.amigo});

  final UserModel amigo;

  @override
  State<PerfilAmigoPage> createState() => _PerfilAmigoPageState();
}

class _PerfilAmigoPageState extends State<PerfilAmigoPage> {
  List<PostModel> _publicacoes = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarPublicacoes();
  }

  Future<void> _carregarPublicacoes() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final publicacoes = await ApiService.getFriendGallery(widget.amigo.id);
      if (!mounted) return;

      setState(() {
        _publicacoes = publicacoes;
        _carregando = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _erro = error.toString().replaceFirst('Exception: ', '');
        _carregando = false;
      });
    }
  }

  List<double> get _aspectRatios => List<double>.generate(
        _publicacoes.length,
        (index) {
          final ratio = _publicacoes[index].aspectRatio;
          if (ratio != null && ratio.isFinite && ratio > 0) return ratio;
          return 4 / 5;
        },
      );

  Widget _buildProfileHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profileStatsTextColor = theme.brightness == Brightness.dark
        ? colorScheme.onSurface
        : colorScheme.primary;
    final avatar = widget.amigo.avatarUrl.isEmpty
        ? Image.asset(
            'assets/images/monalisaPerfil.png',
            fit: BoxFit.cover,
          )
        : Image.network(
            widget.amigo.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/monalisaPerfil.png',
                fit: BoxFit.cover),
          );

    return Column(
      children: [
        const SizedBox(height: 25),
        Row(
          children: [
            Expanded(
              child: Text(
                '${widget.amigo.friendsCount}\nAmigos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: profileStatsTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: avatar,
              ),
            ),
            Expanded(
              child: Text(
                '${_publicacoes.length}\nMemórias',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: profileStatsTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          widget.amigo.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          widget.amigo.username.isEmpty
              ? '@username'
              : '@${widget.amigo.username}',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.chat_bubble, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.amigo.bio.isEmpty
                      ? 'Biografia não informada.'
                      : widget.amigo.bio,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Divider(
          color: colorScheme.outlineVariant,
          thickness: 2,
          height: 20,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGallery() {
    final colorScheme = Theme.of(context).colorScheme;
    if (_carregando) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    if (_erro != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(
              _erro!,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            TextButton(
              onPressed: _carregarPublicacoes,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_publicacoes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Nenhuma memória ainda.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return _buildGalleryGrid();
  }

  Widget _buildGalleryGrid() {
    final colorScheme = Theme.of(context).colorScheme;
    const columnCount = 2;
    const spacing = 10.0;
    final aspectRatios = _aspectRatios;
    final columns = List.generate(columnCount, (_) => <int>[]);
    final columnHeights = List<double>.filled(columnCount, 0);

    for (var index = 0; index < _publicacoes.length; index++) {
      var shortestColumn = 0;
      for (var column = 1; column < columnCount; column++) {
        if (columnHeights[column] < columnHeights[shortestColumn]) {
          shortestColumn = column;
        }
      }

      columns[shortestColumn].add(index);
      columnHeights[shortestColumn] += 1 / aspectRatios[index] + spacing;
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
                    onTap: () => _abrirFoto(_publicacoes[index]),
                    child: AspectRatio(
                      aspectRatio: aspectRatios[index],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          _publicacoes[index].imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              ColoredBox(
                            color: colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
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

  void _abrirFoto(PostModel foto) {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PostMaximizadoPage(post: foto),
      ),
    ).then((excluido) {
      if (excluido == true && mounted) _carregarPublicacoes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: Drawer(
        backgroundColor: isDark ? theme.colorScheme.surface : AppTheme.lightBrown,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 60, bottom: 12),
              child: LogoSobreNosWidget(
                assetPath: 'assets/images/logo.png',
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeedPage(initialIndex: 4),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificações'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeedPage(initialIndex: 1),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConfiguracoesPage(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.call),
              title: const Text('Ajuda e suporte'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FeedPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const InicioPage()),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Builder(
            builder: (context) => FeedHeader(
              onMenuPressed: () => Scaffold.of(context).openDrawer(),
              mostrarVoltar: true,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _carregarPublicacoes,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    _buildGallery(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
