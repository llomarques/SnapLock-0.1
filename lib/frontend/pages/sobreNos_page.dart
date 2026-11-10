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
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
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
                  title: 'O que você encontra dentro do SnapLock?',
                ),
                const SizedBox(height: 12),
                const _FeatureCard(
                  icon: Icons.photo_library_outlined,
                  category: '01 / PRIVACIDADE',
                  title: 'Fotos para o seu círculo',
                  description:
                      'Compartilhe momentos que só amigos autorizados podem ver.',
                  highlighted: true,
                ),
                const _FeatureCard(
                  icon: Icons.favorite_outline_rounded,
                  category: '02 / INTERAÇÃO',
                  title: 'Curtidas',
                  description:
                      'Reaja às publicações de forma leve, sem comentários ou mensagens privadas.',
                ),
                const _FeatureCard(
                  icon: Icons.auto_awesome_outlined,
                  category: '03 / PERSONALIZAÇÃO',
                  title: 'Seu estilo, suas regras',
                  description:
                      'Personalize tema e fonte para deixar o app com a sua cara.',
                ),
                const _FeatureCard(
                  icon: Icons.tune_rounded,
                  category: '04 / FOTOS',
                  title: 'Edite antes de postar',
                  description:
                      'Adicione legendas e ajuste suas fotos com filtros e formatos.',
                ),
                const _FeatureCard(
                  icon: Icons.schedule_rounded,
                  category: '05 / RETROSPECTIVAS',
                  title: 'Reviva cada fase',
                  description:
                      'Relembre os registros especiais do mês e do ano.',
                ),
                const _FeatureCard(
                  icon: Icons.account_circle_outlined,
                  category: '06 / SEU PERFIL',
                  title: 'Um perfil que é você',
                  description:
                      'Cuide das suas informações e mantenha seu espaço atualizado.',
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Text(
              'Sobre Nós',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
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
    required this.category,
    required this.title,
    required this.description,
    this.highlighted = false,
  });

  final IconData icon;
  final String category;
  final String title;
  final String description;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:
              highlighted ? SobreNosPage._darkBrown : const Color(0xFFFFFBF7),
          borderRadius: BorderRadius.circular(20),
          border:
              highlighted ? null : Border.all(color: const Color(0xFFEADCCE)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: highlighted
                    ? const Color(0xFFC17A45)
                    : SobreNosPage._darkBrown,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      color: highlighted
                          ? const Color(0xFFEAB080)
                          : SobreNosPage._mediumBrown,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: TextStyle(
                      color:
                          highlighted ? Colors.white : SobreNosPage._darkBrown,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      color: highlighted
                          ? Colors.white.withValues(alpha: 0.82)
                          : SobreNosPage._mutedText,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
