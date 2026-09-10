import 'package:flutter/material.dart';
import 'package:snaplock/services/api_service.dart';

class NotificacoesPage extends StatefulWidget {
  const NotificacoesPage({super.key});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPage();
}

// int quantidadeNotificacoes = 0;

//   @override
//   void initState() {
//     super.initState();
//     carregarQuantidadeNotificacoes();
//   }

// Future<void> carregarQuantidadeNotificacoes() async {
//     try {
//       final notificacoes = await ApiService.getNotificacoes();

//       if (!mounted) {
//         return;
//       }

//       setState(() {
//         quantidadeNotificacoes = notificacoes.length;
//       });
//     } catch (_) {
//       // Mantém o perfil disponível mesmo quando a API estiver indisponível.
//     }
//   }

class _NotificacoesPage extends State<NotificacoesPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Notificações"),
    );
  }
}
