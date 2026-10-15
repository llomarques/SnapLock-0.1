import 'package:flutter/material.dart';

class AjudaESuportePage extends StatelessWidget {
  const AjudaESuportePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuda e Suporte'),
      ),
      body: const Center(
        child: Text('Página de Ajuda e Suporte'),
      ),
    );
  }
}