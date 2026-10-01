import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snaplock/controller/controller.login.dart';
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
  const FeedHeader({super.key, required this.onMenuPressed});

  final VoidCallback onMenuPressed;

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
            leading: IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(Icons.menu, size: 35.0, color: Colors.black),
            ),
            centerTitle: true,
            title: Image.asset(
              'assets/images/logo.png',
              height: 80,
              width: 80,
            ),
            actions: [
              IconButton(
                onPressed: () => abrirPesquisa(context),
                icon: const Icon(Icons.person_search, size: 35.0, color: Colors.black),
              ),
            ],
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

class _FeedPage extends State<FeedPage> {
   late int indice;

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
                setState(() => indice = 1);
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
            ),
          ),
          Expanded(child: telas[indice]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFFD7CBBD),
        indicatorColor: Colors.transparent,
        onDestinationSelected: (valor) {
          setState(() {
            indice = valor;
          });
        },
        selectedIndex: indice,
        destinations: [
          NavigationDestination(
              icon: _TapScale(child: Icon(
                Icons.home_outlined, 
                size: 33.0, 
                color: Colors.black)),
                selectedIcon: _TapScale(child: Icon(
                  Icons.home,
                  size: 40.0,
                  color: Colors.black,
                )),
              label: ''),
          NavigationDestination(
              icon: _TapScale(child: Icon(
                Icons.notifications_outlined,
                size: 33.0,
                color: Colors.black,
              )),
              selectedIcon: _TapScale(child: Icon(
                  Icons.notifications,
                  size: 40.0,
                  color: Colors.black,
                )),
              label: ''),
          NavigationDestination(
              icon: _TapScale(child: Transform.translate(
                offset: Offset(0, -30),
                child: Icon(
                  Icons.add_circle,
                  size: 40,
                  color: Colors.black,
                ),
              )),
              selectedIcon: _TapScale(child: Transform.translate(
                offset: Offset(0, -30),
                child: Icon(
                  Icons.add_circle,
                  size: 50,
                  color: Colors.black,
                ),
              )),
              label: ''),
          NavigationDestination(
              icon: _TapScale(child: const ImageIcon(
                AssetImage('assets/images/dump.png'),
                size: 33.0,
                color: Colors.black,
              )),
              selectedIcon: _TapScale(child: const ImageIcon(
                  AssetImage('assets/images/dump.png'),
                  size: 50.0,
                  color: Colors.black,
                )),
              label: ''),
          NavigationDestination(
              icon: _TapScale(child: const ImageIcon(
                AssetImage('assets/images/monalisaPerfil.png'),
                size: 33.0,
                color: Colors.black,
              )),
              selectedIcon: _TapScale(child: const ImageIcon(
                  AssetImage('assets/images/monalisaPerfil.png'),
                  size: 50.0,
                  color: Colors.black,
                )),
              icon: _iconePerfil(33),
              selectedIcon: _iconePerfil(50),
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