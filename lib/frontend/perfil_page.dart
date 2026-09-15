import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:snaplock/services/api_service.dart';
import 'editarPerfil_page.dart';
import '../controller/controller.login.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPage();
}

class _PerfilPage extends State<PerfilPage> {
  final TextEditingController biografiaController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  Uint8List? fotoPerfil;
  int quantidadeAmigos = 0;
  int quantidadeFotos = 0;
  String nomeUsuario = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    final usuario = LoginController.usuarioAtual;
    nomeUsuario = usuario?['name']?.toString() ?? '';
    username = usuario?['username']?.toString() ?? '';
    biografiaController.text = usuario?['bio']?.toString() ?? '';
    carregarQuantidadeAmigos();
    carregarQuantidadeFotos();
  }

  Future<void> carregarQuantidadeAmigos() async {
    try {
      final amigos = await ApiService.getFriends();

      if (!mounted) {
        return;
      }

      setState(() {
        quantidadeAmigos = amigos.length;
      });
    } catch (_) {
      // Mantém o perfil disponível mesmo quando a API estiver indisponível.
    }
  }

  Future<void> carregarQuantidadeFotos() async {
    try {
      final fotos = await ApiService.getFotos();

      if (!mounted) {
        return;
      }

      setState(() {
        quantidadeFotos = fotos.length!;
      });
    } catch (_) {
      // Mantém o perfil disponível mesmo quando a API estiver indisponível.
    }
  }

  Future<void> abrirEditarPerfil(BuildContext context) async {
    final usuario = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarPerfilPage(
          nomeInicial: nomeUsuario,
          biografiaInicial: biografiaController.text,
        ),
      ),
    );

    if (usuario != null && mounted) {
      setState(() {
        nomeUsuario = usuario['name']?.toString() ?? nomeUsuario;
        username = usuario['username']?.toString() ?? username;
        biografiaController.text = usuario['bio']?.toString() ?? '';
      });
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
      backgroundColor: const Color(0xFFF3E9DC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
        
        children: [
          const SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    '$quantidadeAmigos\nAmigos',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF5E3023),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 90,
                    height: 90,
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
                            : const AssetImage(
                                'assets/images/monalisaPerfil.png',
                              ) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: IconButton(
                      onPressed: () => abrirEditarPerfil(context),
                      icon: const Icon(Icons.edit, size: 17),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: const Color(0xFFF3E9DC),
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$quantidadeFotos\nMemórias',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF5E3023),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            nomeUsuario,
            style: TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            username.isEmpty ? '@username' : '@$username',
            style: TextStyle(color: Colors.black, fontSize: 10),
          ),
          const SizedBox(
            height: 20,
          ),
          Column(
            children: [
              
              TextField(
                controller: biografiaController,
                readOnly: true,
                showCursor: false,
                enableInteractiveSelection: false,
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
            ],
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    ),
  );
  }
}

extension on Object? {
  int? get length => null;
}
