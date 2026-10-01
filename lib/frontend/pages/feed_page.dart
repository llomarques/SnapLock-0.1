import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              icon: Icon(
                Icons.home_outlined, 
                size: 33.0, 
                color: Colors.black),
                selectedIcon: Icon(
                  Icons.home,
                  size: 40.0,
                  color: Colors.black,
                ),
              label: ''),
          NavigationDestination(
              icon: Icon(
                Icons.notifications_outlined,
                size: 33.0,
                color: Colors.black,
              ),
              selectedIcon: Icon(
                  Icons.notifications,
                  size: 40.0,
                  color: Colors.black,
                ),
              label: ''),
          NavigationDestination(
              icon: Transform.translate(
                offset: Offset(0, -30),
                child: Icon(
                  Icons.add_circle,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              selectedIcon: Transform.translate(
                offset: Offset(0, -30),
                child: Icon(
                  Icons.add_circle,
                  size: 50,
                  color: Colors.black,
                ),
              ),
              label: ''),
          NavigationDestination(
              icon: const ImageIcon(
                AssetImage('assets/images/dump.png'),
                size: 33.0,
                color: Colors.black,
              ),
              selectedIcon: const ImageIcon(
                  AssetImage('assets/images/dump.png'),
                  size: 50.0,
                  color: Colors.black,
                ),
              label: ''),
          NavigationDestination(
              icon: const ImageIcon(
                AssetImage('assets/images/monalisaPerfil.png'),
                size: 33.0,
                color: Colors.black,
              ),
              selectedIcon: const ImageIcon(
                  AssetImage('assets/images/monalisaPerfil.png'),
                  size: 50.0,
                  color: Colors.black,
                ),
              label: ''),
        ],
      ),
    );
  }
}