import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snaplock/theme/app_theme.dart';

Future<void> mostrarImagemPerfilMaximizada(
  BuildContext context, {
  required String imageUrl,
  String fallbackAsset = 'assets/images/monalisaPerfil.png',
  Uint8List? memoryBytes,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: memoryBytes != null
                  ? Image.memory(memoryBytes, fit: BoxFit.contain)
                  : imageUrl.isEmpty
                      ? Image.asset(fallbackAsset, fit: BoxFit.contain)
                      : Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          Image.asset(fallbackAsset, fit: BoxFit.contain),
                    ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () => Navigator.pop(dialogContext),
              tooltip: 'Fechar',
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<Uint8List?> abrirEditorFotoPerfil(
  BuildContext context,
  Uint8List imageBytes,
) {
  final controller = CropController();
  var editorPronto = false;
  var cortando = false;

  return showDialog<Uint8List>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.cardBorder),
        ),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.mediumBrown.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.crop_rotate_rounded,
                color: AppTheme.mediumBrown,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ajustar foto de perfil',
                style: GoogleFonts.cormorantGaramond(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.sizeOf(dialogContext).width * 0.82,
          height: MediaQuery.sizeOf(dialogContext).height * 0.52,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Crop(
              image: imageBytes,
              controller: controller,
              aspectRatio: 1,
              interactive: true,
              baseColor: AppTheme.darkBrown,
              maskColor: Colors.black.withValues(alpha: 0.62),
              progressIndicator: const CircularProgressIndicator(
                color: AppTheme.lightBrown,
              ),
              onStatusChanged: (status) {
                if (!dialogContext.mounted) return;
                setDialogState(() {
                  editorPronto = status == CropStatus.ready;
                  cortando = status == CropStatus.cropping;
                });
              },
              onCropped: (result) {
                if (result is CropSuccess) {
                  Navigator.of(dialogContext).pop(result.croppedImage);
                } else if (result is CropFailure) {
                  if (dialogContext.mounted) {
                    setDialogState(() => cortando = false);
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Não foi possível ajustar a foto: ${result.cause}',
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: cortando ? null : () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed:
                editorPronto && !cortando ? controller.crop : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.mediumBrown,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            icon: cortando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 18),
            label: Text(cortando ? 'Processando...' : 'Aplicar ajuste'),
          ),
        ],
      ),
    ),
  );
}
