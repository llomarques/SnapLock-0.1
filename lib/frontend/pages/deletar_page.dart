import 'package:flutter/material.dart';

class DeletarPage extends StatelessWidget {
  const DeletarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deletar Conta'),
      ),
      body: const Center(
        child: Text('Página de Deletar Conta'),
      ),
    );
  }
}