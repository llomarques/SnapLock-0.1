import 'package:flutter/material.dart';

class SobreNosPage extends StatelessWidget {
  const SobreNosPage({super.key});

  static const _background = Color(0xFFF3E9DC);
  static const _darkBrown = Color(0xFF5E3023);
  static const _mediumBrown = Color(0xFF895737);
  static const _textColor = Color(0xFF3E3A36);
  static const _mutedText = Color(0xFF6E6760);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _darkBrown,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHero(),
                const SizedBox(height: 28),
                const _SectionHeading(
                  eyebrow: 'NOSSA ESSÊNCIA',
                  title: 'Um espaço só seu e de quem importa.',
                ),
                const SizedBox(height: 10),
                const Text(
                  'O SnapLock é uma rede social privada para compartilhar momentos especiais com pessoas de confiança. Aqui, suas memórias não precisam ser expostas para todo mundo: você escolhe quem faz parte delas.',
                  style: TextStyle(
                    color: _mutedText,
                    fontSize: 15,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 26),
                const _SectionHeading(
                  eyebrow: 'O QUE NOS MOVE',
                  title: 'Nossa missão',
                ),
                const SizedBox(height: 12),
                const _InfoCard(
                  icon: Icons.favorite_border_rounded,
                  child: Text(
                    'Criar uma experiência de compartilhamento mais íntima e consciente, colocando privacidade, segurança e conexões reais em primeiro lugar.',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                const _SectionHeading(
                  eyebrow: 'FEITO PARA VOCÊ',
                  title: 'O que torna o SnapLock diferente?',
                ),
                const SizedBox(height: 12),
                const _FeatureCard(
                  icon: Icons.lock_outline_rounded,
                  title: 'Privacidade em primeiro lugar',
                  description:
                      'Suas publicações são compartilhadas apenas com pessoas que você aprovou.',
                ),
                const _FeatureCard(
                  icon: Icons.people_outline_rounded,
                  title: 'Conexões de confiança',
                  description:
                      'Você decide quem pode fazer parte do seu círculo de amigos.',
                ),
                const _FeatureCard(
                  icon: Icons.favorite_outline_rounded,
                  title: 'Interações positivas',
                  description:
                      'Reações simples valorizam os momentos sem transformar a experiência em uma competição.',
                ),
                const _FeatureCard(
                  icon: Icons.shield_outlined,
                  title: 'Ambiente mais seguro',
                  description:
                      'Recursos de denúncia e moderação ajudam a manter a comunidade mais respeitosa.',
                ),
                const _FeatureCard(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Suas memórias organizadas',
                  description:
                      'O Dump reúne momentos para você reviver suas lembranças de forma especial.',
                ),
                const SizedBox(height: 26),
                _buildVision(),
                const SizedBox(height: 28),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_darkBrown, _mediumBrown],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _darkBrown.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 190,
            height: 88,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Image.asset(
              'assets/images/logo_white.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Memórias que ficam\nentre quem importa.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              height: 1.15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Um jeito mais próximo e protegido de compartilhar.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVision() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD7CBBD)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.visibility_outlined, color: _mediumBrown, size: 25),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nossa visão',
                  style: TextStyle(
                    color: _darkBrown,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Construir uma rede social onde compartilhar não significa se expor, e onde cada memória possa ser vivida e guardada com mais segurança.',
                  style: TextStyle(
                    color: _mutedText,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Column(
      children: [
        Text(
          'SnapLock',
          style: TextStyle(
            color: _darkBrown,
            fontSize: 25,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 3),
        Text(
          'FOR YOU ONLY',
          style: TextStyle(
            color: _mediumBrown,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.4,
          ),
        ),
        SizedBox(height: 18),
        Text(
          'Versão 1.4.0  ·  Feito com carinho pela equipe CyberSisters',
          textAlign: TextAlign.center,
          style: TextStyle(color: _mutedText, fontSize: 12, height: 1.5),
        ),
        SizedBox(height: 8),
        SelectableText(
          'snaplock.support@gmail.com',
          style: TextStyle(
            color: _mediumBrown,
            fontSize: 13,
            decoration: TextDecoration.underline,
          ),
        ),
        SizedBox(height: 12),
        Text(
          '© 2026 SnapLock. Todos os direitos reservados.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _mutedText, fontSize: 11),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: SobreNosPage._mediumBrown,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: SobreNosPage._darkBrown,
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.child});

  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEADCCE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: SobreNosPage._mediumBrown, size: 24),
          const SizedBox(width: 14),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _InfoCard(
        icon: icon,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: SobreNosPage._darkBrown,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                color: SobreNosPage._mutedText,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
