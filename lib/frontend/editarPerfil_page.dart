import 'package:flutter/material.dart';
import 'package:snaplock/theme/app_theme.dart';
import 'package:snaplock/frontend/widgets/logo_sobre_nos_widget.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../controller/controller.login.dart';

class EditarPerfilPage extends StatefulWidget {
  final String nomeInicial;
  final String usernameInicial;
  final String biografiaInicial;
  final Uint8List? fotoPerfilInicial;
  final String fotoPerfilUrlInicial;

  const EditarPerfilPage({
    super.key,
    this.nomeInicial = '',
    this.usernameInicial = '',
    this.biografiaInicial = '',
    this.fotoPerfilInicial,
    this.fotoPerfilUrlInicial = '',
  });

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController biografiaController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  Uint8List? fotoPerfil;
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    nomeController.text = widget.nomeInicial;
    usernameController.text = widget.usernameInicial;
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
        username: usernameController.text.trim(),
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
    final XFile? imagem = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (imagem == null) {
      return;
    }

    final bytes = await imagem.readAsBytes();

    if (!mounted) {
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
    usernameController.dispose();
    biografiaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
          color: AppTheme.darkBrown,
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
                  color: AppTheme.mediumBrown,
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
                backgroundColor: AppTheme.mediumBrown,
                foregroundColor: const Color(0xFFF3E9DC),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceLight,
                hintText: 'Nome',
                prefixIcon: Icon(
                  Icons.person,
                  color: AppTheme.darkBrown,
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
            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceLight,
                hintText: 'Username',
                prefixIcon: Icon(
                  Icons.alternate_email,
                  color: AppTheme.darkBrown,
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
            const SizedBox(height: 20),
            TextField(
              controller: biografiaController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceLight,
                hintText: 'Biografia',
                prefixIcon: Icon(
                  Icons.chat_bubble,
                  color: AppTheme.darkBrown,
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
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: salvando ? null : salvarAlteracoes,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.mediumBrown,
                foregroundColor: const Color(0xFFF3E9DC),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Salvar alterações'),
            ),
            const SizedBox(height: 27),
            Align(
              alignment: Alignment.topLeft,
              child: const LogoSobreNosWidget(
                assetPath: 'assets/images/logo.png',
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
