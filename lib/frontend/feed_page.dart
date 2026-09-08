import 'package:flutter/material.dart';
import 'notificacoes_page.dart';
import 'postar_page.dart';
import 'dump_page.dart';
import 'perfil_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPage();
}

class _FeedPage extends State<FeedPage> {
  int indice = 0;

  final telas = const [
    FeedConteudoPage(),
    NotificacoesPage(),
    PostarPage(),
    DumpPage(),
    PerfilPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3E9DC),
      body: telas[indice],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (valor) {
          setState(() {
            indice = valor;
          });
        },
        selectedIndex: indice,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: ''),
          NavigationDestination(
              icon: Icon(Icons.notifications), label: ''),
          NavigationDestination(icon: Icon(Icons.add_a_photo), label: ''),
          NavigationDestination(
              icon: const ImageIcon(
                AssetImage('assets/images/dump.png'),
              ),
              label: ''),
          NavigationDestination(
              icon: const ImageIcon(
                AssetImage('assets/images/monalisaPerfil.png'),
              ),
              label: ''),
        ],
      ),
    );
  }
}

class FeedConteudoPage extends StatelessWidget {
  const FeedConteudoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Feed'),
    );
  }
}
