import 'package:flutter/material.dart';

class CurtidasPage extends StatelessWidget {
  const CurtidasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Curtidas'),
      ),
      body: const Center(
        child: Text('Página de Curtidas'),
      ),
    );
  }
}