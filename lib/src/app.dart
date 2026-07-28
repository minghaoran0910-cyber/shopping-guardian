import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_shell.dart';
import 'import/shared_text_receiver.dart';
import 'settings/api_key_store.dart';
import 'theme.dart';

class ShoppingGuardianApp extends StatefulWidget {
  const ShoppingGuardianApp({super.key, this.sharedTextReceiver});

  final SharedTextReceiver? sharedTextReceiver;

  @override
  State<ShoppingGuardianApp> createState() => _ShoppingGuardianAppState();
}

class _ShoppingGuardianAppState extends State<ShoppingGuardianApp> {
  final navigatorKey = GlobalKey<NavigatorState>();
  ThemeMode themeMode = ThemeMode.system;
  Locale locale = const Locale('zh');
  String justOneApiToken = const String.fromEnvironment('JUSTONEAPI_TOKEN');
  late final SharedTextReceiver sharedTextReceiver;
  String? sharedText;

  @override
  void initState() {
    super.initState();
    sharedTextReceiver = widget.sharedTextReceiver ?? SharedTextReceiver();
    sharedTextReceiver.start(_receiveSharedText);
    _loadPreferences();
    _loadApiKey();
  }

  void _receiveSharedText(String value) {
    if (mounted) setState(() => sharedText = value);
  }

  void _consumeSharedText() {
    if (mounted) setState(() => sharedText = null);
  }

  @override
  void dispose() {
    sharedTextReceiver.stop();
    super.dispose();
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
    final onboardingSeen = preferences.getBool('onboarding_seen') ?? false;
    if (!mounted) return;
    setState(() {
      themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedTheme,
        orElse: () => ThemeMode.system,
      );
      locale = Locale(savedLanguage == 'en' ? 'en' : 'zh');
    });
    if (!onboardingSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showOnboarding());
    }
  }

  Future<void> _showOnboarding() async {
    final dialogContext = navigatorKey.currentContext;
    if (!mounted || dialogContext == null) return;
    final isZh = locale.languageCode == 'zh';
    await showDialog<void>(
      context: dialogContext,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.shield_outlined),
        title: Text(isZh ? '先说清楚数据去哪儿' : 'Where your data goes'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isZh
                    ? '商品、预算、规则和历史默认保存在这台设备；截图识别也在本地完成。'
                    : 'Items, budgets, rules, and history stay on this device by default. Screenshot recognition also runs locally.',
              ),
              const SizedBox(height: 12),
              Text(
                isZh
                    ? '获取商品资料时，商品链接或 ID 会直达 JustOneAPI。开始分析前，应用会让你核对将要直达模型服务的商品、理由、预算、规则和相关历史摘要。'
                    : 'To retrieve product details, the product link or ID goes directly to JustOneAPI. Before analysis, you can review the item, reason, budget, rules, and related-history summaries sent directly to your model service.',
              ),
              const SizedBox(height: 12),
              Text(
                isZh
                    ? '本项目没有账号和中转服务器。API Key 不会放进请求正文或数据导出。模型建议仅供参考，不会替你购买。'
                    : 'This project has no accounts or relay server. API keys are excluded from request bodies and data exports. Model advice is informational and never purchases for you.',
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () async {
              final preferences = await SharedPreferences.getInstance();
              await preferences.setBool('onboarding_seen', true);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(isZh ? '我知道了' : 'Got it'),
          ),
        ],
      ),
    );
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
      navigatorKey: navigatorKey,
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
        sharedText: sharedText,
        onSharedTextConsumed: _consumeSharedText,
      ),
    );
  }
}
