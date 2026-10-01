import 'package:flutter/material.dart';

class BotoesWidget extends StatelessWidget {
  final String texto;
  final VoidCallback aoTocar;

  const BotoesWidget({
    super.key,
    required this.texto,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: aoTocar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF895737),
              foregroundColor: const Color(0xFFF3E9DC),
              minimumSize: const Size.fromHeight(50),
            ),
            child: Text(
              texto,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
      ],
      ),
    );
  }
}