import 'package:flutter/material.dart';

class BotoesWidget extends StatelessWidget {
  final String texto;
  final VoidCallback aoTocar;
  final bool compacto;

  const BotoesWidget({
    super.key,
    required this.texto,
    required this.aoTocar,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compacto) {
      return ElevatedButton(
        onPressed: aoTocar,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC08552),
          foregroundColor: const Color(0xFFF3E9DC),
          minimumSize: const Size(104, 28),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          texto,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      );
    }

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