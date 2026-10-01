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
      final pendentes = await ApiService.getPendingRequests();
      if (!mounted) return;
      setState(() {
        solicitacoes = pendentes;
        carregando = false;
      });
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
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (erro != null) {
      return Center(child: Text(erro!));
    }
    if (solicitacoes.isEmpty) {
      return const Center(child: Text('Cri Cri Cri...'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: solicitacoes.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final solicitacao = solicitacoes[index];
        final nome = solicitacao['name']?.toString() ?? 'Usuário';
        final username = solicitacao['username']?.toString() ?? '';
        final avatarUrl = solicitacao['avatarUrl']?.toString() ?? '';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              AvatarSquareWidget(
                imageUrl: avatarUrl,
                size: 33,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('@$username enviou uma solicitação'),
                    Wrap(
                      spacing: 4,
                      children: [
                        BotoesWidget(
                          texto: 'Aceitar',
                          compacto: true,
                          aoTocar: () => responderSolicitacao(
                            solicitacao,
                            aceitar: true,
                          ),
                        ),
                        BotoesWidget(
                          texto: 'Recusar',
                          compacto: true,
                          aoTocar: () => responderSolicitacao(
                            solicitacao,
                            aceitar: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}