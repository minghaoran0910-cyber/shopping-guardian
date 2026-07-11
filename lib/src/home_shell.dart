import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'analysis/model_client.dart';
import 'copy.dart';
import 'import/jd_cart_importer.dart';
import 'import/cart_screenshot_importer.dart';
import 'import/jd_product_importer.dart';
import 'import/justoneapi_client.dart';
import 'import/share_parser.dart';
import 'import/taobao_product_importer.dart';
import 'settings/model_config_store.dart';

enum GuardianDestination {
  analyze(
    '添加商品',
    'Add',
    Icons.add_circle_outline_rounded,
    Icons.add_circle_rounded,
  ),
  cooldown(
    '稍后再看',
    'Later',
    Icons.hourglass_empty_rounded,
    Icons.hourglass_top_rounded,
  ),
  history('记录', 'History', Icons.history_rounded, Icons.history_rounded),
  insights(
    '习惯',
    'Patterns',
    Icons.psychology_outlined,
    Icons.psychology_rounded,
  ),
  settings('设置', 'Settings', Icons.settings_outlined, Icons.settings_rounded);

  const GuardianDestination(this.zh, this.en, this.icon, this.selectedIcon);
  final String zh;
  final String en;
  final IconData icon;
  final IconData selectedIcon;

  String label(GuardianCopy copy) => copy.t(zh, en);
}

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.themeMode,
    required this.locale,
    required this.onThemeChanged,
    required this.onLocaleChanged,
    required this.justOneApiToken,
    required this.onJustOneApiTokenChanged,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final String justOneApiToken;
  final Future<void> Function(String) onJustOneApiTokenChanged;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  GuardianDestination selected = GuardianDestination.analyze;

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final expanded = width >= 760;
    final body = switch (selected) {
      GuardianDestination.analyze => AnalyzePage(
        justOneApiToken: widget.justOneApiToken,
      ),
      GuardianDestination.cooldown => const CooldownPage(),
      GuardianDestination.history => const HistoryPage(),
      GuardianDestination.insights => const InsightsPage(),
      GuardianDestination.settings => SettingsPage(
        themeMode: widget.themeMode,
        locale: widget.locale,
        onThemeChanged: widget.onThemeChanged,
        onLocaleChanged: widget.onLocaleChanged,
        justOneApiToken: widget.justOneApiToken,
        onJustOneApiTokenChanged: widget.onJustOneApiTokenChanged,
      ),
    };

    if (!expanded) {
      return Scaffold(
        body: SafeArea(child: body),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selected.index,
          onDestinationSelected: (index) =>
              setState(() => selected = GuardianDestination.values[index]),
          destinations: GuardianDestination.values
              .map(
                (item) => NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label(copy),
                ),
              )
              .toList(),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              minWidth: width >= 1100 ? 224 : 88,
              extended: width >= 1100,
              selectedIndex: selected.index,
              onDestinationSelected: (index) =>
                  setState(() => selected = GuardianDestination.values[index]),
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 28),
                child: width >= 1100 ? const _Wordmark() : const _LogoMark(),
              ),
              destinations: GuardianDestination.values
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: Text(item.label(copy)),
                    ),
                  )
                  .toList(),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: SafeArea(left: false, child: body)),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: GuardianCopy.of(context).t('购物守护者', 'Shopping Guardian'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.shield_outlined,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _LogoMark(),
        const SizedBox(width: 12),
        Text(
          GuardianCopy.of(context).t('购物守护者', 'Shopping Guardian'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _PageFrame extends StatelessWidget {
  const _PageFrame({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth < 600 ? 16.0 : 32.0;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontal, 28, horizontal, 48),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  child,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnalyzePage extends StatefulWidget {
  const AnalyzePage({super.key, required this.justOneApiToken});

  final String justOneApiToken;

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  final inputController = TextEditingController();
  bool showManual = false;
  bool isImporting = false;

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return _PageFrame(
      title: copy.t('想买什么？', 'What are you considering?'),
      subtitle: copy.t('贴个链接，或者直接写下来。', 'Paste a link or type it in.'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BudgetStrip(),
          const SizedBox(height: 32),
          Text(
            copy.t('商品信息', 'Item details'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            copy.t(
              '能识别多少算多少，剩下的你来补。',
              'We will fill what we can. You can edit the rest.',
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: inputController,
            minLines: 4,
            maxLines: 7,
            decoration: InputDecoration(
              labelText: copy.t('链接或描述', 'Link or description'),
              alignLabelWithHint: true,
              hintText: copy.t(
                '粘贴商品链接或分享文字',
                'Paste a product link or shared text',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: isImporting
                    ? null
                    : () async {
                        setState(() => isImporting = true);
                        try {
                          final items = await const CartScreenshotImporter()
                              .pickAndRecognize();
                          if (!context.mounted || items.isEmpty) return;
                          showDialog<void>(
                            context: context,
                            builder: (context) =>
                                _ImportPreviewDialog(items: items),
                          );
                        } on PlatformException catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                copy.t(
                                  '截图没读出来：${error.message ?? error.code}',
                                  'Could not read the image: ${error.message ?? error.code}',
                                ),
                              ),
                            ),
                          );
                        } finally {
                          if (mounted) setState(() => isImporting = false);
                        }
                      },
                icon: const Icon(Icons.image_outlined),
                label: Text(copy.t('选截图', 'Choose image')),
              ),
              TextButton.icon(
                onPressed: () => setState(() => showManual = !showManual),
                icon: Icon(
                  showManual ? Icons.expand_less : Icons.edit_outlined,
                ),
                label: Text(
                  showManual
                      ? copy.t('收起', 'Hide fields')
                      : copy.t('手动填写', 'Enter manually'),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: showManual
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: const Padding(
              padding: EdgeInsets.only(top: 20),
              child: _ManualFields(),
            ),
          ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: isImporting
                  ? null
                  : () async {
                      if (inputController.text.trim().isEmpty && !showManual) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              copy.t(
                                '先填点商品信息。',
                                'Add some item details first.',
                              ),
                            ),
                          ),
                        );
                        return;
                      }
                      final parsed = ShoppingShareParser.parse(
                        inputController.text,
                      );
                      if (parsed.isEmpty) {
                        setState(() => showManual = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              copy.t(
                                '没认出链接，手动补一下名称和价格。',
                                'Link not recognized. Add the name and price manually.',
                              ),
                            ),
                          ),
                        );
                        return;
                      }
                      var previewItems = parsed;
                      final details = widget.justOneApiToken.isEmpty
                          ? null
                          : JustOneApiClient(token: widget.justOneApiToken);
                      final jdCollections = parsed.where(
                        (item) =>
                            item.platform == ShoppingPlatform.jd &&
                            item.kind == ShareKind.collection,
                      );
                      if (jdCollections.isNotEmpty) {
                        setState(() => isImporting = true);
                        try {
                          final imported = <SharedShoppingItem>[];
                          for (final collection in jdCollections) {
                            imported.addAll(
                              await JdCartImporter(
                                productDetails: details,
                              ).load(collection.url),
                            );
                          }
                          previewItems = [
                            ...parsed.where(
                              (item) =>
                                  !(item.platform == ShoppingPlatform.jd &&
                                      item.kind == ShareKind.collection),
                            ),
                            ...imported,
                          ];
                        } on JdCartImportException catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                copy.t(
                                  '京东清单没读出来，${error.message}',
                                  'Could not read the JD collection: ${error.message}',
                                ),
                              ),
                            ),
                          );
                        } finally {
                          if (mounted) setState(() => isImporting = false);
                        }
                      }
                      final jdProducts = parsed.where(
                        (item) =>
                            item.platform == ShoppingPlatform.jd &&
                            item.kind == ShareKind.product,
                      );
                      if (jdProducts.isNotEmpty && details != null) {
                        setState(() => isImporting = true);
                        final imported = <SharedShoppingItem>[];
                        try {
                          for (final item in jdProducts) {
                            imported.add(
                              await JdProductImporter(
                                productDetails: details,
                              ).load(item.url),
                            );
                          }
                          previewItems = [
                            ...previewItems.where(
                              (item) =>
                                  !(item.platform == ShoppingPlatform.jd &&
                                      item.kind == ShareKind.product),
                            ),
                            ...imported,
                          ];
                        } on Object catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                copy.t(
                                  '京东商品没读出来：$error',
                                  'Could not read the JD item: $error',
                                ),
                              ),
                            ),
                          );
                        } finally {
                          if (mounted) setState(() => isImporting = false);
                        }
                      }
                      final taobaoProducts = parsed.where(
                        (item) =>
                            item.platform == ShoppingPlatform.taobao &&
                            item.kind == ShareKind.product,
                      );
                      if (taobaoProducts.isNotEmpty && details != null) {
                        setState(() => isImporting = true);
                        final imported = <SharedShoppingItem>[];
                        try {
                          for (final item in taobaoProducts) {
                            imported.add(
                              await TaobaoProductImporter(
                                productDetails: details,
                              ).load(item.url),
                            );
                          }
                          previewItems = [
                            ...previewItems.where(
                              (item) =>
                                  !(item.platform == ShoppingPlatform.taobao &&
                                      item.kind == ShareKind.product),
                            ),
                            ...imported,
                          ];
                        } on Object catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                copy.t(
                                  '淘宝商品没读出来：$error',
                                  'Could not read the Taobao item: $error',
                                ),
                              ),
                            ),
                          );
                        } finally {
                          if (mounted) setState(() => isImporting = false);
                        }
                      }
                      if (!context.mounted) return;
                      showDialog<void>(
                        context: context,
                        builder: (context) =>
                            _ImportPreviewDialog(items: previewItems),
                      );
                    },
              icon: isImporting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward_rounded),
              label: Text(
                isImporting
                    ? copy.t('正在读取', 'Reading')
                    : copy.t('下一步', 'Continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetStrip extends StatelessWidget {
  const _BudgetStrip();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final copy = GuardianCopy.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Wrap(
        spacing: 36,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _BudgetValue(
            label: copy.t('本月预算', 'Monthly budget'),
            value: '¥ 2,000',
          ),
          _BudgetValue(label: copy.t('已经花掉', 'Spent'), value: '¥ 680'),
          _BudgetValue(
            label: copy.t('还剩', 'Left'),
            value: '¥ 1,320',
            emphasized: true,
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded),
            label: Text(copy.t('改预算', 'Edit budget')),
          ),
        ],
      ),
    );
  }
}

class _BudgetValue extends StatelessWidget {
  const _BudgetValue({
    required this.label,
    required this.value,
    this.emphasized = false,
  });
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: emphasized ? scheme.primary : scheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _ManualFields extends StatelessWidget {
  const _ManualFields();

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final fields = [
          TextField(
            decoration: InputDecoration(
              labelText: copy.t('商品名称 *', 'Item name *'),
            ),
          ),
          TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: copy.t('价格 *', 'Price *'),
              prefixText: '¥ ',
            ),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: copy.t('平台（选填）', 'Store (optional)'),
            ),
          ),
        ];
        if (constraints.maxWidth < 680) {
          return Column(
            children: fields
                .expand((field) => [field, const SizedBox(height: 12)])
                .toList(),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              fields
                  .expand(
                    (field) => [
                      Expanded(child: field),
                      const SizedBox(width: 12),
                    ],
                  )
                  .toList()
                ..removeLast(),
        );
      },
    );
  }
}

class _ImportPreviewDialog extends StatelessWidget {
  const _ImportPreviewDialog({required this.items});

  final List<SharedShoppingItem> items;

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return AlertDialog(
      title: Text(copy.t('认出了 ${items.length} 项', '${items.length} found')),
      content: SizedBox(
        width: 560,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 440),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final platform = switch (item.platform) {
                ShoppingPlatform.taobao => copy.t('淘宝', 'Taobao'),
                ShoppingPlatform.jd => copy.t('京东', 'JD'),
                ShoppingPlatform.unknown => copy.t('其他', 'Other'),
              };
              final kind = item.kind == ShareKind.collection
                  ? copy.t('购物清单', 'Collection')
                  : copy.t('单品', 'Item');
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.kind == ShareKind.collection
                            ? Icons.shopping_cart_outlined
                            : Icons.inventory_2_outlined,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title ?? copy.t('未读到商品名称', 'No title found'),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            [
                              platform,
                              kind,
                              if (item.price != null)
                                '¥${item.price!.toStringAsFixed(item.price! % 1 == 0 ? 0 : 2)}',
                              if (item.quantity > 1) '×${item.quantity}',
                            ].join(' · '),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.url.host,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: copy.t('编辑', 'Edit'),
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(copy.t('返回', 'Back')),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            showDialog<void>(
              context: context,
              builder: (context) => const _ModelSetupDialog(),
            );
          },
          child: Text(copy.t('继续填写', 'Continue')),
        ),
      ],
    );
  }
}

class _ModelSetupDialog extends StatelessWidget {
  const _ModelSetupDialog();

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return AlertDialog(
      icon: const Icon(Icons.key_rounded),
      title: Text(copy.t('还没配置模型', 'Model not configured')),
      content: SizedBox(
        width: 420,
        child: Text(
          copy.t(
            '去设置里填 API 地址、密钥和模型名称。',
            'Add your API URL, key, and model in Settings.',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(copy.t('取消', 'Cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(copy.t('打开设置', 'Open Settings')),
        ),
      ],
    );
  }
}

class CooldownPage extends StatelessWidget {
  const CooldownPage({super.key});

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return _PageFrame(
      title: copy.t('稍后再看', 'Later'),
      subtitle: copy.t('到时间了，我们再问一次。', 'We will check in when the time is up.'),
      child: _EmptyState(
        icon: Icons.hourglass_empty_rounded,
        title: copy.t('这里还空着', 'Nothing here yet'),
        description: copy.t(
          '决定晚点再买的商品会放在这里。',
          'Items you decide to wait on will show up here.',
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return _PageFrame(
      title: copy.t('记录', 'History'),
      subtitle: copy.t(
        '看过什么，最后买没买。',
        'What you considered and what you decided.',
      ),
      child: _EmptyState(
        icon: Icons.history_rounded,
        title: copy.t('还没有记录', 'No history yet'),
        description: copy.t('分析过的商品会留在这里。', 'Analyzed items will appear here.'),
      ),
    );
  }
}

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return _PageFrame(
      title: copy.t('你的习惯', 'Your patterns'),
      subtitle: copy.t('用过一阵子，这里才会有东西。', 'This fills in as you use the app.'),
      child: _EmptyState(
        icon: Icons.psychology_outlined,
        title: copy.t('暂时看不出什么', 'Not enough data yet'),
        description: copy.t(
          '有三次以上类似记录后，再来看看。',
          'Come back after a few similar decisions.',
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.themeMode,
    required this.locale,
    required this.onThemeChanged,
    required this.onLocaleChanged,
    required this.justOneApiToken,
    required this.onJustOneApiTokenChanged,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final String justOneApiToken;
  final Future<void> Function(String) onJustOneApiTokenChanged;

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return _PageFrame(
      title: copy.t('设置', 'Settings'),
      subtitle: copy.t('按你习惯的方式来。', 'Set things up your way.'),
      child: Column(
        children: [
          _JustOneApiSettings(
            initialToken: justOneApiToken,
            onSaved: onJustOneApiTokenChanged,
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: copy.t('外观', 'Appearance'),
            icon: Icons.palette_outlined,
            children: [
              _SettingRow(
                title: copy.t('主题', 'Theme'),
                child: SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(copy.t('跟随系统', 'System')),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(copy.t('浅色', 'Light')),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(copy.t('深色', 'Dark')),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (value) => onThemeChanged(value.first),
                ),
              ),
              _SettingRow(
                title: copy.t('语言', 'Language'),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'zh', label: Text('中文')),
                    ButtonSegment(value: 'en', label: Text('English')),
                  ],
                  selected: {locale.languageCode},
                  onSelectionChanged: (value) =>
                      onLocaleChanged(Locale(value.first)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _ModelSettings(),
          const SizedBox(height: 16),
          _SettingsSection(
            title: copy.t('数据', 'Data'),
            icon: Icons.lock_outline_rounded,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.cloud_off_outlined),
                title: Text(copy.t('只存在这台设备', 'Stored on this device')),
                subtitle: Text(
                  copy.t(
                    '商品、预算和记录不会传到我们的服务器。',
                    'Items, budgets, and history stay on this device.',
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.file_download_outlined),
                title: Text(copy.t('导出数据', 'Export data')),
                subtitle: Text(
                  copy.t(
                    'API Key 不会放进导出文件。',
                    'Your API key is never included.',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModelSettings extends StatefulWidget {
  const _ModelSettings();
  @override
  State<_ModelSettings> createState() => _ModelSettingsState();
}

class _ModelSettingsState extends State<_ModelSettings> {
  final baseUrl = TextEditingController();
  final apiKey = TextEditingController();
  final model = TextEditingController();
  bool loading = true;
  bool testing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final config = await const ModelConfigStore().read();
      baseUrl.text = config.baseUrl;
      apiKey.text = config.apiKey;
      model.text = config.model;
    } on MissingPluginException {
      // Native storage is unavailable in widget tests.
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _testAndSave() async {
    final copy = GuardianCopy.of(context);
    final config = ModelConfig(
      baseUrl: baseUrl.text.trim(),
      model: model.text.trim(),
      apiKey: apiKey.text.trim(),
    );
    if (!config.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(copy.t('三个字段都要填写。', 'Fill in all three fields.')),
        ),
      );
      return;
    }
    setState(() => testing = true);
    try {
      await ModelClient(
        baseUrl: config.baseUrl,
        apiKey: config.apiKey,
        model: config.model,
      ).analyze(itemName: '连接测试', price: 1, reason: '只测试连接');
      await const ModelConfigStore().write(config);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.t('模型连接正常，配置已保存。', 'Connected. Configuration saved.'),
          ),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(copy.t('连接失败：$error', 'Connection failed: $error')),
        ),
      );
    } finally {
      if (mounted) setState(() => testing = false);
    }
  }

  @override
  void dispose() {
    baseUrl.dispose();
    apiKey.dispose();
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return _SettingsSection(
      title: copy.t('模型', 'Model'),
      icon: Icons.hub_outlined,
      children: [
        TextField(
          controller: baseUrl,
          enabled: !loading,
          decoration: const InputDecoration(
            labelText: 'Base URL',
            hintText: 'https://api.example.com/v1',
          ),
        ),
        TextField(
          controller: apiKey,
          enabled: !loading,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'API Key',
            hintText: '••••••••••••',
          ),
        ),
        TextField(
          controller: model,
          enabled: !loading,
          decoration: InputDecoration(
            labelText: copy.t('模型名称', 'Model name'),
            hintText: 'deepseek-chat',
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonalIcon(
            onPressed: loading || testing ? null : _testAndSave,
            icon: testing
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.link_rounded),
            label: Text(copy.t('测试并保存', 'Test and save')),
          ),
        ),
      ],
    );
  }
}

class _JustOneApiSettings extends StatefulWidget {
  const _JustOneApiSettings({
    required this.initialToken,
    required this.onSaved,
  });

  final String initialToken;
  final Future<void> Function(String) onSaved;

  @override
  State<_JustOneApiSettings> createState() => _JustOneApiSettingsState();
}

class _JustOneApiSettingsState extends State<_JustOneApiSettings> {
  late final TextEditingController controller;
  bool busy = false;
  bool obscure = true;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialToken);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _saveAndTest() async {
    final copy = GuardianCopy.of(context);
    final token = controller.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(copy.t('先填 API Key。', 'Enter an API key.'))),
      );
      return;
    }
    setState(() => busy = true);
    try {
      await JustOneApiClient(token: token).loadJdProduct('63081885510');
      await widget.onSaved(token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.t('连接正常，Key 已安全保存。', 'Connected. The key is saved securely.'),
          ),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(copy.t('连接失败：$error', 'Connection failed: $error')),
        ),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return _SettingsSection(
      title: 'JustOneAPI',
      icon: Icons.inventory_2_outlined,
      children: [
        Text(
          copy.t(
            '用来补全商品价格、图片和店铺信息。Key 只保存在这台设备。',
            'Used to fill in prices, images, and shop details. The key stays on this device.',
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: 'API Key',
            hintText: '••••••••••••',
            suffixIcon: IconButton(
              onPressed: () => setState(() => obscure = !obscure),
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonalIcon(
            onPressed: busy ? null : _saveAndTest,
            icon: busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.link_rounded),
            label: Text(copy.t('测试并保存', 'Test and save')),
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 10),
              child,
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.labelLarge),
            ),
            child,
          ],
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 20),
          ...children
              .expand((child) => [child, const SizedBox(height: 16)])
              .toList()
            ..removeLast(),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: scheme.primary),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
