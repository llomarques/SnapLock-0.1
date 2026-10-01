import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  static const _languageKey = 'app_language';

  Locale _locale = const Locale('pt', 'BR');

  Locale get locale => _locale;

  String get languageName {
    switch (_locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Espanol';
      default:
        return 'Portugues (Brasil)';
    }
  }

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString(_languageKey);

    if (languageCode == 'en') {
      _locale = const Locale('en');
    } else if (languageCode == 'es') {
      _locale = const Locale('es');
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, locale.languageCode);
  }
}

final appLanguage = AppLanguage();
