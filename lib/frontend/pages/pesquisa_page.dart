import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snaplock/frontend/pages/configuracoes_page.dart';
import 'package:snaplock/frontend/widgets/avatar_square_widget.dart';
import 'package:snaplock/frontend/widgets/botoes_widget.dart';
import 'package:snaplock/models/user_model.dart';
import 'package:snaplock/services/api_service.dart';

class PesquisaPage extends StatefulWidget {
  const PesquisaPage({super.key});

  @override
  State<PesquisaPage> createState() => _PesquisaPage();
}

class _PesquisaPage extends State<PesquisaPage> {
  final TextEditingController pesquisaController = TextEditingController();
  Timer? debounce;
  List<UserModel> usuarios = [];
  bool buscando = false;
  bool iniciouBusca = false;
  String? erro;
  final Map<String, String> statusAmizade = {};
  final Set<String> enviandoSolicitacoes = {};

  void aoAlterarBusca(String valor) {
    debounce?.cancel();
    final query = valor.trim();

    if (query.isEmpty) {
      setState(() {
        usuarios = [];
        buscando = false;
        iniciouBusca = false;
        erro = null;
      });
      return;
    }

    setState(() {
      buscando = true;
      iniciouBusca = true;
      erro = null;
    });
    debounce = Timer(
      const Duration(milliseconds: 300),
      () => buscarUsuarios(query),
    );
  }

  Future<void> buscarUsuarios(String query) async {
    try {
      final encontrados = await ApiService.searchUsers(query);
      if (!mounted || pesquisaController.text.trim() != query) return;

      setState(() {
        usuarios = encontrados;
        buscando = false;
        erro = null;
      });
    } catch (error) {
      if (!mounted || pesquisaController.text.trim() != query) return;

      setState(() {
        buscando = false;
        erro = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> enviarSolicitacao(UserModel usuario) async {
    if (enviandoSolicitacoes.contains(usuario.id)) return;

    setState(() => enviandoSolicitacoes.add(usuario.id));
    try {
      await ApiService.sendFriendRequest(usuario.id);
      if (mounted) {
        setState(() => statusAmizade[usuario.id] = 'pendente');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => enviandoSolicitacoes.remove(usuario.id));
    }
  }

  Widget resultadosBusca() {
    if (!iniciouBusca) {
      return const Center(
          child: Text('Busque usuários pelo nome ou username.'));
    }
    if (buscando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (erro != null) {
      return Center(child: Text(erro!));
    }
    if (usuarios.isEmpty) {
      return const Center(child: Text('Nenhum usuário encontrado.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: usuarios.length,
      itemBuilder: (context, index) {
        final usuario = usuarios[index];
        final status = statusAmizade[usuario.id] ?? usuario.friendshipStatus;
        final enviando = enviandoSolicitacoes.contains(usuario.id);
        return ListTile(
          dense: true,
          visualDensity: const VisualDensity(vertical: -2),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: AvatarSquareWidget(
            imageUrl: usuario.avatarUrl,
            size: 33,
            backgroundColor: Colors.black,
            iconColor: Colors.white,
          ),
          title: Text(
            usuario.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('@${usuario.username}'),
          trailing: BotoesWidget(
            texto: enviando
                ? 'Enviando...'
                : status == 'aceito'
                    ? 'Amigos'
                    : status == 'pendente'
                        ? 'Pendente'
                        : 'Fazer amizade',
            compacto: true,
            aoTocar: status.isNotEmpty || enviando
                ? () {}
                : () => enviarSolicitacao(usuario),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    debounce?.cancel();
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
              onChanged: aoAlterarBusca,
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
          Expanded(child: resultadosBusca()),
          if (iniciouBusca && !buscando && erro == null)
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
