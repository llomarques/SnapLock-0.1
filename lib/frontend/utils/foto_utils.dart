import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class FotoUtils {
  static final ImagePicker _picker = ImagePicker();

  static Future<Uint8List?> selecionarDaGaleria() async {
    final imagem = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (imagem == null) {
      return null;
    }

    return imagem.readAsBytes();
  }
}