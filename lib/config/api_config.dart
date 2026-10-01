import 'package:flutter/foundation.dart';

class ApiConfig {
  // Configuração de URL base do Backend
  // No Web e Windows Desktop: http://localhost:8080/api
  // No Emulador Android: http://10.0.2.2:8080/api
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    } else {
      return 'http://localhost:3000/api';
    }
  }

  static String get mediaBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    } else {
      return 'http://localhost:3000';
    }
  }
}
