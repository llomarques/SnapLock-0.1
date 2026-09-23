import 'package:flutter/material.dart';
import 'package:snaplock/frontend/pages/feed_page.dart';

class PesquisaPage extends StatefulWidget {
  const PesquisaPage({super.key});

  @override
  State<PesquisaPage> createState() => _PesquisaPage();
}

class _PesquisaPage extends State<PesquisaPage> {
  final TextEditingController pesquisaController = TextEditingController();

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
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedPage()),
                  ),
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
                backgroundColor: const Color(0xFFD7CBBD),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(24),
            child: TextField(
              controller: pesquisaController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFD7CBBD),
                hintText: 'Usuário',
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
        ],
      ),
    );
  }
}