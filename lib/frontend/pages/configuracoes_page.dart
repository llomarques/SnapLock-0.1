import 'package:flutter/material.dart';
import 'package:snaplock/frontend/pages/inicio_page.dart';
import 'package:snaplock/services/app_localizations.dart';
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
        title: Text(AppLocalizations.of(context).settings),
        backgroundColor: const Color(0xFFF3E9DC),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(AppLocalizations.of(context).notifications),
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
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(AppLocalizations.of(context).theme),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.visibility),
            title: Text(AppLocalizations.of(context).viewControl),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(AppLocalizations.of(context).changePassword),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AlterarSenhaPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.call),
            title: Text(AppLocalizations.of(context).help),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(AppLocalizations.of(context).about),
            onTap: abrirSobreNos,
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(AppLocalizations.of(context).logout),
            onTap: () {
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
              AppLocalizations.of(context).deleteAccount,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}