import 'package:flutter/material.dart';

class AmigosPage extends StatefulWidget {
  const AmigosPage({super.key});

  @override
  State<AmigosPage> createState() => _AmigosPage();
}

class _AmigosPage extends State<AmigosPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: const Text('Amigos'),
    );
  }
}