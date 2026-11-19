import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snaplock/frontend/pages/inicio_page.dart';
import 'package:snaplock/frontend/widgets/criarOpcao_widget.dart';
import 'package:snaplock/theme/app_theme.dart';
import 'package:snaplock/theme/app_theme_controller.dart';
import 'alterarSenha_page.dart';
import 'sobreNos_page.dart';
import 'alterarEmail_page.dart';
import 'curtidas_page.dart';
import 'ajudaESuporte_page.dart';
import 'deletar_page.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  bool notificacoesAtivas = true;
  bool alterandoTema = false;

  Future<void> alterarTema(bool ativarModoEscuro) async {
    if (alterandoTema) return;
    setState(() => alterandoTema = true);
    try {
      await AppThemeController.instance.setDark(ativarModoEscuro);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível alterar o tema: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => alterandoTema = false);
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: const Text('Configurações'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
                activeThumbColor: AppTheme.success,
                inactiveThumbColor: AppTheme.danger,
                inactiveTrackColor: AppTheme.danger.withValues(alpha: 0.35),
                onChanged: (valor) {
                  setState(() {
                    notificacoesAtivas = valor;
                  });
                },
              ),
            ),
          ),
          AnimatedBuilder(
            animation: AppThemeController.instance,
            builder: (context, _) {
              final isDark = AppThemeController.instance.isDark;
              final theme = Theme.of(context);
              return ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Tema'),
                trailing: PopupMenuButton<bool>(
                  enabled: !alterandoTema,
                  onSelected: alterarTema,
                  color: theme.colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem<bool>(
                      value: false,
                      child: Row(
                        children: [
                          Icon(
                            Icons.light_mode_outlined,
                            color: isDark
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          const Text('Claro'),
                          if (!isDark) ...[
                            const Spacer(),
                            Icon(Icons.check, color: theme.colorScheme.primary),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuItem<bool>(
                      value: true,
                      child: Row(
                        children: [
                          Icon(
                            Icons.dark_mode_outlined,
                            color: isDark
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 10),
                          const Text('Escuro'),
                          if (isDark) ...[
                            const Spacer(),
                            Icon(Icons.check, color: theme.colorScheme.primary),
                          ],
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 112),
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isDark ? 'Escuro' : 'Claro',
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          CriarOpcaoWidget(
            icone: Icons.favorite,
            titulo: 'Minhas curtidas',
            aoClicar: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CurtidasPage(),
                ),
              );
            },
          ),
          CriarOpcaoWidget(
            icone: Icons.email,
            titulo: 'Alterar email',
            aoClicar: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AlterarEmailPage(),
                ),
              );
            },
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
            aoClicar: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AjudaESuportePage(),
                ),
              );
            },
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
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  title: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.mediumBrown.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.logout,
                          color: AppTheme.mediumBrown,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sair da conta?',
                          style: GoogleFonts.cormorantGaramond(
                            color: Theme.of(context).colorScheme.onSurface,
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.mediumBrown,
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
            leading: Icon(Icons.delete, color: AppTheme.danger),
            title: Text(
              'Deletar conta',
              style: TextStyle(color: AppTheme.danger),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeletarPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
