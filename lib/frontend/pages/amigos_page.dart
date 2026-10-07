import 'package:flutter/material.dart';
import 'package:snaplock/frontend/pages/configuracoes_page.dart';
import 'package:snaplock/frontend/pages/postAmigos_page.dart';
import 'package:snaplock/frontend/widgets/avatar_square_widget.dart';
import 'package:snaplock/frontend/widgets/botoes_widget.dart';
import 'package:snaplock/models/user_model.dart';
import 'package:snaplock/services/api_service.dart';

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
      builder: (context) => AlertDialog(
        title: const Text('Cortar laços?'),
        content: Text('Deseja remover @${amigo.username} dos seus amigos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: const Text('Cortar laços'),
          ),
        ],
      ),
    );

    if (confirmado != true || !mounted) return;

    setState(() => removendoAmigos.add(amigo.id));
    try {
      await ApiService.removeFriend(amigo.id);
      if (!mounted) return;

      setState(() => amigos.removeWhere((item) => item.id == amigo.id));
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
              builder: (context) => PostAmigosPage(amigo: amigo),
            ),
          ),
<<<<<<< HEAD
          leading: const CircleAvatar(
            radius: 15,
=======
          leading: AvatarSquareWidget(
            imageUrl: amigo.avatarUrl,
            size: 33,
>>>>>>> 945f551bb4e1252cb0a1e50ab88adbe444080f03
            backgroundColor: Colors.black,
            child: Icon(
              Icons.person,
              color: Colors.white,
            ),
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
