import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class AppThemeController extends ChangeNotifier {
  static const _preferenceKey = 'app_dark_mode';
  static final AppThemeController instance = AppThemeController._();

  AppThemeController._();

  bool _isDark = false;

  bool get isDark => _isDark;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _isDark = preferences.getBool(_preferenceKey) ?? false;
    AppTheme.setDarkMode(_isDark);
  }

  Future<void> setDark(bool isDark) async {
    if (_isDark == isDark) return;

    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setBool(_preferenceKey, isDark);
    if (!saved) {
      throw StateError('Não foi possível salvar a preferência de tema.');
    }

    _isDark = isDark;
    AppTheme.setDarkMode(isDark);
    notifyListeners();
  }
}
