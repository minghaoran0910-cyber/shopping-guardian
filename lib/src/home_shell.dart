import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'analysis/analysis_request_summary.dart';
import 'analysis/analysis_request_review_dialog.dart';
import 'analysis/model_client.dart';
import 'analysis/price_timing_summary.dart';
import 'budget/budget_store.dart';
import 'data/all_data_clearer.dart';
import 'export/data_importer.dart';
import 'export/data_exporter.dart';
import 'history/decision_store.dart';
import 'history/decision_history_retriever.dart';
import 'history/purchase_feedback_dialog.dart';
import 'insights/decision_insights.dart';
import 'notifications/local_notification_service.dart';
import 'notifications/feedback_reminder_service.dart';
import 'owned/owned_item.dart';
import 'owned/owned_item_store.dart';
import 'owned/purchase_list_import.dart';
import 'patterns/pattern_generator.dart';
import 'patterns/candidate_fact_recorder.dart';
import 'patterns/confirmed_pattern_reference.dart';
import 'patterns/pattern_store.dart';
import 'patterns/personal_pattern.dart';
import 'prices/price_monitor_service.dart';
import 'prices/price_evidence.dart';
import 'prices/price_watch.dart';
import 'prices/price_watch_store.dart';
import 'profile/consumer_profile.dart';
import 'profile/consumer_profile_generator.dart';
import 'profile/consumer_profile_store.dart';
import 'release/app_version.dart';
import 'release/version_checker.dart';
import 'rules/consumption_rule_store.dart';
import 'copy.dart';
import 'import/cart_screenshot_importer.dart';
import 'import/import_coordinator.dart';
import 'import/import_diagnostic_exporter.dart';
import 'import/justoneapi_client.dart';
import 'import/order_screenshot_importer.dart';
import 'import/share_parser.dart';
import 'settings/model_config_store.dart';
import 'widgets/empty_state.dart';
import 'widgets/page_frame.dart';

part 'pages/cooldown_page.dart';
part 'pages/history_page.dart';
part 'pages/insights_page.dart';
part 'pages/settings_page.dart';

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
    required this.openSettingsRevision,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<Locale> onLocaleChanged;
  final String justOneApiToken;
  final Future<void> Function(String) onJustOneApiTokenChanged;
  final String? sharedText;
  final VoidCallback onSharedTextConsumed;
  final int openSettingsRevision;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  GuardianDestination selected = GuardianDestination.analyze;
  int dataRevision = 0;

  @override
  void didUpdateWidget(HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sharedText != null &&
        widget.sharedText != oldWidget.sharedText) {
      selected = GuardianDestination.analyze;
    }
    if (widget.openSettingsRevision != oldWidget.openSettingsRevision) {
      selected = GuardianDestination.settings;
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
      GuardianDestination.cooldown => CooldownPage(
        justOneApiToken: widget.justOneApiToken,
      ),
      GuardianDestination.history => const HistoryPage(),
      GuardianDestination.insights => const InsightsPage(),
      GuardianDestination.settings => SettingsPage(
        key: ValueKey(dataRevision),
        themeMode: widget.themeMode,
        locale: widget.locale,
        onThemeChanged: widget.onThemeChanged,
        onLocaleChanged: widget.onLocaleChanged,
        justOneApiToken: widget.justOneApiToken,
        onJustOneApiTokenChanged: widget.onJustOneApiTokenChanged,
        onDataImported: () => setState(() => dataRevision++),
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

  void _clearDraft() {
    inputController.clear();
    manualName.clear();
    manualPrice.clear();
    manualStore.clear();
    setState(() => showManual = false);
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
    return GuardianPageFrame(
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
                          final recognition =
                              await const CartScreenshotImporter()
                                  .pickAndRecognizeDetailed();
                          if (!context.mounted) return;
                          if (recognition.wasCancelled) return;
                          if (recognition.items.isEmpty) {
                            await showDialog<void>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  copy.t(
                                    '没有整理出商品',
                                    'No items could be prepared',
                                  ),
                                ),
                                content: Text(
                                  recognition.recognizedLineCount == 0
                                      ? copy.t(
                                          '这张图里的文字没有读出来。请换一张更清楚、没有遮挡的截图。',
                                          'No text could be read from this image. Try a clearer image without overlays.',
                                        )
                                      : copy.t(
                                          '已经读到 ${recognition.recognizedLineCount} 行文字，但没能确定商品名称和价格。可以换一张完整截图，或先手动填写。',
                                          '${recognition.recognizedLineCount} text lines were read, but the item name and price could not be determined. Try a complete screenshot or enter them manually.',
                                        ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(copy.t('知道了', 'OK')),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }
                          final saved = await showDialog<bool>(
                            context: context,
                            builder: (context) => _ImportPreviewDialog(
                              items: recognition.items,
                              justOneApiToken: widget.justOneApiToken,
                            ),
                          );
                          if (saved == true && mounted) _clearDraft();
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
                      setState(() => isImporting = true);
                      try {
                        final result = await ImportCoordinator(
                          details: details,
                        ).enrich(parsed);
                        previewItems = result.items;
                        if (context.mounted && result.warnings.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result.warnings
                                    .map(
                                      (warning) => switch (warning) {
                                        ImportWarning
                                            .taobaoCollectionNeedsScreenshot =>
                                          copy.t(
                                            '淘宝购物车暂时不能从链接自动读取，请改用购物车截图。',
                                            'Taobao carts cannot be read from a link yet. Use a cart screenshot instead.',
                                          ),
                                        ImportWarning.enrichmentFailed => copy.t(
                                          '部分商品没能自动补全，已保留分享文字里的信息，请在下一步手动核对。',
                                          'Some items could not be enriched. Their shared details were kept; review them manually in the next step.',
                                        ),
                                      },
                                    )
                                    .join('\n'),
                              ),
                              duration: const Duration(seconds: 6),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => isImporting = false);
                      }
                      if (!context.mounted) return;
                      final saved = await showDialog<bool>(
                        context: context,
                        builder: (context) => _ImportPreviewDialog(
                          items: previewItems,
                          justOneApiToken: widget.justOneApiToken,
                        ),
                      );
                      if (saved == true && mounted) _clearDraft();
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
    if (text.contains('拼多多') || text.contains('pinduoduo')) {
      return ShoppingPlatform.pinduoduo;
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
    final value = await showDialog<double>(
      context: context,
      builder: (context) => const _BudgetEditorDialog(),
    );
    if (value == null) return;
    await const BudgetStore().setLimit(value);
    if (mounted) {
      setState(() {
        snapshot = const BudgetStore().snapshot();
      });
    }
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

class _BudgetEditorDialog extends StatefulWidget {
  const _BudgetEditorDialog();

  @override
  State<_BudgetEditorDialog> createState() => _BudgetEditorDialogState();
}

class _BudgetEditorDialogState extends State<_BudgetEditorDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return AlertDialog(
      title: Text(copy.t('设置本月预算', 'Set monthly budget')),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(prefixText: '¥ '),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(copy.t('取消', 'Cancel')),
        ),
        FilledButton(
          onPressed: () {
            final value = double.tryParse(controller.text.trim());
            if (value != null) Navigator.pop(context, value);
          },
          child: Text(copy.t('保存', 'Save')),
        ),
      ],
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
  const _ImportPreviewDialog({
    required this.items,
    required this.justOneApiToken,
  });

  final List<SharedShoppingItem> items;
  final String justOneApiToken;

  @override
  State<_ImportPreviewDialog> createState() => _ImportPreviewDialogState();
}

class _ImportPreviewDialogState extends State<_ImportPreviewDialog> {
  late final List<SharedShoppingItem> items = [...widget.items];
  int processedItemCount = 0;
  int? analysisItemCount;

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
                  reviewed: true,
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

  Future<void> _analyzeItems() async {
    analysisItemCount ??= processedItemCount + items.length;
    while (items.isNotEmpty && mounted) {
      final current = items.first;
      final saved = await showDialog<bool>(
        context: context,
        builder: (context) => _AnalysisDialog(
          items: [current],
          justOneApiToken: widget.justOneApiToken,
          batchPosition: processedItemCount + 1,
          batchCount: analysisItemCount!,
        ),
      );
      if (saved != true || !mounted) return;
      setState(() {
        items.removeAt(0);
        processedItemCount += 1;
      });
    }
    if (mounted && items.isEmpty) Navigator.pop(context, true);
  }

  void _remove(int index) {
    setState(() {
      items.removeAt(index);
      if (analysisItemCount != null) analysisItemCount = analysisItemCount! - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return AlertDialog(
      title: Text(
        processedItemCount == 0
            ? copy.t('认出了 ${items.length} 项', '${items.length} found')
            : copy.t(
                '还剩 ${items.length} 项待分析',
                '${items.length} left to analyze',
              ),
      ),
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
                ShoppingPlatform.pinduoduo => copy.t('拼多多', 'Pinduoduo'),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  item.completeness ==
                                      ImportCompleteness.needsReview
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest
                                  : Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(switch (item.completeness) {
                              ImportCompleteness.complete => copy.t(
                                '信息完整',
                                'Details complete',
                              ),
                              ImportCompleteness.needsReview => copy.t(
                                '需核对',
                                'Needs review',
                              ),
                              ImportCompleteness.reviewed => copy.t(
                                '已核对',
                                'Reviewed',
                              ),
                            }, style: Theme.of(context).textTheme.labelSmall),
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
                    IconButton(
                      tooltip: copy.t('不分析这件', 'Remove from analysis'),
                      onPressed: () => _remove(index),
                      icon: const Icon(Icons.close),
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
          onPressed: items.isEmpty ? null : _analyzeItems,
          child: Text(copy.t('继续分析', 'Continue')),
        ),
      ],
    );
  }
}

class _AnalysisDialog extends StatefulWidget {
  const _AnalysisDialog({
    required this.items,
    required this.justOneApiToken,
    this.batchPosition = 1,
    this.batchCount = 1,
  });
  final List<SharedShoppingItem> items;
  final String justOneApiToken;
  final int batchPosition;
  final int batchCount;
  @override
  State<_AnalysisDialog> createState() => _AnalysisDialogState();
}

class _AnalysisDialogState extends State<_AnalysisDialog> {
  final reason = TextEditingController();
  final budget = TextEditingController();
  final category = TextEditingController();
  final tags = TextEditingController();
  bool analyzing = false;
  double get total => widget.items.fold<double>(
    0,
    (sum, item) => sum + (item.price ?? 0) * item.quantity,
  );

  @override
  void dispose() {
    reason.dispose();
    budget.dispose();
    category.dispose();
    tags.dispose();
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
      final decisionRecords = await const DecisionStore().readAll();
      final history = const DecisionHistoryRetriever().findRelevant(
        itemName: widget.items.map((item) => item.title ?? '未命名商品').join('、'),
        price: total,
        records: decisionRecords,
      );
      final itemName = widget.items
          .map((item) => item.title ?? copy.t('未命名商品', 'Unnamed item'))
          .join(copy.t('、', ', '));
      final ruleSummaries = matchedRules
          .map(
            (rule) =>
                '${rule.name}：${rule.description}'
                '${rule.waitDays == null ? '' : '（至少等待 ${rule.waitDays} 天）'}',
          )
          .toList();
      final minimumRuleWaitDays = matchedRules
          .map((rule) => rule.waitDays)
          .whereType<int>()
          .fold<int?>(null, (current, days) {
            if (current == null || days > current) return days;
            return current;
          });
      final historySummaries = history.map((item) => item.summary).toList();
      final selectedCategory = category.text.trim().isEmpty
          ? null
          : category.text.trim();
      final ownedItems = await const OwnedItemStore().activeInCategory(
        selectedCategory,
      );
      final ownedSummariesByName = <String, String>{
        for (final item in ownedItems)
          item.name.trim().toLowerCase():
              '${item.name} ×${item.quantity}（${_InsightsPageState._statusLabel(copy, item.status)}'
              '${item.notes?.isNotEmpty == true ? '；${item.notes}' : ''}）',
      };
      for (final record in decisionRecords.where(
        (record) =>
            record.countsAsPurchased &&
            selectedCategory != null &&
            record.category?.trim() == selectedCategory,
      )) {
        ownedSummariesByName.putIfAbsent(
          record.itemName.trim().toLowerCase(),
          () =>
              '${record.itemName}（${copy.t('来自已确认购买记录', 'confirmed purchase')}）',
        );
      }
      final ownedSummaries = ownedSummariesByName.values.take(10).toList();
      final confirmedPatterns = await const PatternStore()
          .readConfirmedReferences(
            validDecisionIds: decisionRecords.map((item) => item.id).toSet(),
          );
      final tagValues = tags.text
          .split(RegExp(r'[,，]'))
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toSet()
          .take(10)
          .toList();
      PriceTimingSummary priceTiming;
      if (widget.items.length != 1) {
        priceTiming = const PriceTimingSummary.insufficient(
          '多件商品不能共用一条价格记录，请逐件分析入手时机',
        );
      } else {
        final sourceItem = widget.items.single;
        final sourceItemId = PriceWatchIdentity.itemId(sourceItem);
        final watched = sourceItemId == null
            ? null
            : await const PriceWatchStore().findByIdentity(
                sourceItem.platform,
                sourceItemId,
              );
        priceTiming = watched == null
            ? const PriceTimingSummary.insufficient('尚未监测此商品')
            : PriceTimingSummary.fromEvidence(
                PriceEvidence.from(
                  await const PriceWatchStore().history(watched.id),
                  now: DateTime.now(),
                ),
              );
      }
      final requestSummary = AnalysisRequestSummary(
        endpoint: config.endpoint,
        itemName: itemName,
        price: total,
        reason: reason.text.trim(),
        category: selectedCategory,
        tags: tagValues,
        monthlyBudget: double.tryParse(budget.text.trim()),
        matchedRules: ruleSummaries,
        minimumRuleWaitDays: minimumRuleWaitDays,
        relatedHistory: historySummaries,
        confirmedPatterns: confirmedPatterns,
        ownedItems: ownedSummaries,
        priceTiming: priceTiming,
      );
      final confirmed = await _confirmAnalysisRequest(requestSummary);
      if (!confirmed || !mounted) return;
      final advice =
          await ModelClient(
            endpoint: config.endpoint,
            apiKey: config.apiKey,
            model: config.model,
            useStructuredOutput: config.structuredOutput,
          ).analyze(
            itemName: itemName,
            price: total,
            reason: reason.text.trim(),
            category: selectedCategory,
            tags: tagValues,
            monthlyBudget: double.tryParse(budget.text.trim()),
            matchedRules: ruleSummaries,
            minimumRuleWaitDays: minimumRuleWaitDays,
            relatedHistory: historySummaries,
            confirmedPatterns: confirmedPatterns,
            ownedItems: ownedSummaries,
            priceTiming: priceTiming,
          );
      if (!mounted) return;
      final saved = await showDialog<bool>(
        context: context,
        builder: (context) => _DecisionDialog(
          advice: advice,
          total: total,
          itemName: itemName,
          item: widget.items.single,
          justOneApiToken: widget.justOneApiToken,
          referencedHistory: historySummaries,
          referencedPatterns: confirmedPatterns,
          referencedOwnedItems: ownedSummaries,
          priceTiming: priceTiming,
          category: selectedCategory,
          tags: tagValues,
        ),
      );
      if (saved == true && mounted) Navigator.pop(context, true);
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

  Future<bool> _confirmAnalysisRequest(AnalysisRequestSummary summary) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AnalysisRequestReviewDialog(summary: summary),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    final item = widget.items.single;
    final itemName = item.title ?? copy.t('未命名商品', 'Unnamed item');
    return AlertDialog(
      title: Text(copy.t('买它是为了什么？', 'Why do you want this?')),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.batchCount > 1) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  copy.t(
                    '第 ${widget.batchPosition} 件，共 ${widget.batchCount} 件',
                    'Item ${widget.batchPosition} of ${widget.batchCount}',
                  ),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                [
                  itemName,
                  if (item.price != null)
                    '¥${(item.price! * item.quantity).toStringAsFixed(2)}',
                ].join(' · '),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 14),
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
            const SizedBox(height: 14),
            TextField(
              controller: category,
              decoration: InputDecoration(
                labelText: copy.t('分类（选填）', 'Category (optional)'),
                hintText: copy.t('例如：数码、唱片、家居', 'e.g. Tech, Music, Home'),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    copy.t(
                      '选择与“我的物品”相同的分类，才能进行同类对照。',
                      'Use the same category as My items to compare them.',
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: OwnedItemTemplates.categories
                        .map(
                          (value) => ActionChip(
                            label: Text(
                              _InsightsPageState._categoryLabel(copy, value),
                            ),
                            onPressed: () => setState(() {
                              category.text = value;
                            }),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: tags,
              decoration: InputDecoration(
                labelText: copy.t('标签（选填）', 'Tags (optional)'),
                hintText: copy.t('用逗号分隔', 'Separate with commas'),
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

class _DecisionDialog extends StatefulWidget {
  const _DecisionDialog({
    required this.advice,
    required this.total,
    required this.itemName,
    required this.item,
    required this.justOneApiToken,
    required this.referencedHistory,
    required this.referencedPatterns,
    required this.referencedOwnedItems,
    required this.priceTiming,
    required this.category,
    required this.tags,
  });
  final PurchaseAdvice advice;
  final double total;
  final String itemName;
  final SharedShoppingItem item;
  final String justOneApiToken;
  final List<String> referencedHistory;
  final List<ConfirmedPatternReference> referencedPatterns;
  final List<String> referencedOwnedItems;
  final PriceTimingSummary priceTiming;
  final String? category;
  final List<String> tags;

  @override
  State<_DecisionDialog> createState() => _DecisionDialogState();
}

class _DecisionDialogState extends State<_DecisionDialog> {
  late final TextEditingController targetPrice = TextEditingController(
    text: (widget.total * 0.9).toStringAsFixed(2),
  );
  bool monitorPrice = false;
  final Set<int> confirmedFactIndexes = {};

  bool get canMonitor =>
      widget.justOneApiToken.trim().isNotEmpty &&
      PriceWatchIdentity.supports(widget.item);

  @override
  void dispose() {
    targetPrice.dispose();
    super.dispose();
  }

  Future<void> _choose(BuildContext context, String choice) async {
    final target = double.tryParse(targetPrice.text.trim());
    if (monitorPrice && (target == null || target <= 0 || !target.isFinite)) {
      final copy = GuardianCopy.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(copy.t('目标价要大于 0。', 'Enter a target above 0.'))),
      );
      return;
    }
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    final waitUntil = choice == 'wait'
        ? now.add(Duration(days: widget.advice.waitDays ?? 7))
        : null;
    await const DecisionStore().add(
      DecisionRecord(
        id: id,
        itemName: widget.itemName,
        total: widget.total,
        verdict: widget.advice.verdict.name,
        userChoice: choice,
        summary: widget.advice.summary,
        createdAt: now,
        waitUntil: waitUntil,
        referencedHistory: widget.referencedHistory,
        referencedPatterns: widget.referencedPatterns
            .map((item) => item.auditText)
            .toList(),
        referencedOwnedItems: widget.referencedOwnedItems,
        category: widget.category,
        tags: widget.tags,
        risk: widget.advice.risk.name,
        confidence: widget.advice.confidence.name,
        budgetImpact: widget.advice.budgetImpact,
        priceTimingEvidence: widget.priceTiming.auditText,
        alternatives: widget.advice.alternatives,
        events: [
          DecisionEvent(status: 'analyzed', occurredAt: now),
          DecisionEvent(
            status: switch (choice) {
              'buy' => 'intend_to_buy',
              'wait' => 'waiting',
              'skip' => 'skipped',
              'alternative' => 'seeking_alternative',
              _ => 'analyzed',
            },
            occurredAt: now,
          ),
        ],
      ),
    );
    try {
      await const CandidateFactRecorder().record(
        facts: widget.advice.candidateFacts,
        confirmedIndexes: confirmedFactIndexes,
        decisionId: id,
        at: now,
      );
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              GuardianCopy.of(context).t(
                '购买决定已保存，但候选习惯没有保存成功。',
                'The decision was saved, but candidate patterns could not be saved.',
              ),
            ),
          ),
        );
      }
    }
    var priceWatchSaved = false;
    if (monitorPrice && canMonitor) {
      final itemId = PriceWatchIdentity.itemId(widget.item);
      if (target != null && itemId != null) {
        await const PriceWatchStore().save(
          PriceWatch(
            id: 'price_$id',
            decisionId: id,
            itemName: widget.itemName,
            platform: widget.item.platform,
            itemId: itemId,
            productUrl: widget.item.url,
            targetPrice: target,
            createdAt: now,
          ),
        );
        priceWatchSaved = true;
        try {
          await const PriceMonitorService().checkAll(
            token: widget.justOneApiToken,
          );
        } on Object {
          // The watch stays saved and can be checked again from Later.
        }
      }
    }
    var notificationScheduled = true;
    if (waitUntil != null) {
      try {
        notificationScheduled = await const LocalNotificationService().schedule(
          id: id,
          title: widget.itemName,
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
    if (context.mounted && priceWatchSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            GuardianCopy.of(context).t(
              '已开始监测；达到目标价时会提醒你可以考虑下单。',
              'Price watch started. You will be alerted when it reaches your target.',
            ),
          ),
        ),
      );
    }
    if (context.mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    final title = switch (widget.advice.verdict) {
      PurchaseVerdict.buy => copy.t('可以买', 'Buy'),
      PurchaseVerdict.wait => copy.t('先等等', 'Wait'),
      PurchaseVerdict.skip => copy.t('这次先不买', 'Skip'),
      PurchaseVerdict.alternative => copy.t('先看看替代方案', 'Find an alternative'),
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
                '¥${widget.total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(widget.advice.summary),
              const SizedBox(height: 8),
              Text(
                copy.t(
                  '风险：${_levelLabel(copy, widget.advice.risk)} · 信心：${_levelLabel(copy, widget.advice.confidence)}',
                  'Risk: ${_levelLabel(copy, widget.advice.risk)} · Confidence: ${_levelLabel(copy, widget.advice.confidence)}',
                ),
              ),
              if (widget.advice.budgetImpact.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    copy.t(
                      '预算影响：${widget.advice.budgetImpact}',
                      'Budget impact: ${widget.advice.budgetImpact}',
                    ),
                  ),
                ),
              if (widget.advice.waitDays != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    copy.t(
                      '建议等 ${widget.advice.waitDays} 天再看。',
                      'Check again in ${widget.advice.waitDays} days.',
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                copy.t('价格时机', 'Price timing'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(_priceTimingLabel(copy, widget.priceTiming)),
              ...widget.advice.reasons.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('• $item'),
                ),
              ),
              ...widget.advice.missingInformation.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('• $item'),
                ),
              ),
              if (widget.advice.alternatives.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  copy.t('可以考虑', 'Alternatives'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                ...widget.advice.alternatives.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('• $item'),
                  ),
                ),
              ],
              if (widget.advice.candidateFacts.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  copy.t('这像是你的习惯吗？', 'Does this sound like you?'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  copy.t(
                    '默认不采用。勾选确认后，才会参与之后的分析；未勾选的只会留在“习惯”页等待处理。',
                    'Not used by default. Checked facts can inform future analyses; unchecked facts remain pending in Patterns.',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                ...widget.advice.candidateFacts.indexed.map(
                  (entry) => CheckboxListTile(
                    key: ValueKey('candidate-fact-${entry.$1}'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: confirmedFactIndexes.contains(entry.$1),
                    onChanged: (value) => setState(() {
                      if (value == true) {
                        confirmedFactIndexes.add(entry.$1);
                      } else {
                        confirmedFactIndexes.remove(entry.$1);
                      }
                    }),
                    title: Text(entry.$2.text),
                    subtitle: Text(
                      copy.t(
                        '依据：${entry.$2.evidence}',
                        'Evidence: ${entry.$2.evidence}',
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              if (widget.referencedHistory.isEmpty)
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
                      '引用了 ${widget.referencedHistory.length} 条个人历史',
                      '${widget.referencedHistory.length} personal records used',
                    ),
                  ),
                  children: widget.referencedHistory
                      .map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(item),
                        ),
                      )
                      .toList(),
                ),
              if (widget.referencedPatterns.isNotEmpty)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    copy.t(
                      '引用了 ${widget.referencedPatterns.length} 条已确认规律',
                      '${widget.referencedPatterns.length} confirmed patterns used',
                    ),
                  ),
                  children: widget.referencedPatterns
                      .map(
                        (pattern) => ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: Text(pattern.text),
                          children: [
                            ...pattern.supportingEvidence.map(
                              (item) => ListTile(
                                dense: true,
                                leading: const Icon(Icons.add_circle_outline),
                                title: Text(copy.t('支持依据', 'Supporting')),
                                subtitle: Text(item),
                              ),
                            ),
                            ...pattern.contraryEvidence.map(
                              (item) => ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.remove_circle_outline,
                                ),
                                title: Text(copy.t('相反记录', 'Counterexample')),
                                subtitle: Text(item),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              if (widget.referencedOwnedItems.isNotEmpty)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    copy.t(
                      '对照了 ${widget.referencedOwnedItems.length} 件同类物品',
                      'Compared ${widget.referencedOwnedItems.length} owned items',
                    ),
                  ),
                  children: widget.referencedOwnedItems
                      .map((item) => ListTile(title: Text(item)))
                      .toList(),
                ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: monitorPrice,
                onChanged: canMonitor
                    ? (value) => setState(() => monitorPrice = value)
                    : null,
                title: Text(copy.t('到目标价时提醒我', 'Alert me at my target')),
                subtitle: Text(
                  canMonitor
                      ? copy.t(
                          '使用商品接口记录真实价格；检查时间受系统后台限制。',
                          'Uses the product API for real prices; timing depends on the operating system.',
                        )
                      : copy.t(
                          '需要淘宝或京东单品链接，并先配置 JustOneAPI。',
                          'Requires a Taobao or JD product link and JustOneAPI.',
                        ),
                ),
              ),
              if (monitorPrice)
                TextField(
                  controller: targetPrice,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: copy.t('目标价', 'Target price'),
                    prefixText: '¥ ',
                  ),
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

  static String _levelLabel(GuardianCopy copy, AdviceLevel level) =>
      switch (level) {
        AdviceLevel.low => copy.t('低', 'Low'),
        AdviceLevel.medium => copy.t('中', 'Medium'),
        AdviceLevel.high => copy.t('高', 'High'),
      };

  static String _priceTimingLabel(
    GuardianCopy copy,
    PriceTimingSummary timing,
  ) {
    final current = timing.current;
    final low = timing.recentLow;
    return switch (timing.status) {
      PriceTimingStatus.nearLocalLow => copy.t(
        '当前 ¥${current!.price.toStringAsFixed(2)}，接近本机 30 天低价 ¥${low!.price.toStringAsFixed(2)}。这只说明价格时机，不代表商品值得买。',
        'Current ¥${current.price.toStringAsFixed(2)}, near this device’s 30-day low of ¥${low.price.toStringAsFixed(2)}. This only describes timing, not whether the item is worth buying.',
      ),
      PriceTimingStatus.aboveLocalLow => copy.t(
        '当前 ¥${current!.price.toStringAsFixed(2)}，高于本机 30 天低价 ¥${low!.price.toStringAsFixed(2)}。',
        'Current ¥${current.price.toStringAsFixed(2)}, above this device’s 30-day low of ¥${low.price.toStringAsFixed(2)}.',
      ),
      PriceTimingStatus.insufficient => copy.t(
        '数据不足：${timing.note}',
        'Insufficient evidence: ${timing.note}',
      ),
    };
  }
}
