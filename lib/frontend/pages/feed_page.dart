import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snaplock/controller/controller.login.dart';
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

class FeedConteudoPage extends StatelessWidget {
  const FeedConteudoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: const Text('Feed'),
    );
  }
}

class _FeedPage extends State<FeedPage> with SingleTickerProviderStateMixin {
  late int indice;
  late final AnimationController _animacaoZoomPostagem;
  bool _animandoZoomPostagem = false;
  bool _revelarPostagem = false;
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
              const NavigationDestination(
                icon: SizedBox.shrink(),
                selectedIcon: SizedBox.shrink(),
                label: '',
              ),
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
                  width: 64,
                  height: 64,
                  child: AnimatedBuilder(
                    animation: _animacaoZoomPostagem,
                    child: const Icon(
                      Icons.add_circle,
                      size: 40,
                      color: Colors.black,
                    ),
                    builder: (context, child) {
                      final progresso = _animacaoZoomPostagem.value;
                      final fade = ((progresso - 0.72) / 0.28).clamp(0.0, 1.0);
                      final opacidade = 1 - Curves.easeIn.transform(fade);
                      final escala = 1 +
                          (escalaFinalZoom - 1) *
                              Curves.easeInCubic.transform(progresso);

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
