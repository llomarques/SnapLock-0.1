import 'package:flutter/material.dart';

void mostrarMensagem(BuildContext context, String mensagem){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        duration: const Duration(seconds: 1),
      )
    );
}