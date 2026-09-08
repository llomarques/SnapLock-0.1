import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:snaplock/frontend/feed_page.dart';

class personalizarPerfilPage extends StatefulWidget {
  const personalizarPerfilPage({super.key});

  @override
  State<personalizarPerfilPage> createState() => _personalizarPerfilPage();
}

class _personalizarPerfilPage extends State<personalizarPerfilPage> {
  final TextEditingController biografiaController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  Uint8List? fotoPerfil;

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

  void abrirFeed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FeedPage()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3E9DC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 60,
            ),
            Text('Personalizar perfil'),
            const SizedBox(
              height: 30,
            ),
            CircleAvatar(
              radius: 60,
              backgroundColor:
                  Colors.transparent, // Ajuste a cor de fundo se necessário
              backgroundImage: fotoPerfil != null
                  ? MemoryImage(fotoPerfil!)
                  : const AssetImage('assets/images/monalisaPerfil.png')
                      as ImageProvider,
            ),
            const SizedBox(
              height: 25,
            ),
            ElevatedButton.icon(
              onPressed: escolherDaGaleria,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Adicionar Foto"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF895737),
                foregroundColor: Color(0xFFF3E9DC),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: biografiaController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFD7CBBD),
                hintText: 'Digite sua biografia',
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
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  abrirFeed();
                },
                child: const Text(
                  'Deixar para mais tarde',
                  style: TextStyle(
                      color: Color(0xFF895737), fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () {
                abrirFeed();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF895737),
                foregroundColor: Color(0xFFF3E9DC),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Personalizar'),
            ),
            const SizedBox(height: 55),
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
