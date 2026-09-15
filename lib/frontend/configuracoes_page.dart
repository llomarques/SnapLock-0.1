import 'package:flutter/material.dart';
import 'package:snaplock/frontend/inicio_page.dart';
import 'package:snaplock/services/app_language.dart';
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

  Future<void> selecionarIdioma() async {
    final idioma = await showDialog<String>(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: const Color(0xFF895737),
            secondary: const Color(0xFFC08552),
            surface: const Color(0xFFF3E9DC),
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: Color(0xFFF3E9DC),
            surfaceTintColor: Colors.transparent,
          ),
        ),
        child: AlertDialog(
          title: Text(AppLocalizations.of(context).appLanguage),
          content: RadioGroup<String>(
            groupValue: appLanguage.locale.languageCode,
            onChanged: (valor) => Navigator.pop(context, valor),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text('Português (Brasil)'),
                  value: 'pt',
                ),
                RadioListTile<String>(
                  title: Text('English'),
                  value: 'en',
                ),
                RadioListTile<String>(
                  title: Text('Español'),
                  value: 'es',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (idioma != null && mounted) {
      await appLanguage.setLocale(Locale(idioma));
      setState(() {});
    }
  }

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
            leading: const Icon(Icons.language),
            title: Text(AppLocalizations.of(context).language),
            subtitle: Text(appLanguage.languageName),
            onTap: selecionarIdioma,
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