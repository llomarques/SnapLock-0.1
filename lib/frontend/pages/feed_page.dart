import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snaplock/controller/controller.login.dart';
import 'package:snaplock/models/post_model.dart';
import 'package:snaplock/services/api_service.dart';
import 'package:snaplock/frontend/widgets/avatar_square_widget.dart';
import 'package:snaplock/frontend/pages/inicio_page.dart';
import 'package:snaplock/theme/app_theme.dart';
import 'notificacoes_page.dart';
import 'postar_page.dart';
import 'dump_page.dart';
import 'perfil_page.dart';
import 'configuracoes_page.dart';
import 'pesquisa_page.dart';
import 'post_page.dart';

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
    this.mostrarVoltar = false,
    this.trailingAction,
  });

  final VoidCallback onMenuPressed;
  final bool mostrarAcoes;
  final bool mostrarVoltar;
  final Widget? trailingAction;

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
            leading: mostrarVoltar
                ? IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: Colors.black,
                    ),
                  )
                : (mostrarAcoes
                    ? IconButton(
                        onPressed: onMenuPressed,
                        icon: const Icon(
                          Icons.menu,
                          size: 35.0,
                          color: Colors.black,
                        ),
                      )
                    : null),
            centerTitle: true,
            title: Image.asset(
              'assets/images/logo.png',
              height: 80,
              width: 80,
            ),
            actions: trailingAction != null
                ? [trailingAction!]
                : mostrarAcoes
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

class FeedNavigationBar extends StatelessWidget {
  const FeedNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.temNotificacaoNova = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool temNotificacaoNova;

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
        if (temNotificacaoNova)
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

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: const Color(0xFFD7CBBD),
      indicatorColor: Colors.transparent,
      onDestinationSelected: onDestinationSelected,
      selectedIndex: selectedIndex,
      destinations: [
        NavigationDestination(
          icon: _TapScale(
            child: const Icon(
              Icons.home_outlined,
              size: 33,
              color: Colors.black,
            ),
          ),
          selectedIcon: _TapScale(
            child: const Icon(Icons.home, size: 40, color: Colors.black),
          ),
          label: '',
        ),
        NavigationDestination(
          icon: _TapScale(
            child: _iconeNotificacoes(Icons.notifications_outlined, 33),
          ),
          selectedIcon: _TapScale(
            child: _iconeNotificacoes(Icons.notifications, 40),
          ),
          label: '',
        ),
        const NavigationDestination(
          icon: SizedBox.shrink(),
          selectedIcon: SizedBox.shrink(),
          label: '',
        ),
        NavigationDestination(
          icon: _TapScale(
            child: const ImageIcon(
              AssetImage('assets/images/dump.png'),
              size: 33,
              color: Colors.black,
            ),
          ),
          selectedIcon: _TapScale(
            child: const ImageIcon(
              AssetImage('assets/images/dump.png'),
              size: 50,
              color: Colors.black,
            ),
          ),
          label: '',
        ),
        NavigationDestination(
          icon: _TapScale(child: _iconePerfil(30)),
          selectedIcon: _TapScale(child: _iconePerfil(37)),
          label: '',
        ),
      ],
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

  Future<void> _openPost(PostModel post) async {
    final excluido = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PostMaximizadoPage(post: post),
      ),
    );
    if (excluido == true) await _loadFeed();
  }

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
                      GestureDetector(
                        onTap: () => _openPost(_posts[index]),
                        child: ClipRRect(
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

class _FeedPage extends State<FeedPage> with SingleTickerProviderStateMixin {
  late int indice;
  late final AnimationController _animacaoZoomPostagem;
  bool _animandoZoomPostagem = false;
  bool _revelarPostagem = false;
  bool _drawerAberto = false;
  Timer? _timerNotificacoes;
  final Set<String> _solicitacoesConhecidas = {};
  final Set<String> _avisosAmizadeConhecidos = {};
  bool _temNotificacaoNova = false;
  bool _inicializouNotificacoes = false;
  int _versaoLeituraNotificacoes = 0;

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
    _animacaoZoomPostagem = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
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
    _animacaoZoomPostagem.dispose();
    super.dispose();
  }

  Future<void> _atualizarNotificacoes({bool marcarComoLidas = false}) async {
    final versaoNoInicio = _versaoLeituraNotificacoes;
    try {
      final resultados = await Future.wait<List<Map<String, dynamic>>>([
        ApiService.getPendingRequests(),
        ApiService.getAcceptedFriendNotifications(),
      ]);
      if (!mounted) return;

      final pendentes = resultados[0];
      final avisosAmizade = resultados[1];
      final idsAtuais = pendentes
          .map((solicitacao) => solicitacao['requestId']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      final idsNovos = idsAtuais.difference(_solicitacoesConhecidas);
      final idsAvisos = avisosAmizade
          .map((aviso) => aviso['notificationId']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      final idsAvisosNaoLidos = avisosAmizade
          .where((aviso) => aviso['read'] != true)
          .map((aviso) => aviso['notificationId']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      final avisosNovos = idsAvisosNaoLidos.difference(
        _avisosAmizadeConhecidos,
      );

      if (marcarComoLidas) {
        await ApiService.markAcceptedFriendNotificationsRead(avisosAmizade);
      }
      if (!mounted) return;

      setState(() {
        if (!_inicializouNotificacoes) {
          _temNotificacaoNova = indice != 1 &&
              (idsAtuais.isNotEmpty || idsAvisosNaoLidos.isNotEmpty);
          _inicializouNotificacoes = true;
        } else if (marcarComoLidas) {
          _temNotificacaoNova = false;
        } else if ((idsNovos.isNotEmpty || avisosNovos.isNotEmpty) &&
            versaoNoInicio == _versaoLeituraNotificacoes) {
          _temNotificacaoNova = true;
        }

        _solicitacoesConhecidas
          ..clear()
          ..addAll(idsAtuais);
        _avisosAmizadeConhecidos
          ..clear()
          ..addAll(idsAvisos);
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

  void _abrirPostagemComZoom() {
    if (_animandoZoomPostagem) return;

    setState(() {
      _animandoZoomPostagem = true;
      _revelarPostagem = true;
    });
    _animacaoZoomPostagem.forward().whenComplete(() {
      if (!mounted) return;
      _selecionarAba(2);
      setState(() => _revelarPostagem = false);
    });
  }

  void _finalizarAnimacaoPostagem() {
    if (_revelarPostagem || !_animandoZoomPostagem) return;
    setState(() => _animandoZoomPostagem = false);
    _animacaoZoomPostagem.reset();
  }

  void abrirConfiguracoes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConfiguracoesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tamanhoTela = MediaQuery.sizeOf(context);
    final distanciaInferior = MediaQuery.viewPaddingOf(context).bottom + 38.0;
    final centroY = tamanhoTela.height - distanciaInferior - 32.0;
    final distanciaMaiorCanto = math.sqrt(
      math.pow(tamanhoTela.width / 2, 2) +
          math.pow(math.max(centroY, tamanhoTela.height - centroY), 2),
    );
    final escalaFinalZoom = (distanciaMaiorCanto * 1.15) / 20;

    return Stack(
      fit: StackFit.expand,
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF3E9DC),
          onDrawerChanged: (aberto) {
            setState(() => _drawerAberto = aberto);
          },
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
                  onTap: () async {
                    final confirmarSaida = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        backgroundColor: AppTheme.textPrimary,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: const BorderSide(color: AppTheme.cardBorder),
                        ),
                        title: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.danger.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.logout,
                                color: AppTheme.danger,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Sair da conta?',
                                style: GoogleFonts.cormorantGaramond(
                                  color: AppTheme.background,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          'Tem certeza que deseja sair?',
                          style: GoogleFonts.poppins(
                            color: AppTheme.surface,
                            fontSize: 14,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.surface,
                              textStyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.danger,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            icon: const Icon(Icons.logout, size: 18),
                            label: const Text('Sair'),
                          ),
                        ],
                      ),
                    );

                    if (confirmarSaida != true || !mounted) return;
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
          bottomNavigationBar: FeedNavigationBar(
            selectedIndex: indice,
            onDestinationSelected: _selecionarAba,
            temNotificacaoNova: _temNotificacaoNova,
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
          child: AbsorbPointer(
            absorbing: _animandoZoomPostagem,
            child: AnimatedBuilder(
              animation: _animacaoZoomPostagem,
              builder: (context, child) {
                final progresso =
                    Curves.easeInCubic.transform(_animacaoZoomPostagem.value);
                final raio = distanciaMaiorCanto * 1.15 * progresso;

                return ClipPath(
                  clipper: _CircularRevealClipper(
                    center: Offset(tamanhoTela.width / 2, centroY),
                    radius: raio,
                  ),
                  child: AnimatedOpacity(
                    opacity: _revelarPostagem ? 1 : 0,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                    onEnd: _finalizarAnimacaoPostagem,
                    child: child,
                  ),
                );
              },
              child: const ColoredBox(color: Color(0xFFF3E9DC)),
            ),
          ),
        ),
        if (!_drawerAberto && indice != 2)
          Positioned(
            left: 0,
            right: 0,
            bottom: distanciaInferior,
            child: Center(
              child: Semantics(
                button: true,
                label: 'Postar foto',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _abrirPostagemComZoom,
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: AnimatedBuilder(
                      animation: _animacaoZoomPostagem,
                      child: const Icon(
                        Icons.add_circle,
                        size: 44,
                        color: Colors.black,
                      ),
                      builder: (context, child) {
                        final progresso = _animacaoZoomPostagem.value;
                        final fade =
                            ((progresso - 0.72) / 0.28).clamp(0.0, 1.0);
                        final opacidade = 1 - Curves.easeIn.transform(fade);
                        final escalaZoom = 1 +
                            (escalaFinalZoom - 1) *
                                Curves.easeInCubic.transform(progresso);
                        final escalaToque = 1 +
                            0.55 *
                                Curves.easeOut.transform(
                                  (progresso / 0.16).clamp(0.0, 1.0),
                                );
                        final escala = escalaZoom * escalaToque;

                        return IgnorePointer(
                          child: Opacity(
                            opacity: opacidade,
                            child: Transform.scale(
                              scale: escala,
                              child: child,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CircularRevealClipper extends CustomClipper<Path> {
  const _CircularRevealClipper({required this.center, required this.radius});

  final Offset center;
  final double radius;

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(covariant _CircularRevealClipper oldClipper) {
    return oldClipper.center != center || oldClipper.radius != radius;
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
