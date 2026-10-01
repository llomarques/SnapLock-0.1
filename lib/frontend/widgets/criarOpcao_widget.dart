import 'package:flutter/material.dart';

class CriarOpcaoWidget extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final VoidCallback aoClicar;

  const CriarOpcaoWidget({
    super.key,
    required IconData icone,
    required String titulo,
    required VoidCallback aoClicar,
  })  : icone = icone,
        titulo = titulo,
        aoClicar = aoClicar;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icone),
      title: Text(titulo),
      onTap: aoClicar,
    );
  }
}
