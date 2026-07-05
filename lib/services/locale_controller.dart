import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gere la langue de l'app (pulaar 'ff' par defaut) et persiste le
/// choix de l'utilisateur. Ecoutable par MaterialApp pour rebasculer
/// l'interface a chaud.
class LocaleController extends ValueNotifier<Locale> {
  LocaleController() : super(defaultLocale);

  static const Locale defaultLocale = Locale('ff');
  static const List<Locale> supported = [Locale('ff'), Locale('fr')];
  static const String _prefsKey = 'app_locale';

  /// Charge le choix enregistre (ou garde le pulaar par defaut).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && supported.any((l) => l.languageCode == code)) {
      value = Locale(code);
    }
  }

  /// Change la langue et enregistre le choix.
  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == value.languageCode) return;
    value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}
