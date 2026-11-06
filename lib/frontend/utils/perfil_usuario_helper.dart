import 'package:flutter/material.dart';
import 'package:snaplock/controller/controller.login.dart';
import 'package:snaplock/frontend/pages/perfilAmigo_page.dart';
import 'package:snaplock/frontend/pages/perfil_page.dart';
import 'package:snaplock/models/user_model.dart';
import 'package:snaplock/services/api_service.dart';

Future<void> abrirPerfilUsuario(
  BuildContext context, {
  required String username,
  String? userId,
  String? name,
  String? avatarUrl,
}) async {
  final normalizedUsername = username.replaceFirst('@', '').trim();
  final normalizedUserId = userId?.trim() ?? '';

  final currentUser = ApiService.currentUser ??
      (LoginController.usuarioAtual == null
          ? null
          : UserModel(
              id: LoginController.usuarioAtual?['id']?.toString() ?? '',
              name: LoginController.usuarioAtual?['name']?.toString() ?? '',
              username:
                  LoginController.usuarioAtual?['username']?.toString() ?? '',
              email: LoginController.usuarioAtual?['email']?.toString() ?? '',
              birthdate: '',
            ));

  final isCurrentUser =
      (normalizedUserId.isNotEmpty && normalizedUserId == currentUser?.id) ||
          (normalizedUsername.isNotEmpty &&
              normalizedUsername == currentUser?.username);

  if (!context.mounted) return;
  if (isCurrentUser) {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PerfilPage()),
    );
    return;
  }

  UserModel? usuario;
  if (normalizedUsername.isNotEmpty) {
    try {
      final encontrados = await ApiService.searchUsers(normalizedUsername);
      for (final candidato in encontrados) {
        if (candidato.username.toLowerCase() ==
            normalizedUsername.toLowerCase()) {
          usuario = candidato;
          break;
        }
      }
      usuario ??= encontrados.isNotEmpty ? encontrados.first : null;
    } catch (_) {}
  }

  usuario ??= UserModel(
    id: normalizedUserId.isNotEmpty ? normalizedUserId : normalizedUsername,
    name: name?.trim().isNotEmpty == true ? name!.trim() : normalizedUsername,
    username: normalizedUsername,
    email: '',
    birthdate: '',
    avatarUrl: avatarUrl ?? '',
  );

  if (!context.mounted) return;
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => PerfilAmigoPage(amigo: usuario!)),
  );
}
