 import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snaplock/theme/app_theme.dart';

class AjudaESuportePage extends StatelessWidget {
  const AjudaESuportePage({super.key});

  static const _faqItems = [
    _FaqItem(
      question: 'Posso enviar uma mensagem direta?',
      answer:
          'O SnapLock não oferece mensagens diretas no momento. Você pode interagir com as publicações disponíveis no app.',
    ),
    _FaqItem(
      question: 'É possível tornar o meu perfil público?',
      answer:
          'No momento, não há uma opção para tornar o perfil público. As publicações seguem as regras de privacidade do SnapLock.',
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
                      _buildContact(),
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
                Icons.subdirectory_arrow_right,
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
                  child: Text(
                    item.answer,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildContact() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 2, 4, 0),
      child: Text.rich(
        TextSpan(
          style: GoogleFonts.poppins(
            color: AppTheme.textSecondary,
            fontSize: 14,
            height: 1.32,
          ),
          children: const [
            TextSpan(
              text: 'Demais dúvidas entre em contato\ncom o nosso suporte:\n',
            ),
            TextSpan(text: 'snaplock.support@gmail.com'),
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
