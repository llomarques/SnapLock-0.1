import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snaplock/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AjudaESuportePage extends StatelessWidget {
  const AjudaESuportePage({super.key});

  static const _faqItems = [
    _FaqItem(
      question: 'Posso enviar uma mensagem direta?',
      answer:
          'O SnapLock não oferece mensagens diretas. Você pode interagir com as publicações disponíveis no app.',
    ),
    _FaqItem(
      question: 'É possível tornar o meu perfil público?',
      answer:
          'Não há uma opção para tornar o perfil público. As publicações seguem as regras de privacidade do SnapLock.',
    ),
    _FaqItem(
      question: 'Por que não posso comentar em uma foto?',
      answer:
          'O SnapLock não possui comentários em fotos. Você pode deixar uma curtida na publicação.',
    ),
    _FaqItem(
      question: 'Não consigo alterar o meu usuário',
      answer:
          'Acesse seu perfil e toque em Editar perfil. Se o problema continuar, fale com nosso suporte pelo e-mail abaixo.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 360 ? 18.0 : 24.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                26,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 154,
                          height: 154,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSupportLabel(),
                      const SizedBox(height: 20),
                      _buildFaqList(context),
                      const SizedBox(height: 12),
                      _buildContact(context),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSupportLabel() {
    return Row(
      children: [
        const Icon(Icons.support_agent, color: Colors.black, size: 27),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.cardBorder,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            'Ajuda e suporte',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaqList(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.cardBorder,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            'Principais dúvidas',
            style: GoogleFonts.cormorantGaramond(
              color: AppTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final item in _faqItems)
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: AppTheme.mediumBrown.withValues(alpha: 0.08),
              highlightColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 6),
              childrenPadding: const EdgeInsets.fromLTRB(6, 0, 32, 12),
              minTileHeight: 44,
              visualDensity: VisualDensity.compact,
              trailing: const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
                size: 20,
              ),
              title: Text(
                item.question,
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Text(
                      item.answer,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildContact(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.help_outline,
                  color: AppTheme.darkBrown,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demais dúvidas?',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Entre em contato com o nosso suporte:',
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () async {
                final launched = await launchUrl(
                  Uri(
                    scheme: 'mailto',
                    path: 'snaplock.support@gmail.com',
                  ),
                );
                if (!launched && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Não foi possível abrir o aplicativo de e-mail.'),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AppTheme.darkBrown,
              ),
              child: Text(
                'snaplock.support@gmail.com',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}
