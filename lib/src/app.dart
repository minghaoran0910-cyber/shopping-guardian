import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_shell.dart';
import 'settings/api_key_store.dart';
import 'theme.dart';

class ShoppingGuardianApp extends StatefulWidget {
  const ShoppingGuardianApp({super.key});

  @override
  State<ShoppingGuardianApp> createState() => _ShoppingGuardianAppState();
}

class _ShoppingGuardianAppState extends State<ShoppingGuardianApp> {
  ThemeMode themeMode = ThemeMode.system;
  Locale locale = const Locale('zh');
  String justOneApiToken = const String.fromEnvironment('JUSTONEAPI_TOKEN');

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    try {
      final saved = await const ApiKeyStore().readJustOneApiToken();
      if (mounted && saved.isNotEmpty) setState(() => justOneApiToken = saved);
    } catch (_) {
      // Secure storage can be unavailable in widget tests.
    }
  }

  Future<void> _setJustOneApiToken(String value) async {
    await const ApiKeyStore().writeJustOneApiToken(value);
    if (mounted) setState(() => justOneApiToken = value.trim());
  }

  Future<void> _loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    final savedTheme = preferences.getString('theme_mode');
    final savedLanguage = preferences.getString('language');
    if (!mounted) return;
    setState(() {
      themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedTheme,
        orElse: () => ThemeMode.system,
      );
      locale = Locale(savedLanguage == 'en' ? 'en' : 'zh');
    });
  }

  Future<void> _setThemeMode(ThemeMode value) async {
    setState(() => themeMode = value);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('theme_mode', value.name);
  }

  Future<void> _setLocale(Locale value) async {
    setState(() => locale = value);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('language', value.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: locale.languageCode == 'zh' ? '购物守护者' : 'Shopping Guardian',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: GuardianTheme.light(),
      darkTheme: GuardianTheme.dark(),
      locale: locale,
      supportedLocales: const [Locale('zh'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: HomeShell(
        themeMode: themeMode,
        locale: locale,
        onThemeChanged: _setThemeMode,
        onLocaleChanged: _setLocale,
        justOneApiToken: justOneApiToken,
        onJustOneApiTokenChanged: _setJustOneApiToken,
      ),
    );
  }
}
