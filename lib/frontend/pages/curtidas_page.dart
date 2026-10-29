import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snaplock/frontend/pages/post_page.dart';
import 'package:snaplock/models/post_model.dart';
import 'package:snaplock/services/api_service.dart';
import 'package:snaplock/theme/app_theme.dart';

class CurtidasPage extends StatefulWidget {
  const CurtidasPage({super.key});

  @override
  State<CurtidasPage> createState() => _CurtidasPageState();
}

class _CurtidasPageState extends State<CurtidasPage> {
  List<PostModel> _posts = [];
  bool _isLoading = true;
  bool _maisAntigasPrimeiro = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarCurtidas();
  }

  Future<void> _carregarCurtidas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final posts = await ApiService.getFeed();
      final curtidas = posts.where((post) => post.userReaction != null).toList()
        ..sort((a, b) {
          final dataA = DateTime.tryParse(a.createdAt);
          final dataB = DateTime.tryParse(b.createdAt);
          if (dataA == null || dataB == null) return 0;
          return _maisAntigasPrimeiro
              ? dataA.compareTo(dataB)
              : dataB.compareTo(dataA);
        });

      if (!mounted) return;
      setState(() {
        _posts = curtidas;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _abrirPublicacao(PostModel post) async {
    final foiAtualizada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PostMaximizadoPage(
          post: post,
          abertaPelasCurtidas: true,
        ),
      ),
    );
    if (foiAtualizada == true && mounted) {
      await _carregarCurtidas();
    }
  }

  List<List<int>> _distribuirColunas() {
    final colunas = [<int>[], <int>[]];
    final alturas = [0.0, 0.0];

    for (var index = 0; index < _posts.length; index++) {
      final post = _posts[index];
      final proporcao = post.aspectRatio != null &&
              post.aspectRatio!.isFinite &&
              post.aspectRatio! > 0
          ? post.aspectRatio!
          : 4 / 5;
      final coluna = alturas[0] <= alturas[1] ? 0 : 1;
      colunas[coluna].add(index);
      alturas[coluna] += 1 / proporcao + 0.04;
    }
    return colunas;
  }

  Widget _buildGrid() {
    const spacing = 10.0;
    final colunas = _distribuirColunas();

    return RefreshIndicator(
      onRefresh: _carregarCurtidas,
      color: AppTheme.mediumBrown,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(17, 18, 17, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var coluna = 0; coluna < colunas.length; coluna++) ...[
              if (coluna > 0) const SizedBox(width: spacing),
              Expanded(
                child: Column(
                  children: [
                    for (final index in colunas[coluna]) ...[
                      _buildPostCard(_posts[index]),
                      const SizedBox(height: spacing),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    final proporcao = post.aspectRatio != null &&
            post.aspectRatio!.isFinite &&
            post.aspectRatio! > 0
        ? post.aspectRatio!
        : 4 / 5;

    return GestureDetector(
      onTap: () => _abrirPublicacao(post),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: proporcao,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: Color(0xFFD7CBBD),
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xB3000000)],
                    ),
                  ),
                  child: Text(
                    '@${post.authorUsername?.isNotEmpty == true ? post.authorUsername : 'usuario'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 3),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _carregarCurtidas,
      color: AppTheme.mediumBrown,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 110),
          Icon(
            _errorMessage == null
                ? Icons.favorite_border_rounded
                : Icons.cloud_off_outlined,
            color: AppTheme.mediumBrown,
            size: 54,
          ),
          const SizedBox(height: 14),
          Text(
            _errorMessage == null
                ? 'Nenhuma curtida por aqui'
                : 'Não foi possível carregar',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ??
                  'Quando você curtir uma publicação, ela aparecerá nesta coleção.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          if (_errorMessage != null)
            TextButton(
              onPressed: _carregarCurtidas,
              child: const Text('Tentar novamente'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 104,
        backgroundColor: const Color(0xFFD7CBBD),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFD7CBBD),
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, size: 30, color: Colors.black),
        ),
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo.png',
          height: 80,
          width: 80,
        ),
        actions: [
          PopupMenuButton<bool>(
            tooltip: 'Filtrar curtidas',
            icon: const Icon(Icons.filter_alt, size: 30, color: Colors.black),
            onSelected: (maisAntigasPrimeiro) {
              setState(() {
                _maisAntigasPrimeiro = maisAntigasPrimeiro;
                _posts.sort((a, b) {
                  final dataA = DateTime.tryParse(a.createdAt);
                  final dataB = DateTime.tryParse(b.createdAt);
                  if (dataA == null || dataB == null) return 0;
                  return maisAntigasPrimeiro
                      ? dataA.compareTo(dataB)
                      : dataB.compareTo(dataA);
                });
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: false,
                child: Text('Mais recentes'),
              ),
              PopupMenuItem(
                value: true,
                child: Text('Mais antigas'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD7CBBD),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Text(
                'Memórias curtidas',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: _isLoading && _posts.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.mediumBrown,
                    ),
                  )
                : _posts.isEmpty
                    ? _buildEmptyState()
                    : _buildGrid(),
          ),
        ],
      ),
    );
  }
}
