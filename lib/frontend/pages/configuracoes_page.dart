import 'package:flutter/material.dart';
import 'package:snaplock/frontend/pages/inicio_page.dart';
import 'package:snaplock/frontend/widgets/criarOpcao_widget.dart';
import 'alterarSenha_page.dart';
import 'sobreNos_page.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  bool notificacoesAtivas = true;

  void abrirSobreNos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SobreNosPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E9DC),
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: const Color(0xFFF3E9DC),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificações'),
            trailing: Transform.scale(
              scale: 0.8,
              child: Switch(
                value: notificacoesAtivas,
                activeThumbColor: Colors.green,
                inactiveThumbColor: Colors.red,
                inactiveTrackColor: Colors.red.shade200,
                onChanged: (valor) {
                  setState(() {
                    notificacoesAtivas = valor;
                  });
                },
              ),
            ),
          ),
          CriarOpcaoWidget(
            icone: Icons.palette,
            titulo: 'Tema',
            aoClicar: () {},
          ),
          CriarOpcaoWidget(
            icone: Icons.visibility,
            titulo: 'Controle de visualizações',
            aoClicar: () {},
          ),
          CriarOpcaoWidget(
            icone: Icons.lock,
            titulo: 'Alterar senha',
            aoClicar: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AlterarSenhaPage(),
                ),
              );
            },
          ),
          CriarOpcaoWidget(
            icone: Icons.call,
            titulo: 'Ajuda e suporte',
            aoClicar: () {},
          ),
          CriarOpcaoWidget(
            icone: Icons.info,
            titulo: 'Sobre nós',
            aoClicar: abrirSobreNos,
          ),
          CriarOpcaoWidget(
            icone: Icons.logout,
            titulo: 'Sair da conta',
            aoClicar: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const InicioPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: Text(
              'Deletar conta',
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}