import 'package:flutter/material.dart';
import 'package:snaplock/frontend/pages/sobreNos_page.dart';

class LogoSobreNosWidget extends StatelessWidget {
  const LogoSobreNosWidget({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoAssetPath = isDark && assetPath == 'assets/images/logo.png'
        ? 'assets/images/logo_oficial_white.png'
        : assetPath;

    return Semantics(
      button: true,
      label: 'Sobre Nós',
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const SobreNosPage(),
            ),
          );
        },
        child: Image.asset(
          logoAssetPath,
          width: width,
          height: height,
          fit: fit,
        ),
      ),
    );
  }
}
