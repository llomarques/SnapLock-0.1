import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../controller/controller.login.dart';

class ProfileEditResult {
  const ProfileEditResult({
    required this.name,
    required this.bio,
    this.photo,
  });

  final String name;
  final String bio;
  final Uint8List? photo;
}

class EditarPerfilPage extends StatefulWidget {
  const EditarPerfilPage({super.key});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController biografiaController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  Uint8List? fotoPerfil;
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    final usuario = LoginController.usuarioAtual ?? {};
    nomeController.text = (usuario['name'] ?? usuario['nome'] ?? '').toString();
    biografiaController.text = (usuario['bio'] ?? usuario['biografia'] ?? '').toString();
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
            const Text('Editar foto ou dados do perfil'),
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
                  image: fotoPerfil != null
                      ? MemoryImage(fotoPerfil!)
                      : const AssetImage('assets/images/monalisaPerfil.png')
                          as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: escolherDaGaleria,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Adicionar Foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF895737),
                foregroundColor: const Color(0xFFF3E9DC),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFD7CBBD),
                hintText: 'Nome',
                prefixIcon: const Icon(
                  Icons.person,
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
            const SizedBox(height: 20),
            TextField(
              controller: biografiaController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFD7CBBD),
                hintText: 'Biografia',
                prefixIcon: const Icon(
                  Icons.chat_bubble,
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
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: salvando
                  ? null
                  : () async {
                final nome = nomeController.text.trim();
                final biografia = biografiaController.text.trim();
                if (nome.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Informe um nome.')),
                  );
                  return;
                }

                setState(() => salvando = true);
                try {
                  await LoginController.atualizarPerfil(
                    nome: nome,
                    biografia: biografia,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(
                    context,
                    ProfileEditResult(
                      name: nome,
                      bio: biografia,
                      photo: fotoPerfil,
                    ),
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  setState(() => salvando = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error.toString().replaceFirst('LoginException: ', ''))),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF895737),
                foregroundColor: const Color(0xFFF3E9DC),
                minimumSize: const Size.fromHeight(50),
              ),
              child: salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar alterações'),
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
