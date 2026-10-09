import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snaplock/frontend/pages/inicio_page.dart';
import 'package:snaplock/frontend/widgets/criarOpcao_widget.dart';
import 'package:snaplock/theme/app_theme.dart';
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
            aoClicar: () async {
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
                      onPressed: () => Navigator.pop(dialogContext, false),
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
