import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'analysis/model_client.dart';
import 'budget/budget_store.dart';
import 'export/data_exporter.dart';
import 'history/decision_store.dart';
import 'history/decision_history_retriever.dart';
import 'insights/decision_insights.dart';
import 'notifications/local_notification_service.dart';
import 'rules/consumption_rule_store.dart';
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
    this.sharedText,
    required this.onSharedTextConsumed,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final String justOneApiToken;
  final Future<void> Function(String) onJustOneApiTokenChanged;
  final String? sharedText;
  final VoidCallback onSharedTextConsumed;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  GuardianDestination selected = GuardianDestination.analyze;

  @override
  void didUpdateWidget(HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sharedText != null &&
        widget.sharedText != oldWidget.sharedText) {
      selected = GuardianDestination.analyze;
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final expanded = width >= 760;
    final body = switch (selected) {
      GuardianDestination.analyze => AnalyzePage(
        justOneApiToken: widget.justOneApiToken,
        sharedText: widget.sharedText,
        onSharedTextConsumed: widget.onSharedTextConsumed,
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
  const AnalyzePage({
    super.key,
    required this.justOneApiToken,
    this.sharedText,
    required this.onSharedTextConsumed,
  });

  final String justOneApiToken;
  final String? sharedText;
  final VoidCallback onSharedTextConsumed;

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  final inputController = TextEditingController();
  final manualName = TextEditingController();
  final manualPrice = TextEditingController();
  final manualStore = TextEditingController();
  bool showManual = false;
  bool isImporting = false;

  @override
  void initState() {
    super.initState();
    _applySharedText();
  }

  @override
  void didUpdateWidget(AnalyzePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sharedText != oldWidget.sharedText) _applySharedText();
  }

  void _applySharedText() {
    final value = widget.sharedText;
    if (value == null || value.isEmpty) return;
    inputController.text = value;
    inputController.selection = TextSelection.collapsed(offset: value.length);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onSharedTextConsumed();
    });
  }

  @override
  void dispose() {
    inputController.dispose();
    manualName.dispose();
    manualPrice.dispose();
    manualStore.dispose();
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
                          if (!context.mounted) return;
                          if (items.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  copy.t(
                                    '这张图里没认出商品。可以换张更清楚的截图，或手动填写。',
                                    'No items were found in this image. Try a clearer screenshot or enter the item manually.',
                                  ),
                                ),
                              ),
                            );
                            return;
                          }
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
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _ManualFields(
                name: manualName,
                price: manualPrice,
                store: manualStore,
              ),
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
                      var parsed = ShoppingShareParser.parse(
                        inputController.text,
                      );
                      if (parsed.isEmpty) {
                        final price = double.tryParse(manualPrice.text.trim());
                        if (showManual &&
                            manualName.text.trim().isNotEmpty &&
                            price != null) {
                          parsed = [
                            SharedShoppingItem(
                              platform: _manualPlatform(manualStore.text),
                              kind: ShareKind.product,
                              url: Uri.parse('local://manual/item'),
                              title: manualName.text.trim(),
                              price: price,
                            ),
                          ];
                        } else {
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

  ShoppingPlatform _manualPlatform(String value) {
    final text = value.toLowerCase();
    if (text.contains('京东') || text.contains('jd')) {
      return ShoppingPlatform.jd;
    }
    if (text.contains('淘宝') || text.contains('天猫') || text.contains('taobao')) {
      return ShoppingPlatform.taobao;
    }
    return ShoppingPlatform.unknown;
  }
}

class _BudgetStrip extends StatefulWidget {
  const _BudgetStrip();

  @override
  State<_BudgetStrip> createState() => _BudgetStripState();
}

class _BudgetStripState extends State<_BudgetStrip> {
  late Future<BudgetSnapshot> snapshot = const BudgetStore().snapshot();

  Future<void> _edit() async {
    final controller = TextEditingController();
    final copy = GuardianCopy.of(context);
    final value = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(copy.t('设置本月预算', 'Set monthly budget')),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: '¥ '),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(copy.t('取消', 'Cancel')),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, double.tryParse(controller.text)),
            child: Text(copy.t('保存', 'Save')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    await const BudgetStore().setLimit(value);
    if (mounted) setState(() => snapshot = const BudgetStore().snapshot());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final copy = GuardianCopy.of(context);
    return FutureBuilder<BudgetSnapshot>(
      future: snapshot,
      builder: (context, state) {
        final data = state.data ?? const BudgetSnapshot(limit: 0, spent: 0);
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
                value: data.limit == 0
                    ? copy.t('未设置', 'Not set')
                    : '¥ ${data.limit.toStringAsFixed(0)}',
              ),
              _BudgetValue(
                label: copy.t('已经花掉', 'Spent'),
                value: '¥ ${data.spent.toStringAsFixed(0)}',
              ),
              _BudgetValue(
                label: copy.t('还剩', 'Left'),
                value: '¥ ${data.left.toStringAsFixed(0)}',
                emphasized: true,
              ),
              TextButton.icon(
                onPressed: _edit,
                icon: const Icon(Icons.tune_rounded),
                label: Text(copy.t('改预算', 'Edit budget')),
              ),
            ],
          ),
        );
      },
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
  const _ManualFields({
    required this.name,
    required this.price,
    required this.store,
  });
  final TextEditingController name;
  final TextEditingController price;
  final TextEditingController store;

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final fields = [
          TextField(
            controller: name,
            decoration: InputDecoration(
              labelText: copy.t('商品名称 *', 'Item name *'),
            ),
          ),
          TextField(
            controller: price,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: copy.t('价格 *', 'Price *'),
              prefixText: '¥ ',
            ),
          ),
          TextField(
            controller: store,
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

class _ImportPreviewDialog extends StatefulWidget {
  const _ImportPreviewDialog({required this.items});

  final List<SharedShoppingItem> items;

  @override
  State<_ImportPreviewDialog> createState() => _ImportPreviewDialogState();
}

class _ImportPreviewDialogState extends State<_ImportPreviewDialog> {
  late final List<SharedShoppingItem> items = [...widget.items];

  Future<void> _edit(int index) async {
    final item = items[index];
    final name = TextEditingController(text: item.title);
    final price = TextEditingController(text: item.price?.toString());
    final quantity = TextEditingController(text: item.quantity.toString());
    final updated = await showDialog<SharedShoppingItem>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(GuardianCopy.of(context).t('修改商品', 'Edit item')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(
                labelText: GuardianCopy.of(context).t('商品名称', 'Item name'),
              ),
            ),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: GuardianCopy.of(context).t('价格', 'Price'),
                prefixText: '¥ ',
              ),
            ),
            TextField(
              controller: quantity,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: GuardianCopy.of(context).t('数量', 'Quantity'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(GuardianCopy.of(context).t('取消', 'Cancel')),
          ),
          FilledButton(
            onPressed: () {
              final parsedPrice = double.tryParse(price.text.trim());
              final parsedQuantity = int.tryParse(quantity.text.trim());
              if (name.text.trim().isEmpty ||
                  parsedPrice == null ||
                  parsedQuantity == null ||
                  parsedQuantity < 1) {
                return;
              }
              Navigator.pop(
                context,
                SharedShoppingItem(
                  platform: item.platform,
                  kind: item.kind,
                  url: item.url,
                  title: name.text.trim(),
                  shareCode: item.shareCode,
                  price: parsedPrice,
                  imageUrl: item.imageUrl,
                  quantity: parsedQuantity,
                ),
              );
            },
            child: Text(GuardianCopy.of(context).t('保存', 'Save')),
          ),
        ],
      ),
    );
    if (updated != null && mounted) setState(() => items[index] = updated);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    name.dispose();
    price.dispose();
    quantity.dispose();
  }

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
                      onPressed: () => _edit(index),
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
              builder: (context) => _AnalysisDialog(items: items),
            );
          },
          child: Text(copy.t('继续分析', 'Continue')),
        ),
      ],
    );
  }
}

class _AnalysisDialog extends StatefulWidget {
  const _AnalysisDialog({required this.items});
  final List<SharedShoppingItem> items;
  @override
  State<_AnalysisDialog> createState() => _AnalysisDialogState();
}

class _AnalysisDialogState extends State<_AnalysisDialog> {
  final reason = TextEditingController();
  final budget = TextEditingController();
  bool analyzing = false;
  double get total => widget.items.fold<double>(
    0,
    (sum, item) => sum + (item.price ?? 0) * item.quantity,
  );

  @override
  void dispose() {
    reason.dispose();
    budget.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final copy = GuardianCopy.of(context);
    if (reason.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(copy.t('写一句为什么想买。', 'Tell us why you want it.')),
        ),
      );
      return;
    }
    setState(() => analyzing = true);
    try {
      final config = await const ModelConfigStore().read();
      if (!config.isComplete) throw const ModelClientException('请先在设置里配置并测试模型');
      final matchedRules = await const ConsumptionRuleStore().matching(total);
      final history = const DecisionHistoryRetriever().findRelevant(
        itemName: widget.items.map((item) => item.title ?? '未命名商品').join('、'),
        price: total,
        records: await const DecisionStore().readAll(),
      );
      final advice =
          await ModelClient(
            baseUrl: config.baseUrl,
            apiKey: config.apiKey,
            model: config.model,
          ).analyze(
            itemName: widget.items
                .map((item) => item.title ?? '未命名商品')
                .join('、'),
            price: total,
            reason: reason.text.trim(),
            monthlyBudget: double.tryParse(budget.text.trim()),
            matchedRules: matchedRules
                .map((rule) => '${rule.name}：${rule.description}')
                .toList(),
            relatedHistory: history.map((item) => item.summary).toList(),
          );
      if (!mounted) return;
      Navigator.pop(context);
      showDialog<void>(
        context: context,
        builder: (context) => _DecisionDialog(
          advice: advice,
          total: total,
          itemName: widget.items.map((item) => item.title ?? '未命名商品').join('、'),
          referencedHistory: history.map((item) => item.summary).toList(),
        ),
      );
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(copy.t('分析失败：$error', 'Analysis failed: $error')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return AlertDialog(
      title: Text(copy.t('买它是为了什么？', 'Why do you want this?')),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reason,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(labelText: copy.t('购买理由', 'Reason')),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: budget,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: copy.t('本月剩余预算（选填）', 'Budget left (optional)'),
                prefixText: '¥ ',
              ),
            ),
            FutureBuilder<List<ConsumptionRule>>(
              future: const ConsumptionRuleStore().matching(total),
              builder: (context, snapshot) {
                final rules = snapshot.data ?? const [];
                if (rules.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      copy.t(
                        '本次命中：${rules.map((rule) => rule.name).join('、')}',
                        'Matched: ${rules.map((rule) => rule.name).join(', ')}',
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(copy.t('返回', 'Back')),
        ),
        FilledButton(
          onPressed: analyzing ? null : _run,
          child: Text(
            analyzing
                ? copy.t('分析中…', 'Analyzing…')
                : copy.t('开始分析', 'Analyze'),
          ),
        ),
      ],
    );
  }
}

class _DecisionDialog extends StatelessWidget {
  const _DecisionDialog({
    required this.advice,
    required this.total,
    required this.itemName,
    required this.referencedHistory,
  });
  final PurchaseAdvice advice;
  final double total;
  final String itemName;
  final List<String> referencedHistory;

  Future<void> _choose(BuildContext context, String choice) async {
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    final waitUntil = choice == 'wait'
        ? now.add(Duration(days: advice.waitDays ?? 7))
        : null;
    await const DecisionStore().add(
      DecisionRecord(
        id: id,
        itemName: itemName,
        total: total,
        verdict: advice.verdict.name,
        userChoice: choice,
        summary: advice.summary,
        createdAt: now,
        waitUntil: waitUntil,
        referencedHistory: referencedHistory,
      ),
    );
    var notificationScheduled = true;
    if (waitUntil != null) {
      try {
        notificationScheduled = await const LocalNotificationService().schedule(
          id: id,
          title: itemName,
          at: waitUntil,
        );
      } on PlatformException {
        notificationScheduled = false;
      }
    }
    if (context.mounted && waitUntil != null && !notificationScheduled) {
      final copy = GuardianCopy.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.t(
              '已加入稍后再看，但没能创建系统提醒。可以在系统设置中开启通知。',
              'Saved for later, but the system reminder could not be created. Enable notifications in system settings.',
            ),
          ),
        ),
      );
    }
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    final title = switch (advice.verdict) {
      PurchaseVerdict.buy => copy.t('可以买', 'Buy'),
      PurchaseVerdict.wait => copy.t('先等等', 'Wait'),
      PurchaseVerdict.skip => copy.t('这次先不买', 'Skip'),
      PurchaseVerdict.insufficientData => copy.t(
        '信息还不够',
        'Not enough information',
      ),
    };
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 540,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¥${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(advice.summary),
              if (advice.waitDays != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    copy.t(
                      '建议等 ${advice.waitDays} 天再看。',
                      'Check again in ${advice.waitDays} days.',
                    ),
                  ),
                ),
              ...advice.reasons.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('• $item'),
                ),
              ),
              ...advice.missingInformation.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('• $item'),
                ),
              ),
              const SizedBox(height: 10),
              if (referencedHistory.isEmpty)
                Text(
                  copy.t(
                    '本次为通用分析，没有引用个人历史。',
                    'General analysis; no personal history was used.',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  title: Text(
                    copy.t(
                      '引用了 ${referencedHistory.length} 条个人历史',
                      '${referencedHistory.length} personal records used',
                    ),
                  ),
                  children: referencedHistory
                      .map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(item),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _choose(context, 'buy'),
          child: Text(copy.t('决定购买', 'Buy')),
        ),
        TextButton(
          onPressed: () => _choose(context, 'wait'),
          child: Text(copy.t('稍后再看', 'Wait')),
        ),
        TextButton(
          onPressed: () => _choose(context, 'skip'),
          child: Text(copy.t('这次不买', 'Skip')),
        ),
        TextButton(
          onPressed: () => _choose(context, 'alternative'),
          child: Text(copy.t('寻找替代', 'Find alternative')),
        ),
      ],
    );
  }
}

class CooldownPage extends StatefulWidget {
  const CooldownPage({super.key});

  @override
  State<CooldownPage> createState() => _CooldownPageState();
}

class _CooldownPageState extends State<CooldownPage> {
  late final Future<List<DecisionRecord>> records = const DecisionStore()
      .readAll();

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return _PageFrame(
      title: copy.t('稍后再看', 'Later'),
      subtitle: copy.t('到时间了，我们再问一次。', 'We will check in when the time is up.'),
      child: FutureBuilder<List<DecisionRecord>>(
        future: records,
        builder: (context, snapshot) {
          final items = (snapshot.data ?? const [])
              .where((record) => record.waitUntil != null)
              .toList();
          if (items.isEmpty) {
            return _EmptyState(
              icon: Icons.hourglass_empty_rounded,
              title: copy.t('这里还空着', 'Nothing here yet'),
              description: copy.t(
                '决定晚点再买的商品会放在这里。',
                'Items you decide to wait on will show up here.',
              ),
            );
          }
          return Column(
            children: items.map((record) {
              final days = record.waitUntil!
                  .difference(DateTime.now())
                  .inDays
                  .clamp(0, 999);
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.hourglass_top_rounded),
                  title: Text(record.itemName),
                  subtitle: Text(record.summary),
                  trailing: Text(copy.t('还剩 $days 天', '$days days left')),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<DecisionRecord>> records = const DecisionStore().readAll();
  final search = TextEditingController();
  String status = 'all';

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void _reload() => setState(() => records = const DecisionStore().readAll());

  Future<void> _feedback(DecisionRecord record) async {
    final copy = GuardianCopy.of(context);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(copy.t('后来怎么样？', 'What happened later?')),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'satisfied'),
            child: Text(copy.t('买了，很满意', 'Bought it, satisfied')),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'regretted'),
            child: Text(copy.t('买了，有点后悔', 'Bought it, regretted')),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'not_bought'),
            child: Text(copy.t('最后没有买', 'Did not buy')),
          ),
        ],
      ),
    );
    if (value == null) return;
    await const DecisionStore().setFeedback(record.id, value);
    if (mounted) _reload();
  }

  Future<void> _details(DecisionRecord record) async {
    final copy = GuardianCopy.of(context);
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record.itemName),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¥${record.total.toStringAsFixed(2)}'),
                const SizedBox(height: 10),
                Text(
                  copy.t('模型建议：${record.verdict}', 'Model: ${record.verdict}'),
                ),
                Text(
                  copy.t(
                    '你的决定：${record.userChoice}',
                    'Your choice: ${record.userChoice}',
                  ),
                ),
                if (record.feedback != null)
                  Text(
                    copy.t(
                      '后来：${record.feedback}',
                      'Later: ${record.feedback}',
                    ),
                  ),
                const SizedBox(height: 12),
                Text(record.summary),
                const SizedBox(height: 14),
                Text(
                  record.referencedHistory.isEmpty
                      ? copy.t(
                          '本次为通用分析，没有引用个人历史。',
                          'General analysis; no personal history was used.',
                        )
                      : copy.t('本次引用的个人历史', 'Personal history used'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                ...record.referencedHistory.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('• $item'),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            child: Text(copy.t('删除', 'Delete')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'feedback'),
            child: Text(copy.t('补充反馈', 'Add feedback')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(copy.t('关闭', 'Close')),
          ),
        ],
      ),
    );
    if (action == 'feedback') await _feedback(record);
    if (action == 'delete' && mounted) {
      final confirmed =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(copy.t('删除这条记录？', 'Delete this record?')),
              content: Text(
                copy.t(
                  '关联的冷静期和预算统计也会更新。',
                  'Cooldown and budget totals will update.',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(copy.t('取消', 'Cancel')),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(copy.t('删除', 'Delete')),
                ),
              ],
            ),
          ) ??
          false;
      if (confirmed) {
        await const DecisionStore().delete(record.id);
        await const LocalNotificationService().cancel(record.id);
        if (mounted) _reload();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return _PageFrame(
      title: copy.t('记录', 'History'),
      subtitle: copy.t(
        '看过什么，最后买没买。',
        'What you considered and what you decided.',
      ),
      child: Column(
        children: [
          TextField(
            controller: search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: copy.t('搜索商品', 'Search items'),
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'all', label: Text(copy.t('全部', 'All'))),
              ButtonSegment(value: 'buy', label: Text(copy.t('购买', 'Bought'))),
              ButtonSegment(value: 'wait', label: Text(copy.t('等待', 'Waited'))),
              ButtonSegment(
                value: 'skip',
                label: Text(copy.t('放弃', 'Skipped')),
              ),
            ],
            selected: {status},
            onSelectionChanged: (value) => setState(() => status = value.first),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<DecisionRecord>>(
            future: records,
            builder: (context, snapshot) {
              final query = search.text.trim().toLowerCase();
              final items = (snapshot.data ?? const [])
                  .where(
                    (record) =>
                        (status == 'all' || record.userChoice == status) &&
                        (query.isEmpty ||
                            record.itemName.toLowerCase().contains(query)),
                  )
                  .toList();
              if (items.isEmpty) {
                return _EmptyState(
                  icon: Icons.history_rounded,
                  title: copy.t('还没有记录', 'No history yet'),
                  description: copy.t(
                    '分析过的商品会留在这里。',
                    'Analyzed items will appear here.',
                  ),
                );
              }
              return Column(
                children: items
                    .map(
                      (record) => Card(
                        child: ListTile(
                          title: Text(
                            record.itemName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${record.summary}\n${record.createdAt.toLocal().toString().substring(0, 16)}',
                          ),
                          isThreeLine: true,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('¥${record.total.toStringAsFixed(2)}'),
                              Text(record.userChoice),
                              if (record.feedback != null)
                                Text(
                                  record.feedback!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                          onTap: () => _details(record),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  late final Future<List<DecisionRecord>> records = const DecisionStore()
      .readAll();

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return _PageFrame(
      title: copy.t('你的习惯', 'Your patterns'),
      subtitle: copy.t('用过一阵子，这里才会有东西。', 'This fills in as you use the app.'),
      child: FutureBuilder<List<DecisionRecord>>(
        future: records,
        builder: (context, snapshot) {
          final insights = DecisionInsights.from(snapshot.data ?? const []);
          if (!insights.hasEnoughEvidence) {
            return _EmptyState(
              icon: Icons.psychology_outlined,
              title: copy.t('暂时看不出什么', 'Not enough data yet'),
              description: copy.t(
                '有三次以上记录后，再来看看。',
                'Come back after at least three decisions.',
              ),
            );
          }
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _InsightCard(
                label: copy.t('分析过', 'Analyzed'),
                value: insights.total,
              ),
              _InsightCard(
                label: copy.t('决定购买', 'Bought'),
                value: insights.bought,
              ),
              _InsightCard(
                label: copy.t('选择等待', 'Waited'),
                value: insights.waited,
              ),
              _InsightCard(
                label: copy.t('主动放弃', 'Skipped'),
                value: insights.skipped,
              ),
              _InsightCard(
                label: copy.t('买后后悔', 'Regretted'),
                value: insights.regretted,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Container(
    width: 180,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(label),
      ],
    ),
  );
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
          const _RuleSettings(),
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
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.file_download_outlined),
                  title: Text(copy.t('导出数据', 'Export data')),
                  subtitle: Text(
                    copy.t(
                      'API Key 不会放进导出文件。',
                      'Your API key is never included.',
                    ),
                  ),
                  onTap: () async {
                    final saved = await const DataExporter().export();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          saved
                              ? copy.t('数据已导出。', 'Data exported.')
                              : copy.t('已取消导出。', 'Export cancelled.'),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_sweep_outlined),
                  title: Text(copy.t('清除决策和预算', 'Clear decisions and budget')),
                  onTap: () => _confirmClear(context, copy, clearConfig: false),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.key_off_outlined),
                  title: Text(copy.t('清除 API 配置', 'Clear API configuration')),
                  onTap: () => _confirmClear(context, copy, clearConfig: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    GuardianCopy copy, {
    required bool clearConfig,
  }) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              clearConfig
                  ? copy.t('清除 API 配置？', 'Clear API configuration?')
                  : copy.t('清除决策和预算？', 'Clear decisions and budget?'),
            ),
            content: Text(copy.t('这个操作不能撤销。', 'This cannot be undone.')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(copy.t('取消', 'Cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(copy.t('确认清除', 'Clear')),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    if (clearConfig) {
      await const ModelConfigStore().clear();
      await onJustOneApiTokenChanged('');
    } else {
      await const DecisionStore().clear();
      await const BudgetStore().clear();
    }
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(copy.t('已经清除。', 'Cleared.'))));
    }
  }
}

class _RuleSettings extends StatefulWidget {
  const _RuleSettings();
  @override
  State<_RuleSettings> createState() => _RuleSettingsState();
}

class _RuleSettingsState extends State<_RuleSettings> {
  List<ConsumptionRule> rules = const [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await const ConsumptionRuleStore().readAll();
    if (mounted) setState(() => rules = value);
  }

  Future<void> _save(List<ConsumptionRule> value) async {
    await const ConsumptionRuleStore().saveAll(value);
    if (mounted) setState(() => rules = value);
  }

  Future<void> _add() async {
    final name = TextEditingController();
    final description = TextEditingController();
    final amount = TextEditingController();
    final days = TextEditingController();
    final rule = await showDialog<ConsumptionRule>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(GuardianCopy.of(context).t('新增消费规则', 'Add rule')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: InputDecoration(
                  labelText: GuardianCopy.of(context).t('规则名称', 'Name'),
                ),
              ),
              TextField(
                controller: description,
                decoration: InputDecoration(
                  labelText: GuardianCopy.of(context).t('规则描述', 'Description'),
                ),
              ),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: GuardianCopy.of(
                    context,
                  ).t('最低金额（选填）', 'Minimum amount (optional)'),
                  prefixText: '¥ ',
                ),
              ),
              TextField(
                controller: days,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: GuardianCopy.of(
                    context,
                  ).t('建议等待天数（选填）', 'Wait days (optional)'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(GuardianCopy.of(context).t('取消', 'Cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty || description.text.trim().isEmpty) {
                return;
              }
              Navigator.pop(
                context,
                ConsumptionRule(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  name: name.text.trim(),
                  description: description.text.trim(),
                  minimumAmount: double.tryParse(amount.text.trim()),
                  waitDays: int.tryParse(days.text.trim()),
                ),
              );
            },
            child: Text(GuardianCopy.of(context).t('保存', 'Save')),
          ),
        ],
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    name.dispose();
    description.dispose();
    amount.dispose();
    days.dispose();
    if (rule != null) await _save([...rules, rule]);
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return _SettingsSection(
      title: copy.t('消费规则', 'Purchase rules'),
      icon: Icons.rule_outlined,
      children: [
        if (rules.isEmpty)
          Text(
            copy.t(
              '还没有规则。可以先加一条“大额商品至少等两天”。',
              'No rules yet. Add one for large purchases.',
            ),
          ),
        ...rules.map(
          (rule) => Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(rule.name),
              subtitle: Text(rule.description),
              leading: Switch(
                value: rule.enabled,
                onChanged: (value) => _save(
                  rules
                      .map(
                        (item) => item.id == rule.id
                            ? item.copyWith(enabled: value)
                            : item,
                      )
                      .toList(),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () =>
                    _save(rules.where((item) => item.id != rule.id).toList()),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonalIcon(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: Text(copy.t('新增规则', 'Add rule')),
          ),
        ),
      ],
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
