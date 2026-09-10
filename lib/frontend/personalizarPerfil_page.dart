import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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
  bool selecionandoImagem = false;

  Future<void> escolherDaGaleria() async {
    if (selecionandoImagem) {
      return;
    }

    setState(() => selecionandoImagem = true);
    try {
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
    } on PlatformException catch (error) {
      if (mounted && error.code != 'already_active') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível selecionar a imagem.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => selecionandoImagem = false);
      }
    }
  }

  void abrirFeed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FeedPage()),
    );
  }

  void personalizarPerfil() {
    final biografia = biografiaController.text.trim();
    if (fotoPerfil == null && biografia.isEmpty) {
      abrirFeed();
      return;
    }

    // A foto e a biografia ficam prontas para serem persistidas quando o usuário estiver autenticado.
    abrirFeed();
  }

  @override
  void dispose() {
    biografiaController.dispose();
    super.dispose();
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
            Text('Personalizar Perfil'),
            const SizedBox(
              height: 30,
            ),
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
            const SizedBox(
              height: 25,
            ),
            ElevatedButton.icon(
              onPressed: selecionandoImagem ? null : escolherDaGaleria,
              icon: selecionandoImagem
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.camera_alt),
              label: Text(selecionandoImagem ? 'Abrindo galeria...' : 'Adicionar Foto'),
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
                onTap: abrirFeed,
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
              onPressed: personalizarPerfil,
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
