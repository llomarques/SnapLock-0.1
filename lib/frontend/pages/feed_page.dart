import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snaplock/controller/controller.login.dart';
import 'package:snaplock/models/post_model.dart';
import 'package:snaplock/services/api_service.dart';
import 'package:snaplock/frontend/widgets/avatar_square_widget.dart';
import 'package:snaplock/frontend/pages/inicio_page.dart';
import 'notificacoes_page.dart';
import 'postar_page.dart';
import 'dump_page.dart';
import 'perfil_page.dart';
import 'configuracoes_page.dart';
import 'pesquisa_page.dart';

class FeedPage extends StatefulWidget {
  final int initialIndex;

  const FeedPage({super.key, this.initialIndex = 0});

  @override
  State<FeedPage> createState() => _FeedPage();
}

class FeedHeader extends StatelessWidget {
  const FeedHeader({
    super.key,
    required this.onMenuPressed,
    this.mostrarAcoes = true,
  });

  final VoidCallback onMenuPressed;
  final bool mostrarAcoes;

  void abrirPesquisa(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PesquisaPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFD7CBBD),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Container(
        color: const Color(0xFFD7CBBD),
        child: SafeArea(
          bottom: false,
          child: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 110,
            leading: mostrarAcoes
                ? IconButton(
                    onPressed: onMenuPressed,
                    icon: const Icon(
                      Icons.menu,
                      size: 35.0,
                      color: Colors.black,
                    ),
                  )
                : null,
            centerTitle: true,
            title: Image.asset(
              'assets/images/logo.png',
              height: 80,
              width: 80,
            ),
            actions: mostrarAcoes
                ? [
                    IconButton(
                      onPressed: () => abrirPesquisa(context),
                      icon: const Icon(
                        Icons.person_search,
                        size: 35.0,
                        color: Colors.black,
                      ),
                    ),
                  ]
                : const [],
            backgroundColor: const Color(0xFFD7CBBD),
          ),
        ),
      ),
    );
  }
}

class FeedConteudoPage extends StatefulWidget {
  const FeedConteudoPage({super.key});

  @override
  State<FeedConteudoPage> createState() => _FeedConteudoPageState();
}

class _FeedConteudoPageState extends State<FeedConteudoPage> {
  static const _fallbackAspectRatios = [0.8, 1.0, 1.2, 1.4];
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
      if (!mounted) return;

      setState(() {
        _posts = posts;
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

  List<double> get _aspectRatios =>
      List<double>.generate(_posts.length, (index) {
        final ratio = _posts[index].aspectRatio;
        if (ratio != null && ratio.isFinite && ratio > 0) return ratio;
        return _fallbackAspectRatios[index % _fallbackAspectRatios.length];
      });

  Widget _buildGrid() {
    const spacing = 10.0;
    final ratios = _aspectRatios;
    final columns = List.generate(2, (_) => <int>[]);
    final heights = List<double>.filled(2, 0);

    for (var index = 0; index < _posts.length; index++) {
      final column = heights[0] <= heights[1] ? 0 : 1;
      columns[column].add(index);
      heights[column] += 1 / ratios[index] + spacing;
    }

    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var column = 0; column < 2; column++) ...[
              if (column > 0) const SizedBox(width: spacing),
              Expanded(
                child: Column(
                  children: [
                    for (final index in columns[column]) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: AspectRatio(
                          aspectRatio: ratios[index],
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                _posts[index].imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const ColoredBox(
                                  color: Color(0xFFD7CBBD),
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Color(0xFF6F5C4A),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(
                                    8,
                                    22,
                                    8,
                                    8,
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
                                    '@${_posts[index].authorUsername ?? 'usuario'}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF895737)),
      );
    }

    if (_errorMessage != null && _posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(
                onPressed: _loadFeed, child: const Text('Tentar novamente')),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadFeed,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 260,
              child: Center(child: Text('Nenhuma publicação no feed.')),
            ),
          ],
        ),
      );
    }

    return _buildGrid();
  }
}

class _FeedPage extends State<FeedPage> {
  late int indice;
  Timer? _timerNotificacoes;
  final Set<String> _solicitacoesConhecidas = {};
  bool _temNotificacaoNova = false;
  bool _inicializouNotificacoes = false;
  int _versaoLeituraNotificacoes = 0;

  Widget _iconePerfil(double tamanho) {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: LoginController.usuarioNotifier,
      builder: (context, usuario, child) => AvatarSquareWidget(
        imageUrl: usuario?['avatarUrl']?.toString() ?? '',
        size: tamanho,
        backgroundColor: Colors.transparent,
        iconColor: Colors.black,
        fallbackAsset: 'assets/images/monalisaPerfil.png',
      ),
    );
  }

  Widget _iconeNotificacoes(IconData icone, double tamanho) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icone, size: tamanho, color: Colors.black),
        if (_temNotificacaoNova)
          Positioned(
            top: 0,
            right: -1,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFC08552),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD7CBBD),
                  width: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  final telas = const [
    FeedConteudoPage(),
    NotificacoesPage(),
    PostarPage(),
    DumpPage(),
    PerfilPage()
  ];

  @override
  void initState() {
    super.initState();
    indice = widget.initialIndex.clamp(0, telas.length - 1);
    _atualizarNotificacoes();
    _timerNotificacoes = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _atualizarNotificacoes(),
    );
  }

  @override
  void dispose() {
    _timerNotificacoes?.cancel();
    super.dispose();
  }

  Future<void> _atualizarNotificacoes({bool marcarComoLidas = false}) async {
    final versaoNoInicio = _versaoLeituraNotificacoes;
    try {
      final pendentes = await ApiService.getPendingRequests();
      if (!mounted) return;

      final idsAtuais = pendentes
          .map((solicitacao) => solicitacao['requestId']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      final idsNovos = idsAtuais.difference(_solicitacoesConhecidas);

      setState(() {
        if (!_inicializouNotificacoes) {
          _temNotificacaoNova = indice != 1 && idsAtuais.isNotEmpty;
          _inicializouNotificacoes = true;
        } else if (marcarComoLidas) {
          _temNotificacaoNova = false;
        } else if (idsNovos.isNotEmpty &&
            versaoNoInicio == _versaoLeituraNotificacoes) {
          _temNotificacaoNova = true;
        }

        _solicitacoesConhecidas
          ..clear()
          ..addAll(idsAtuais);
      });
    } catch (_) {
      // Mantém o indicador atual se a API estiver indisponível.
    }
  }

  void _selecionarAba(int valor) {
    setState(() {
      indice = valor;
      if (valor == 1) {
        _temNotificacaoNova = false;
        _versaoLeituraNotificacoes++;
      }
    });

    if (valor == 1) {
      _atualizarNotificacoes(marcarComoLidas: true);
    }
  }

  void abrirConfiguracoes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConfiguracoesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E9DC),
      drawer: Drawer(
        backgroundColor: const Color(0xFFC08552),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 60, bottom: 12),
              child: Image.asset(
                'assets/images/logo.png',
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                setState(() => indice = 4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificações'),
              onTap: () {
                Navigator.pop(context);
                _selecionarAba(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                abrirConfiguracoes();
              },
            ),
            ListTile(
              leading: const Icon(Icons.call),
              title: const Text('Ajuda e suporte'),
              onTap: () {
                Navigator.pop(context);
                setState(() => indice = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InicioPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Builder(
            builder: (context) => FeedHeader(
              onMenuPressed: () => Scaffold.of(context).openDrawer(),
              mostrarAcoes: indice != 2,
            ),
          ),
          Expanded(child: telas[indice]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFFD7CBBD),
        indicatorColor: Colors.transparent,
        onDestinationSelected: _selecionarAba,
        selectedIndex: indice,
        destinations: [
          NavigationDestination(
              icon: _TapScale(
                  child: Icon(Icons.home_outlined,
                      size: 33.0, color: Colors.black)),
              selectedIcon: _TapScale(
                  child: Icon(
                Icons.home,
                size: 40.0,
                color: Colors.black,
              )),
              label: ''),
          NavigationDestination(
              icon: _TapScale(
                child: _iconeNotificacoes(Icons.notifications_outlined, 33),
              ),
              selectedIcon: _TapScale(
                child: _iconeNotificacoes(Icons.notifications, 40),
              ),
              label: ''),
          NavigationDestination(
              icon: _TapScale(
                  child: Transform.translate(
                offset: Offset(0, -30),
                child: Icon(
                  Icons.add_circle,
                  size: 40,
                  color: Colors.black,
                ),
              )),
              selectedIcon: _TapScale(
                  child: Transform.translate(
                offset: Offset(0, -30),
                child: Icon(
                  Icons.add_circle,
                  size: 50,
                  color: Colors.black,
                ),
              )),
              label: ''),
          NavigationDestination(
              icon: _TapScale(
                  child: const ImageIcon(
                AssetImage('assets/images/dump.png'),
                size: 33.0,
                color: Colors.black,
              )),
              selectedIcon: _TapScale(
                  child: const ImageIcon(
                AssetImage('assets/images/dump.png'),
                size: 50.0,
                color: Colors.black,
              )),
              label: ''),
          NavigationDestination(
              icon: _TapScale(child: _iconePerfil(30)),
              selectedIcon: _TapScale(child: _iconePerfil(37)),
              label: ''),
        ],
      ),
    );
  }
}

class _TapScale extends StatefulWidget {
  const _TapScale({required this.child});

  final Widget child;

  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale> {
  bool _pressed = false;

  void _release(PointerEvent _) {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: _release,
      onPointerCancel: _release,
      child: AnimatedScale(
        scale: _pressed ? 0.84 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
