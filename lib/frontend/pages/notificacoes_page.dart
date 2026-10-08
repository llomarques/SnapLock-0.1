import 'package:flutter/material.dart';
import 'package:snaplock/frontend/widgets/avatar_square_widget.dart';
import 'package:snaplock/services/api_service.dart';
import 'package:snaplock/frontend/widgets/botoes_widget.dart';

class NotificacoesPage extends StatefulWidget {
  const NotificacoesPage({super.key});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPage();
}

class _NotificacoesPage extends State<NotificacoesPage> {
  List<Map<String, dynamic>> solicitacoes = [];
  List<Map<String, dynamic>> avisosAceite = [];
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarSolicitacoes();
  }

  Future<void> carregarSolicitacoes() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final resultados = await Future.wait<List<Map<String, dynamic>>>([
        ApiService.getPendingRequests(),
        ApiService.getAcceptedFriendNotifications(),
      ]);
      if (!mounted) return;
      setState(() {
        solicitacoes = resultados[0];
        avisosAceite = resultados[1];
        carregando = false;
      });

      final naoLidos = avisosAceite.where((item) => item['read'] != true);
      if (naoLidos.isNotEmpty) {
        try {
          await ApiService.markAcceptedFriendNotificationsRead(naoLidos);
          if (!mounted) return;
          setState(() {
            avisosAceite =
                avisosAceite.map((item) => {...item, 'read': true}).toList();
          });
        } catch (_) {}
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        erro = error.toString().replaceFirst('Exception: ', '');
        carregando = false;
      });
    }
  }

  Future<void> responderSolicitacao(
    Map<String, dynamic> solicitacao, {
    required bool aceitar,
  }) async {
    final requestId = solicitacao['requestId']?.toString() ?? '';
    try {
      if (aceitar) {
        await ApiService.acceptFriendRequest(requestId);
        await carregarSolicitacoes();
        return;
      } else {
        await ApiService.declineFriendRequest(requestId);
      }
      if (!mounted) return;
      setState(() {
        solicitacoes.removeWhere(
          (item) => item['requestId']?.toString() == requestId,
        );
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Widget _construirAvisoAceite(Map<String, dynamic> aviso) {
    final lido = aviso['read'] == true;
    final username = aviso['username']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: lido ? const Color(0xFFD7CBBD) : const Color(0xFFE9D1B4),
      child: ListTile(
        leading: AvatarSquareWidget(
          imageUrl: aviso['avatarUrl']?.toString() ?? '',
          size: 36,
        ),
        title: Text(
          aviso['message']?.toString() ?? '',
          style: TextStyle(
            color: const Color(0xFF3E3A36),
            fontSize: 14,
            fontWeight: lido ? FontWeight.normal : FontWeight.w600,
          ),
        ),
        subtitle: username.isEmpty ? null : Text('@$username'),
        trailing: lido
            ? const Icon(Icons.check, color: Colors.black38, size: 18)
            : const Icon(Icons.fiber_manual_record,
                color: Color(0xFFC08552), size: 12),
      ),
    );
  }

  DateTime? parseDataBackend(dynamic valor) {
    final texto = valor?.toString().trim() ?? '';
    if (texto.isEmpty) return null;

    final isoString = texto.replaceFirst(' ', 'T');
    return DateTime.tryParse(isoString)?.toLocal();
  }

  /// Converte a data do item em um rótulo de agrupamento por dia/período
  String obterCategoriaData(dynamic valor) {
    final data = parseDataBackend(valor);
    if (data == null) return 'Mais antigas';

    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final dataSemHora = DateTime(data.year, data.month, data.day);

    final diferencaDias = hoje.difference(dataSemHora).inDays;

    if (diferencaDias <= 0) {
      return 'Hoje';
    } else if (diferencaDias == 1) {
      return 'Ontem';
    } else if (diferencaDias < 7) {
      return 'Essa semana';
    } else {
      return 'Mais antigas';
    }
  }

  /// Agrupa as notificações em um Map separado por Categoria ("Hoje", "Ontem", etc.)
  Map<String, List<Map<String, dynamic>>> agruparNotificacoes() {
    final Map<String, List<Map<String, dynamic>>> grupos = {};

    for (var item in solicitacoes) {
      final dataSolicitacao =
          item['dataSolicitacao'] ?? item['data_solicitacao'];
      final categoria = obterCategoriaData(dataSolicitacao);
      if (!grupos.containsKey(categoria)) {
        grupos[categoria] = [];
      }
      grupos[categoria]!.add(item);
    }

    return grupos;
  }

  @override
  Widget build(BuildContext context) {
    final quantidadeNotificacoes = solicitacoes.length +
        avisosAceite.where((item) => item['read'] != true).length;
    final notificacoesAgrupadas = agruparNotificacoes();
    final temConteudo = solicitacoes.isNotEmpty || avisosAceite.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!carregando && erro == null && temConteudo)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Notificações',
                  style: TextStyle(
                    color: Color(0xFF3E3A36),
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 8),
                if (quantidadeNotificacoes > 0)
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC08552),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      quantidadeNotificacoes > 99
                          ? '99+'
                          : '$quantidadeNotificacoes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: carregando
              ? const Center(child: CircularProgressIndicator())
              : erro != null
                  ? Center(child: Text(erro!))
                  : !temConteudo
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Cri Cri Cri...'),
                              SizedBox(height: 12),
                              _GriloPulando(),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: notificacoesAgrupadas.keys.length +
                              (avisosAceite.isEmpty ? 0 : 1),
                          itemBuilder: (context, indexGrupo) {
                            if (avisosAceite.isNotEmpty && indexGrupo == 0) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      'Atualizações de amizade',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  ...avisosAceite.map(_construirAvisoAceite),
                                ],
                              );
                            }

                            final indiceGrupoSolicitacao =
                                indexGrupo - (avisosAceite.isEmpty ? 0 : 1);
                            final categoria = notificacoesAgrupadas.keys
                                .elementAt(indiceGrupoSolicitacao);
                            final itensDoGrupo =
                                notificacoesAgrupadas[categoria]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: indexGrupo == 0 ? 0 : 16,
                                    bottom: 8,
                                  ),
                                  child: Text(
                                    categoria,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                ...itensDoGrupo.map((solicitacao) {
                                  final username =
                                      solicitacao['username']?.toString() ?? '';
                                  final avatarUrl =
                                      solicitacao['avatarUrl']?.toString() ??
                                          '';

                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      children: [
                                        AvatarSquareWidget(
                                          imageUrl: avatarUrl,
                                          size: 33,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFD7CBBD),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '@$username quer ser seu amigo(a).',
                                                    style: const TextStyle(
                                                      color: Color(0xFF3E3A36),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Wrap(
                                                    spacing: 4,
                                                    children: [
                                                      BotoesWidget(
                                                        texto: 'Aceitar',
                                                        compacto: true,
                                                        aoTocar: () =>
                                                            responderSolicitacao(
                                                          solicitacao,
                                                          aceitar: true,
                                                        ),
                                                      ),
                                                      BotoesWidget(
                                                        texto: 'Recusar',
                                                        compacto: true,
                                                        aoTocar: () =>
                                                            responderSolicitacao(
                                                          solicitacao,
                                                          aceitar: false,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Excluir solicitação',
                                          onPressed: () => responderSolicitacao(
                                            solicitacao,
                                            aceitar: false,
                                          ),
                                          icon: const Icon(
                                            Icons.close,
                                            size: 16,
                                          ),
                                          color: Colors.black54,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 36,
                                            minHeight: 36,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

class _GriloPulando extends StatefulWidget {
  const _GriloPulando();

  @override
  State<_GriloPulando> createState() => _GriloPulandoState();
}

class _GriloPulandoState extends State<_GriloPulando>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animacao;
  late final Animation<double> _salto;

  @override
  void initState() {
    super.initState();
    _animacao = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _salto = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: -16.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 24,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -16.0, end: 0.0).chain(
          CurveTween(curve: Curves.bounceOut),
        ),
        weight: 26,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0.0),
        weight: 50,
      ),
    ]).animate(_animacao);
  }

  @override
  void dispose() {
    _animacao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 92,
      child: AnimatedBuilder(
        animation: _salto,
        child: const CustomPaint(painter: _GriloPainter()),
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _salto.value),
          child: Transform.scale(
            scale: 0.72,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _GriloPainter extends CustomPainter {
  const _GriloPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cinza = Paint()..color = const Color(0xFF777B7E);
    final cinzaClaro = Paint()..color = const Color(0xFFAEB2B4);
    final contorno = Paint()
      ..color = const Color(0xFF626669)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(43, 47),
        width: 42,
        height: 18,
      ),
      cinza,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(46, 43),
        width: 31,
        height: 10,
      ),
      cinzaClaro,
    );
    canvas.drawLine(const Offset(34, 40), const Offset(55, 46), contorno);
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(65, 43),
        width: 13,
        height: 14,
      ),
      cinza,
    );
    canvas.drawCircle(const Offset(76, 36), 8, cinza);
    canvas.drawCircle(
      const Offset(79, 34),
      1.5,
      Paint()..color = const Color(0xFF333638),
    );

    final antena = Path()
      ..moveTo(72, 30)
      ..quadraticBezierTo(65, 15, 57, 11)
      ..moveTo(77, 29)
      ..quadraticBezierTo(84, 13, 92, 12);
    canvas.drawPath(antena, contorno);

    _desenharPerna(canvas, contorno, const [
      Offset(38, 50),
      Offset(22, 27),
      Offset(29, 66),
      Offset(20, 71),
    ]);
    _desenharPerna(canvas, contorno, const [
      Offset(45, 51),
      Offset(37, 27),
      Offset(43, 65),
      Offset(38, 71),
    ]);
    _desenharPerna(canvas, contorno, const [
      Offset(61, 49),
      Offset(56, 63),
      Offset(51, 69),
    ]);
    _desenharPerna(canvas, contorno, const [
      Offset(66, 48),
      Offset(72, 62),
      Offset(80, 66),
    ]);

    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(50, 77),
        width: 32,
        height: 5,
      ),
      Paint()..color = const Color(0x33777B7E),
    );
  }

  @override
  bool shouldRepaint(covariant _GriloPainter oldDelegate) => false;

  void _desenharPerna(Canvas canvas, Paint tinta, List<Offset> pontos) {
    final caminho = Path()..moveTo(pontos.first.dx, pontos.first.dy);
    for (final ponto in pontos.skip(1)) {
      caminho.lineTo(ponto.dx, ponto.dy);
    }
    canvas.drawPath(caminho, tinta);
  }
}
