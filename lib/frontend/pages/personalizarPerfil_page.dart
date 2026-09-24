import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snaplock/frontend/pages/feed_page.dart';
import '../../controller/controller.login.dart';
import 'package:snaplock/frontend/widgets/input_widget.dart';

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
  bool salvando = false;

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

  Future<void> personalizarPerfil() async {
    final biografia = biografiaController.text.trim();
    if (fotoPerfil == null && biografia.isEmpty) {
      abrirFeed();
      return;
    }

    if (salvando) return;
    setState(() => salvando = true);

    try {
      String? novaFotoUrl;
      if (fotoPerfil != null) {
        novaFotoUrl = await LoginController.atualizarFotoPerfil(fotoPerfil!);
      }

      final nome = LoginController.usuarioAtual?['name']?.toString() ?? '';
      final resposta = await LoginController.atualizarPerfil(
        nome: nome,
        biografia: biografia,
      );

      if (novaFotoUrl != null && resposta['user'] is Map<String, dynamic>) {
        (resposta['user'] as Map<String, dynamic>)['avatarUrl'] = novaFotoUrl;
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const FeedPage(initialIndex: 4),
          ),
        );
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
            const Text('Personalizar perfil'),
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
                label: Text(selecionandoImagem
                  ? 'Abrindo galeria...'
                  : 'Adicionar foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF895737),
                foregroundColor: Color(0xFFF3E9DC),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            InputWidget(
              controller: biografiaController,
              texto: 'Digite sua biografia',
              icon: Icons.chat_bubble,
              maximoCaracteres: 150,
			  linhasMinimas: 3,
			  linhasMaximas: 6,
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: abrirFeed,
                child: Text(
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
              onPressed: salvando ? null : personalizarPerfil,
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