import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../controller/controller.login.dart';
import 'package:snaplock/frontend/widgets/input_widget.dart';
import 'package:snaplock/frontend/utils/foto_utils.dart';

class EditarPerfilPage extends StatefulWidget {
  final String nomeInicial;
  final String biografiaInicial;
  final Uint8List? fotoPerfilInicial;
  final String fotoPerfilUrlInicial;

  const EditarPerfilPage({
    super.key,
    this.nomeInicial = '',
    this.biografiaInicial = '',
    this.fotoPerfilInicial,
    this.fotoPerfilUrlInicial = '',
  });

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController biografiaController = TextEditingController();
  Uint8List? fotoPerfil;
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    nomeController.text = widget.nomeInicial;
    biografiaController.text = widget.biografiaInicial;
    fotoPerfil = widget.fotoPerfilInicial;
  }

  Future<void> salvarAlteracoes() async {
  if (salvando) return;

  setState(() => salvando = true);
  try {
    String? novaFotoUrl;

    // Se o usuário escolheu uma nova foto, envia primeiro
    if (fotoPerfil != null) {
      novaFotoUrl = await LoginController.atualizarFotoPerfil(fotoPerfil!);
    }

    final resposta = await LoginController.atualizarPerfil(
      nome: nomeController.text.trim(),
      biografia: biografiaController.text.trim(),
    );

    if (mounted) {
      final usuarioAtualizado = Map<String, dynamic>.from(
        resposta['user'] as Map<String, dynamic>,
      );

      // O endpoint de nome/bio não sabe da nova foto, então mesclamos aqui
      if (novaFotoUrl != null) {
        usuarioAtualizado['avatarUrl'] = novaFotoUrl;
      }

      Navigator.pop(context, usuarioAtualizado);
    }
  } catch (error) {
    if (mounted) {
      setState(() => salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
}

  Future<void> escolherDaGaleria() async {
    final bytes = await FotoUtils.selecionarDaGaleria();

    if (bytes == null || !mounted) {
      return;
    }

    setState(() {
      fotoPerfil = bytes;
    });
  }

  ImageProvider<Object> get imagemPerfil {
    if (fotoPerfil != null) {
      return MemoryImage(fotoPerfil!);
    }
    if (widget.fotoPerfilUrlInicial.isNotEmpty) {
      return NetworkImage(widget.fotoPerfilUrlInicial);
    }
    return const AssetImage('assets/images/monalisaPerfil.png');
  }

  @override
  void dispose() {
    
    nomeController.dispose();
    biografiaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E9DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3E9DC),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF5E3023),
          tooltip: 'Voltar',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Editar perfil'),
            const SizedBox(height: 30),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF895737),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image(
                  image: imagemPerfil,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/monalisaPerfil.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: escolherDaGaleria,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Adicionar foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF895737),
                foregroundColor: const Color(0xFFF3E9DC),
              ),
            ),
            const SizedBox(height: 20),
            InputWidget(
              controller: nomeController,
              texto: 'Digite seu nome',
              icon: Icons.person,
              maximoCaracteresSemContador: 20,
            ),
            const SizedBox(height: 20),
            InputWidget(
              controller: usuarioController,
              texto: 'Digite seu usuário',
              icon: Icons.alternate_email,
              maximoCaracteresSemContador: 20,
            ),
            const SizedBox(height: 20,),
            InputWidget(
              controller: biografiaController,
              texto: 'Digite sua biografia',
              icon: Icons.chat_bubble,
              maximoCaracteres: 150,
			  linhasMinimas: 3,
			  linhasMaximas: 6,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: salvando ? null : salvarAlteracoes,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF895737),
                foregroundColor: const Color(0xFFF3E9DC),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Salvar alterações'),
            ),
            const SizedBox(height: 27),
            Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/images/logo.png',
                width: 50,
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}