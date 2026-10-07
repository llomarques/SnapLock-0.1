import 'package:flutter/material.dart';
import 'package:snaplock/models/post_model.dart';
import 'package:snaplock/models/user_model.dart';
import 'package:snaplock/services/api_service.dart';
import 'package:snaplock/widgets/post_card.dart';

class PostAmigosPage extends StatefulWidget {
  const PostAmigosPage({super.key, required this.amigo});

  final UserModel amigo;

  @override
  State<PostAmigosPage> createState() => _PostAmigosPageState();
}

class _PostAmigosPageState extends State<PostAmigosPage> {
  List<PostModel> _publicacoes = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarPublicacoes();
  }

  Future<void> _carregarPublicacoes() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final publicacoes = await ApiService.getFriendGallery(widget.amigo.id);
      if (!mounted) return;

      setState(() {
        _publicacoes = publicacoes;
        _carregando = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _erro = error.toString().replaceFirst('Exception: ', '');
        _carregando = false;
      });
    }
  }

  Widget _conteudo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_erro!),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _carregarPublicacoes,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_publicacoes.isEmpty) {
      return Center(
        child: Text('Nenhuma publicação de ${widget.amigo.name} ainda.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _publicacoes.length,
      itemBuilder: (context, index) => PostCard(
        post: _publicacoes[index],
        onPostUpdated: _carregarPublicacoes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E9DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD7CBBD),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          widget.amigo.name,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: _conteudo(),
    );
  }
}
