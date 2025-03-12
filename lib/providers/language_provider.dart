import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale? _locale;
  static const String _languageCodeKey = 'languageCode';

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Locale? get locale => _locale;

  // Get the list of supported locales
  static List<Locale> get supportedLocales => [
    const Locale('en'), // English
    const Locale('es'), // Spanish
    const Locale('fr'), // French
    const Locale('de'), // German
    const Locale('zh'), // Chinese
    const Locale('vi'), // Vietnamese
  ];

  // Get the list of supported language names
  static Map<String, String> get supportedLanguages => {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'zh': '中文',
    'vi': 'Tiếng Việt',
    'system': 'System Default',
  };

  // Load the saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageCodeKey);
    
    if (languageCode != null && languageCode != 'system') {
      _locale = Locale(languageCode);
    } else {
      _locale = null; // Use system default
    }
    
    notifyListeners();
  }

  // Set the app's language
  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (languageCode == 'system') {
      _locale = null;
      await prefs.setString(_languageCodeKey, 'system');
    } else {
      _locale = Locale(languageCode);
      await prefs.setString(_languageCodeKey, languageCode);
    }
    
    notifyListeners();
  }

  // Get the current language code
  String getCurrentLanguageCode() {
    return _locale?.languageCode ?? 'system';
  }
} 