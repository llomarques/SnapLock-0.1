import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snaplock/frontend/pages/configuracoes_page.dart';
import 'package:snaplock/frontend/pages/perfilAmigo_page.dart';
import 'package:snaplock/frontend/widgets/avatar_square_widget.dart';
import 'package:snaplock/frontend/widgets/botoes_widget.dart';
import 'package:snaplock/models/user_model.dart';
import 'package:snaplock/services/api_service.dart';
import 'package:snaplock/theme/app_theme.dart';

class AmigosPage extends StatefulWidget {
  const AmigosPage({super.key});

  @override
  State<AmigosPage> createState() => _AmigosPage();
}

class _AmigosPage extends State<AmigosPage> {
  final TextEditingController pesquisaController = TextEditingController();
  List<UserModel> amigos = [];
  final Set<String> removendoAmigos = {};
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarAmigos();
  }

  Future<void> carregarAmigos() async {
    try {
      final encontrados = await ApiService.getFriends();
      if (!mounted) return;

      setState(() {
        amigos = encontrados;
        carregando = false;
        erro = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        carregando = false;
        erro = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<UserModel> get amigosFiltrados {
    final consulta = pesquisaController.text.trim().toLowerCase();
    if (consulta.isEmpty) return amigos;

    return amigos.where((amigo) {
      return amigo.name.toLowerCase().contains(consulta) ||
          amigo.username.toLowerCase().contains(consulta) ||
          amigo.email.toLowerCase().contains(consulta);
    }).toList();
  }

  Future<void> cortarLacos(UserModel amigo) async {
    if (removendoAmigos.contains(amigo.id)) return;

    final confirmado = await showDialog<bool>(
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
                Icons.heart_broken_outlined,
                color: AppTheme.danger,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Desfazer amizade?',
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
          'Tem certeza que deseja desfazer a amizade com @${amigo.username}?',
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
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
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
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            icon: const Icon(Icons.content_cut, size: 18),
            label: const Text('Desfazer amizade'),
          ),
        ],
      ),
    );

    if (confirmado != true || !mounted) return;

    setState(() => removendoAmigos.add(amigo.id));
    try {
      final remocao = ApiService.removeFriend(amigo.id);
      await _mostrarAnimacaoCorte(
        remocao: remocao,
        aoConcluir: () {
          if (mounted) {
            setState(() => amigos.removeWhere((item) => item.id == amigo.id));
          }
        },
      );
      await remocao;
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('@${amigo.username} removido dos seus amigos.')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => removendoAmigos.remove(amigo.id));
    }
  }

  Future<void> _mostrarAnimacaoCorte({
    required Future<void> remocao,
    required VoidCallback aoConcluir,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) =>
          _AnimacaoCorteLacos(
        remocao: remocao,
        aoConcluir: aoConcluir,
      ),
    );
  }

  Widget listaAmigos() {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(erro!),
            const SizedBox(height: 12),
            TextButton(
                onPressed: carregarAmigos,
                child: const Text('Tentar novamente')),
          ],
        ),
      );
    }
    final resultados = amigosFiltrados;
    if (resultados.isEmpty) {
      return Center(
        child: Text(
          amigos.isEmpty
              ? 'Você ainda não tem amigos adicionados.'
              : 'Nenhum amigo encontrado.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: resultados.length,
      itemBuilder: (context, index) {
        final amigo = resultados[index];
        final removendo = removendoAmigos.contains(amigo.id);
        return ListTile(
          dense: true,
          visualDensity: const VisualDensity(vertical: -2),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PerfilAmigoPage(amigo: amigo),
            ),
          ),
          leading: AvatarSquareWidget(
            imageUrl: amigo.avatarUrl,
            size: 33,
            backgroundColor: Colors.black,
          ),
          title: Text(
            amigo.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('@${amigo.username}'),
          trailing: BotoesWidget(
            texto: removendo ? 'Cortando...' : 'Cortar laços',
            compacto: true,
            aoTocar: () => cortarLacos(amigo),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E9DC),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFD7CBBD),
            child: SafeArea(
              bottom: false,
              child: AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 110,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 35.0,
                    color: Colors.black,
                  ),
                ),
                centerTitle: true,
                title: Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  width: 80,
                ),
                actions: [
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConfiguracoesPage(),
                      ),
                    ),
                    icon: const Icon(
                      Icons.settings,
                      size: 32,
                      color: Colors.black,
                    ),
                  ),
                ],
                backgroundColor: const Color(0xFFD7CBBD),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(24),
            child: TextField(
              controller: pesquisaController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFD7CBBD),
                hintText: 'Nome ou username',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF5E3023),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: listaAmigos()),
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 22),
            child: Text(
              'Isso é tudo.',
              style: TextStyle(color: Colors.black38),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimacaoCorteLacos extends StatefulWidget {
  const _AnimacaoCorteLacos({
    required this.remocao,
    required this.aoConcluir,
  });

  final Future<void> remocao;
  final VoidCallback aoConcluir;

  @override
  State<_AnimacaoCorteLacos> createState() => _AnimacaoCorteLacosState();
}

class _AnimacaoCorteLacosState extends State<_AnimacaoCorteLacos>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _executarCorte();
  }

  Future<void> _executarCorte() async {
    final animacao = _controller.forward();
    try {
      await Future.wait<void>([animacao, widget.remocao]);
      if (!mounted) return;
      widget.aoConcluir();
    } catch (_) {
      await animacao;
    } finally {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 190,
        height: 112,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = Curves.easeInOut.transform(
              (_controller.value / 0.75).clamp(0.0, 1.0),
            );
            final bowOpacity = 1 -
                Curves.easeOut.transform(
                  (_controller.value - 0.55).clamp(0.0, 0.45) / 0.45,
                );

            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Opacity(
                  opacity: bowOpacity,
                  child: const CustomPaint(
                    size: Size(100, 82),
                    painter: _LacoVermelhoPainter(),
                  ),
                ),
                Positioned(
                  left: 15 + progress * 105,
                  top: 31,
                  child: Transform.rotate(
                    angle: -0.45 + progress * 0.9,
                    child: const Icon(
                      Icons.content_cut,
                      color: AppTheme.darkBrown,
                      size: 48,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LacoVermelhoPainter extends CustomPainter {
  const _LacoVermelhoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC62828)
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = const Color(0xFF8E1717)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final center = Offset(size.width / 2, size.height * 0.42);

    final leftLoop = Path()
      ..moveTo(center.dx, center.dy)
      ..cubicTo(center.dx - 7, center.dy - 24, center.dx - 43, center.dy - 24,
          center.dx - 42, center.dy - 3)
      ..cubicTo(center.dx - 42, center.dy + 13, center.dx - 16, center.dy + 15,
          center.dx, center.dy);
    final rightLoop = Path()
      ..moveTo(center.dx, center.dy)
      ..cubicTo(center.dx + 7, center.dy - 24, center.dx + 43, center.dy - 24,
          center.dx + 42, center.dy - 3)
      ..cubicTo(center.dx + 42, center.dy + 13, center.dx + 16, center.dy + 15,
          center.dx, center.dy);

    canvas.drawPath(leftLoop, paint);
    canvas.drawPath(leftLoop, outline);
    canvas.drawPath(rightLoop, paint);
    canvas.drawPath(rightLoop, outline);

    final tails = Path()
      ..moveTo(center.dx - 5, center.dy + 5)
      ..lineTo(center.dx - 24, center.dy + 36)
      ..lineTo(center.dx - 8, center.dy + 30)
      ..lineTo(center.dx, center.dy + 7)
      ..lineTo(center.dx + 8, center.dy + 30)
      ..lineTo(center.dx + 24, center.dy + 36)
      ..lineTo(center.dx + 5, center.dy + 5)
      ..close();
    canvas.drawPath(tails, paint);
    canvas.drawPath(tails, outline);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 14, height: 17),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFE53935),
    );
  }

  @override
  bool shouldRepaint(covariant _LacoVermelhoPainter oldDelegate) => false;
}
