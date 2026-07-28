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
  int openSettingsRevision = 0;

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
    final openSettings = await showDialog<bool>(
      context: dialogContext,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.tune_outlined),
        title: Text(isZh ? '三步开始使用' : 'Get started in three steps'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OnboardingStep(
                  number: '1',
                  title: isZh ? '现在就能用' : 'Ready now',
                  body: isZh
                      ? '手动填写、粘贴分享文字和截图识别都在本地完成。商品、预算、规则和历史默认只存在这台设备。'
                      : 'Manual entry, shared text, and screenshot recognition work locally. Items, budgets, rules, and history stay on this device by default.',
                ),
                const SizedBox(height: 12),
                _OnboardingStep(
                  number: '2',
                  title: isZh ? '分析前配置自己的模型' : 'Add your model for analysis',
                  body: isZh
                      ? '只有 AI 分析需要模型 Endpoint、模型名和你自己的 API Key。发送前可以核对内容；项目没有中转服务器。'
                      : 'AI analysis needs your model endpoint, model name, and API key. You can review the payload before sending; this project has no relay server.',
                ),
                const SizedBox(height: 12),
                _OnboardingStep(
                  number: '3',
                  title: isZh ? '商品自动补全是可选项' : 'Product enrichment is optional',
                  body: isZh
                      ? 'JustOneAPI Token 只用于补全淘宝或京东商品资料。不填写也能用手动输入和截图导入。所有密钥都不会进入业务数据导出。'
                      : 'A JustOneAPI token only enriches Taobao or JD product details. Manual and screenshot imports work without it. Keys are excluded from business-data exports.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final preferences = await SharedPreferences.getInstance();
              await preferences.setBool('onboarding_seen', true);
              if (context.mounted) Navigator.pop(context, false);
            },
            child: Text(isZh ? '先逛逛' : 'Explore first'),
          ),
          FilledButton(
            onPressed: () async {
              final preferences = await SharedPreferences.getInstance();
              await preferences.setBool('onboarding_seen', true);
              if (context.mounted) Navigator.pop(context, true);
            },
            child: Text(isZh ? '去设置' : 'Open settings'),
          ),
        ],
      ),
    );
    if (openSettings == true && mounted) {
      setState(() => openSettingsRevision++);
    }
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
        openSettingsRevision: openSettingsRevision,
      ),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CircleAvatar(radius: 14, child: Text(number)),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 3),
            Text(body),
          ],
        ),
      ),
    ],
  );
}
