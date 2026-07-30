part of '../home_shell.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  final profileCardKey = GlobalKey();
  late Future<
    (
      List<DecisionRecord>,
      List<PersonalPattern>,
      List<OwnedItem>,
      ConsumerProfile?,
    )
  >
  data = _load();

  Future<
    (
      List<DecisionRecord>,
      List<PersonalPattern>,
      List<OwnedItem>,
      ConsumerProfile?,
    )
  >
  _load() async {
    final records = await const DecisionStore().readAll();
    final stored = await const PatternStore().readAll();
    final ownedItems = await const OwnedItemStore().readAll();
    final profile = await const ConsumerProfileStore().read();
    final patterns = const PatternGenerator().merge(
      const PatternGenerator().generate(records),
      stored,
    );
    return (records, patterns, ownedItems, profile);
  }

  Future<void> _createProfile(List<DecisionRecord> records) async {
    final references = await const PatternStore().readConfirmedReferences(
      validDecisionIds: records.map((item) => item.id).toSet(),
    );
    var profile = const ConsumerProfileGenerator().fromEvidence(references);
    if (profile == null && mounted) {
      final answers = await _showProfileQuiz();
      if (answers == null) return;
      profile = const ConsumerProfileGenerator().fromQuiz(answers);
    }
    if (profile == null || !mounted) return;
    final edited = await _editProfile(profile);
    if (edited == null) return;
    await const ConsumerProfileStore().save(edited);
    if (mounted) setState(() => data = _load());
  }

  Future<List<int>?> _showProfileQuiz() async {
    final copy = GuardianCopy.of(context);
    final answers = List<int?>.filled(4, null);
    const questions = [
      ('准备方式', '先列清单', '看到喜欢再说'),
      ('已有物品', '先检查能否继续用', '更想体验新功能'),
      ('优惠出现', '至少等一晚', '合适就快速决定'),
      ('分享标签', '提醒自己保持弹性', '喜欢鲜明有趣的称号'),
    ];
    return showDialog<List<int>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(copy.t('四道趣味小题', 'Four quick questions')),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    copy.t(
                      '现有记录还不足以生成画像，先用一个本地小测试。答案不会发送给模型。',
                      'There is not enough evidence yet, so use this local quiz. Answers are not sent to a model.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final (index, question) in questions.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.$1,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 6),
                          SegmentedButton<int>(
                            emptySelectionAllowed: true,
                            segments: [
                              ButtonSegment(value: 0, label: Text(question.$2)),
                              ButtonSegment(value: 1, label: Text(question.$3)),
                            ],
                            selected: answers[index] == null
                                ? const {}
                                : {answers[index]!},
                            onSelectionChanged: (value) => setDialogState(
                              () => answers[index] = value.firstOrNull,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(copy.t('取消', 'Cancel')),
            ),
            FilledButton(
              onPressed: answers.every((item) => item != null)
                  ? () => Navigator.pop(context, answers.cast<int>().toList())
                  : null,
              child: Text(copy.t('生成结果', 'Create result')),
            ),
          ],
        ),
      ),
    );
  }

  Future<ConsumerProfile?> _editProfile(ConsumerProfile profile) async {
    final copy = GuardianCopy.of(context);
    final title = TextEditingController(text: profile.title);
    final traits = [
      for (final trait in profile.traits) TextEditingController(text: trait),
    ];
    final reminder = TextEditingController(text: profile.reminder);
    final result = await showDialog<ConsumerProfile>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final candidate = profile.copyWith(
            title: title.text.trim(),
            traits: traits.map((item) => item.text.trim()).toList(),
            reminder: reminder.text.trim(),
          );
          return AlertDialog(
            title: Text(copy.t('编辑消费人格', 'Edit spending persona')),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: title,
                      maxLength: 24,
                      decoration: InputDecoration(
                        labelText: copy.t('趣味名称', 'Fun title'),
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    for (final (index, controller) in traits.indexed)
                      TextField(
                        controller: controller,
                        maxLength: 60,
                        decoration: InputDecoration(
                          labelText: copy.t(
                            '特点 ${index + 1}',
                            'Trait ${index + 1}',
                          ),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                    TextField(
                      controller: reminder,
                      maxLength: 100,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: copy.t('给自己的提醒', 'Reminder'),
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    Text(
                      copy.t(
                        ConsumerProfile.disclaimer,
                        'For entertainment only; not a psychological or scientific assessment.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(copy.t('取消', 'Cancel')),
              ),
              FilledButton(
                onPressed: candidate.isValid
                    ? () => Navigator.pop(context, candidate)
                    : null,
                child: Text(copy.t('保存', 'Save')),
              ),
            ],
          );
        },
      ),
    );
    title.dispose();
    for (final controller in traits) {
      controller.dispose();
    }
    reminder.dispose();
    return result;
  }

  Future<void> _saveProfileCard() async {
    final copy = GuardianCopy.of(context);
    try {
      final boundary =
          profileCardKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) throw const FormatException();
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw const FormatException();
      final location = await getSaveLocation(
        suggestedName: 'shopping-guardian-profile.png',
      );
      if (location == null) return;
      await XFile.fromData(
        data.buffer.asUint8List(),
        mimeType: 'image/png',
        name: 'shopping-guardian-profile.png',
      ).saveTo(location.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(copy.t('分享卡已保存。', 'Share card saved.'))),
        );
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(copy.t('这台设备暂时无法保存分享卡。', 'Could not save the card.')),
          ),
        );
      }
    }
  }

  Future<void> _save(PersonalPattern pattern) async {
    await const PatternStore().save(pattern);
    if (mounted) {
      setState(() {
        data = _load();
      });
    }
  }

  Future<void> _edit(PersonalPattern pattern) async {
    final controller = TextEditingController(text: pattern.text);
    final text = await showDialog<String>(
      context: context,
      builder: (context) {
        final copy = GuardianCopy.of(context);
        return AlertDialog(
          title: Text(copy.t('修改这条规律', 'Edit pattern')),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 4,
            maxLength: 200,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(copy.t('取消', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(copy.t('保存', 'Save')),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (text?.isNotEmpty == true) {
      await _save(pattern.copyWith(text: text, status: 'confirmed'));
    }
  }

  Future<void> _editOwnedItem([OwnedItem? existing]) async {
    final copy = GuardianCopy.of(context);
    final name = TextEditingController(text: existing?.name);
    final notes = TextEditingController(text: existing?.notes);
    final price = TextEditingController(
      text: existing?.purchasePrice?.toString(),
    );
    var category = existing?.category ?? OwnedItemTemplates.categories.first;
    var status = existing?.status ?? 'in_use';
    var quantity = existing?.quantity ?? 1;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            existing == null
                ? copy.t('添加已有物品', 'Add an item')
                : copy.t('修改已有物品', 'Edit item'),
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    autofocus: true,
                    maxLength: 100,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: copy.t('物品名称 *', 'Item name *'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: InputDecoration(
                      labelText: copy.t('分类', 'Category'),
                    ),
                    items: OwnedItemTemplates.categories
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(_categoryLabel(copy, value)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => category = value ?? category),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: InputDecoration(
                      labelText: copy.t('当前状态', 'Current status'),
                    ),
                    items: OwnedItemTemplates.statuses
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(_statusLabel(copy, value)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => status = value ?? status),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: Text(copy.t('数量', 'Quantity'))),
                      IconButton(
                        tooltip: copy.t('减少', 'Decrease'),
                        onPressed: quantity <= 1
                            ? null
                            : () => setDialogState(() => quantity--),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$quantity'),
                      IconButton(
                        tooltip: copy.t('增加', 'Increase'),
                        onPressed: quantity >= 999
                            ? null
                            : () => setDialogState(() => quantity++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  TextField(
                    controller: price,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: copy.t(
                        '当时价格（选填）',
                        'Purchase price (optional)',
                      ),
                      prefixText: '¥ ',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notes,
                    maxLength: 300,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: copy.t(
                        '备注（型号、用途等）',
                        'Notes (model, use, etc.)',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(copy.t('取消', 'Cancel')),
            ),
            FilledButton(
              onPressed: name.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(dialogContext, true),
              child: Text(copy.t('保存', 'Save')),
            ),
          ],
        ),
      ),
    );
    final parsedPrice = price.text.trim().isEmpty
        ? null
        : double.tryParse(price.text.trim());
    if (saved == true && name.text.trim().isNotEmpty) {
      if (price.text.trim().isNotEmpty &&
          (parsedPrice == null || parsedPrice < 0)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(copy.t('价格格式不正确。', 'Invalid price.'))),
          );
        }
      } else {
        final now = DateTime.now();
        await const OwnedItemStore().save(
          OwnedItem(
            id:
                existing?.id ??
                'owned_${now.microsecondsSinceEpoch.toString()}',
            name: name.text.trim(),
            category: category,
            status: status,
            quantity: quantity,
            notes: notes.text,
            purchasePrice: parsedPrice,
            acquiredAt: existing?.acquiredAt,
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
          ),
        );
        if (mounted) {
          setState(() {
            data = _load();
          });
        }
      }
    }
  }

  Future<void> _deleteOwnedItem(OwnedItem item) async {
    final copy = GuardianCopy.of(context);
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(copy.t('删除这件物品？', 'Delete this item?')),
            content: Text(
              copy.t(
                '删除后，之后的分析不会再把“${item.name}”当作你已有的物品。',
                'Future analyses will no longer treat “${item.name}” as something you own.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(copy.t('取消', 'Cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(copy.t('删除', 'Delete')),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await const OwnedItemStore().delete(item.id);
    if (mounted) {
      setState(() {
        data = _load();
      });
    }
  }

  Future<PurchaseListDraft?> _editPurchaseDraft(PurchaseListDraft draft) async {
    final copy = GuardianCopy.of(context);
    final name = TextEditingController(text: draft.name);
    final price = TextEditingController(
      text: draft.purchasePrice?.toString() ?? '',
    );
    final date = TextEditingController(
      text: draft.acquiredAt?.toIso8601String().substring(0, 10) ?? '',
    );
    final notes = TextEditingController(text: draft.notes);
    var category = draft.category;
    var status = draft.status;
    String? validationError;
    return showDialog<PurchaseListDraft>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(copy.t('修改识别结果', 'Edit recognized item')),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    key: const Key('purchase-draft-name'),
                    controller: name,
                    autofocus: true,
                    maxLength: 160,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: copy.t('商品名称 *', 'Item name *'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: InputDecoration(
                      labelText: copy.t('分类', 'Category'),
                    ),
                    items: OwnedItemTemplates.categories
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(_categoryLabel(copy, value)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => category = value ?? category),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: InputDecoration(
                      labelText: copy.t('当前状态', 'Current status'),
                    ),
                    items: OwnedItemTemplates.statuses
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(_statusLabel(copy, value)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => status = value ?? status),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: price,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: copy.t(
                        '当时价格（选填）',
                        'Purchase price (optional)',
                      ),
                      prefixText: '¥ ',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: date,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: copy.t('购买日期（选填）', 'Purchase date (optional)'),
                      hintText: 'YYYY-MM-DD',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notes,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 300,
                    decoration: InputDecoration(
                      labelText: copy.t('备注（选填）', 'Notes (optional)'),
                    ),
                  ),
                  if (validationError != null)
                    Text(
                      validationError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(copy.t('取消', 'Cancel')),
            ),
            FilledButton(
              onPressed: name.text.trim().isEmpty
                  ? null
                  : () {
                      final safeNotes = notes.text.replaceAll('|', '／');
                      final parsed = const PurchaseListParser().parse(
                        '${name.text.replaceAll('|', '／')} | $category | '
                        '$status | ${price.text} | ${date.text} | $safeNotes',
                      );
                      if (parsed.isEmpty || !parsed.single.isValid) {
                        setDialogState(() {
                          validationError = copy.t(
                            '请检查价格和日期格式。',
                            'Check the price and date formats.',
                          );
                        });
                        return;
                      }
                      Navigator.pop(
                        dialogContext,
                        parsed.single.copyWith(included: draft.included),
                      );
                    },
              child: Text(copy.t('保存修改', 'Save changes')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importOrderScreenshot(List<OwnedItem> existingItems) async {
    final copy = GuardianCopy.of(context);
    try {
      final result = await const OrderScreenshotImporter().pickAndRecognize();
      if (!mounted || result.wasCancelled) return;
      if (result.drafts.isEmpty) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(copy.t('没有整理出订单商品', 'No order items found')),
            content: Text(
              result.recognizedLineCount == 0
                  ? copy.t(
                      '这张图里的文字没有读出来。请换一张更清楚的订单截图。',
                      'No text could be read. Try a clearer order screenshot.',
                    )
                  : copy.t(
                      '读到了 ${result.recognizedLineCount} 行文字，但无法可靠配对商品名称和价格。可以换一张包含完整商品卡片的订单截图，或使用“导入购买清单”。',
                      '${result.recognizedLineCount} lines were read, but item names and prices could not be paired reliably. Try a complete order screenshot or use “Import purchases”.',
                    ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(copy.t('知道了', 'OK')),
              ),
            ],
          ),
        );
        return;
      }
      String safe(String? value) => (value ?? '').replaceAll('|', '／');
      final text = result.drafts
          .map(
            (draft) => [
              safe(draft.name),
              draft.category,
              draft.status,
              draft.purchasePrice?.toString() ?? '',
              '',
              safe(draft.notes),
            ].join(' | '),
          )
          .join('\n');
      await _importPurchaseList(existingItems, initialInput: text);
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.t(
              '订单截图没读出来：${error.message ?? error.code}',
              'Could not read the order screenshot: ${error.message ?? error.code}',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _importPurchaseList(
    List<OwnedItem> existingItems, {
    String? initialInput,
  }) async {
    final copy = GuardianCopy.of(context);
    final controller = TextEditingController(text: initialInput);
    final input =
        initialInput ??
        await showDialog<String>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(copy.t('导入历史购买清单', 'Import purchase history')),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      copy.t(
                        '每行一件，用“|”分隔：名称 | 分类 | 当前状态 | 当时价格 | 日期 | 备注',
                        'One item per line, separated by “|”: name | category | current status | price | date | notes',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      copy.t(
                        '状态可填：仍在使用、备用、已淘汰、已转卖、已退货。留空会按“买过，现状不确定”处理。',
                        'Status: in_use, backup, retired, returned. Blank means previously bought, current status unknown.',
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('purchase-list-input'),
                      controller: controller,
                      autofocus: true,
                      minLines: 7,
                      maxLines: 14,
                      decoration: InputDecoration(
                        hintText: copy.t(
                          'AirPods Pro | 数码 | 仍在使用 | 1499 | 2024-06-18 | 通勤\n'
                              '旧键盘 | 数码 | 已转卖 | 399 | 2022-03-01',
                          'AirPods Pro | 数码 | in_use | 1499 | 2024-06-18 | commute\n'
                              'Old keyboard | 数码 | retired | 399 | 2022-03-01',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(copy.t('取消', 'Cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, controller.text),
                child: Text(copy.t('解析并预览', 'Parse and preview')),
              ),
            ],
          ),
        );
    if (input == null || input.trim().isEmpty || !mounted) return;
    final parsed = const PurchaseListParser().parse(input);
    if (parsed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(copy.t('没有找到可导入的行。', 'No importable rows found.')),
        ),
      );
      return;
    }

    final normalizedExisting = {
      for (final item in existingItems)
        '${item.name.trim().toLowerCase()}\u0000${item.category}',
    };
    final seenInInput = <String>{};
    final drafts = parsed.map((item) {
      final key = '${item.name.trim().toLowerCase()}\u0000${item.category}';
      final duplicate =
          normalizedExisting.contains(key) || !seenInInput.add(key);
      return item.copyWith(included: item.isValid && !duplicate);
    }).toList();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final selected = drafts.where(
            (item) => item.included && item.isValid,
          );
          bool isDuplicate(int index) {
            final draft = drafts[index];
            final key =
                '${draft.name.trim().toLowerCase()}\u0000${draft.category}';
            if (normalizedExisting.contains(key)) return true;
            for (var previous = 0; previous < index; previous++) {
              final other = drafts[previous];
              if (!other.included) continue;
              final otherKey =
                  '${other.name.trim().toLowerCase()}\u0000${other.category}';
              if (otherKey == key) return true;
            }
            return false;
          }

          return AlertDialog(
            title: Text(copy.t('核对后再导入', 'Review before importing')),
            content: SizedBox(
              width: 640,
              height: MediaQuery.sizeOf(context).height * .62,
              child: ListView.builder(
                itemCount: drafts.length,
                itemBuilder: (context, index) {
                  final draft = drafts[index];
                  final conflict = isDuplicate(index);
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: draft.included,
                            onChanged: draft.isValid && !conflict
                                ? (value) => setDialogState(
                                    () => drafts[index] = draft.copyWith(
                                      included: value ?? false,
                                    ),
                                  )
                                : null,
                            title: Text(
                              draft.name.isEmpty
                                  ? copy.t('未填写名称', 'Missing name')
                                  : draft.name,
                            ),
                            subtitle: Text(
                              conflict
                                  ? copy.t(
                                      '同名同分类项目已存在或在本清单前面出现，默认不导入。',
                                      'This name and category already exists or appeared earlier; excluded by default.',
                                    )
                                  : draft.error != null
                                  ? _purchaseImportError(copy, draft.error!)
                                  : [
                                      if (draft.purchasePrice != null)
                                        '¥${draft.purchasePrice!.toStringAsFixed(2)}',
                                      if (draft.acquiredAt != null)
                                        draft.acquiredAt!
                                            .toIso8601String()
                                            .substring(0, 10),
                                      if (draft.notes?.isNotEmpty == true)
                                        draft.notes!,
                                    ].join(' · '),
                            ),
                            secondary: IconButton(
                              tooltip: copy.t('修改这一项', 'Edit this item'),
                              onPressed: () async {
                                final edited = await _editPurchaseDraft(draft);
                                if (edited != null) {
                                  setDialogState(() {
                                    drafts[index] = edited.copyWith(
                                      included: edited.isValid,
                                    );
                                  });
                                }
                              },
                              icon: const Icon(Icons.edit_outlined),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: draft.category,
                                  decoration: InputDecoration(
                                    labelText: copy.t('分类', 'Category'),
                                  ),
                                  items: OwnedItemTemplates.categories
                                      .map(
                                        (value) => DropdownMenuItem(
                                          value: value,
                                          child: Text(
                                            _categoryLabel(copy, value),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) => setDialogState(
                                    () => drafts[index] = draft.copyWith(
                                      category: value,
                                      included: false,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: draft.status,
                                  decoration: InputDecoration(
                                    labelText: copy.t('当前状态', 'Current status'),
                                  ),
                                  items: OwnedItemTemplates.statuses
                                      .map(
                                        (value) => DropdownMenuItem(
                                          value: value,
                                          child: Text(
                                            _statusLabel(copy, value),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) => setDialogState(
                                    () => drafts[index] = draft.copyWith(
                                      status: value,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(copy.t('取消', 'Cancel')),
              ),
              FilledButton(
                onPressed: selected.isEmpty
                    ? null
                    : () => Navigator.pop(dialogContext, true),
                child: Text(
                  copy.t(
                    '导入 ${selected.length} 件',
                    'Import ${selected.length} items',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    if (confirmed != true) return;
    final now = DateTime.now();
    final selected = drafts.where((item) => item.included && item.isValid);
    await const OwnedItemStore().saveAll([
      for (final (index, draft) in selected.indexed)
        OwnedItem(
          id: 'owned_import_${now.microsecondsSinceEpoch}_$index',
          name: draft.name.trim(),
          category: draft.category,
          status: draft.status,
          quantity: 1,
          notes: draft.notes,
          purchasePrice: draft.purchasePrice,
          acquiredAt: draft.acquiredAt,
          createdAt: now,
          updatedAt: now,
        ),
    ]);
    if (!mounted) return;
    setState(() {
      data = _load();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          copy.t(
            '已导入 ${selected.length} 件历史购买。',
            'Imported ${selected.length} historical purchases.',
          ),
        ),
      ),
    );
  }

  static String _purchaseImportError(GuardianCopy copy, String error) {
    if (error.contains('missing_name')) {
      return copy.t('缺少商品名称。', 'Missing item name.');
    }
    if (error.contains('invalid_price')) {
      return copy.t('价格格式不正确。', 'Invalid price.');
    }
    return copy.t('日期应使用 YYYY-MM-DD。', 'Use YYYY-MM-DD for the date.');
  }

  static String _categoryLabel(GuardianCopy copy, String category) =>
      switch (category) {
        '数码' => copy.t('数码', 'Tech'),
        '服饰' => copy.t('服饰', 'Clothing'),
        '家居' => copy.t('家居', 'Home'),
        '兴趣收藏' => copy.t('兴趣收藏', 'Hobbies'),
        '运动' => copy.t('运动', 'Sports'),
        '美妆护理' => copy.t('美妆护理', 'Beauty'),
        _ => copy.t('其他', 'Other'),
      };

  static String _statusLabel(GuardianCopy copy, String status) =>
      switch (status) {
        'in_use' => copy.t('仍在使用', 'In use'),
        'backup' => copy.t('备用 / 收藏', 'Backup / collection'),
        'retired' => copy.t('已淘汰 / 转卖', 'Retired / sold'),
        'returned' => copy.t('已退货', 'Returned'),
        _ => copy.t('买过，现状不确定', 'Owned before, status unknown'),
      };

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return GuardianPageFrame(
      title: copy.t('你的习惯', 'Your patterns'),
      subtitle: copy.t('用过一阵子，这里才会有东西。', 'This fills in as you use the app.'),
      child:
          FutureBuilder<
            (
              List<DecisionRecord>,
              List<PersonalPattern>,
              List<OwnedItem>,
              ConsumerProfile?,
            )
          >(
            future: data,
            builder: (context, snapshot) {
              final allRecords = snapshot.data?.$1 ?? const <DecisionRecord>[];
              final patterns = snapshot.data?.$2 ?? const <PersonalPattern>[];
              final manualItems = snapshot.data?.$3 ?? const <OwnedItem>[];
              final profile = snapshot.data?.$4;
              final insights = DecisionInsights.from(allRecords);
              final owned = allRecords.where(
                (record) => record.countsAsPurchased,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        copy.t('我的物品', 'My items'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _importPurchaseList(manualItems),
                        icon: const Icon(Icons.playlist_add),
                        label: Text(copy.t('导入购买清单', 'Import purchases')),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _importOrderScreenshot(manualItems),
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: Text(copy.t('订单截图', 'Order screenshot')),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _editOwnedItem,
                        icon: const Icon(Icons.add),
                        label: Text(copy.t('添加一件', 'Add one')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (manualItems.isEmpty && owned.isEmpty)
                    Text(
                      copy.t(
                        '手动添加，或确认购买后，物品会出现在这里。',
                        'Add items manually, or confirm a purchase.',
                      ),
                    )
                  else
                    ...manualItems.map(
                      (item) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.inventory_2_outlined),
                          title: Text(
                            item.quantity > 1
                                ? '${item.name} ×${item.quantity}'
                                : item.name,
                          ),
                          subtitle: Text(
                            [
                              _categoryLabel(copy, item.category),
                              _statusLabel(copy, item.status),
                              if (item.notes?.isNotEmpty == true) item.notes!,
                            ].join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: PopupMenuButton<String>(
                            tooltip: copy.t('管理物品', 'Manage item'),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editOwnedItem(item);
                              } else if (value == 'delete') {
                                _deleteOwnedItem(item);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(copy.t('修改', 'Edit')),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(copy.t('删除', 'Delete')),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ...owned.map(
                    (record) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: Text(record.itemName),
                        subtitle: Text(
                          [
                            if (record.category?.isNotEmpty == true)
                              record.category!,
                            if (record.tags.isNotEmpty) record.tags.join(' · '),
                            if (record.usageFrequency != null)
                              _HistoryPageState._usageLabel(
                                copy,
                                record.usageFrequency!,
                              ),
                            if (record.satisfaction != null)
                              '${record.satisfaction}/5',
                          ].join(' · '),
                        ),
                        trailing: Text('¥${record.total.toStringAsFixed(2)}'),
                        onTap: () => showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(record.itemName),
                            content: Text(
                              copy.t(
                                '来自 ${record.createdAt.toLocal().toString().substring(0, 16)} 的决策记录。\n'
                                    '决定：${record.userChoice}\n'
                                    '反馈：${record.feedback == null ? '尚未反馈' : _HistoryPageState._feedbackLabel(copy, record.feedback!)}',
                                'From the decision recorded at ${record.createdAt.toLocal().toString().substring(0, 16)}.\n'
                                    'Decision: ${record.userChoice}\n'
                                    'Feedback: ${record.feedback == null ? 'Not added' : _HistoryPageState._feedbackLabel(copy, record.feedback!)}',
                              ),
                            ),
                            actions: [
                              FilledButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(copy.t('关闭', 'Close')),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    copy.t('你的规律', 'Your patterns'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    copy.t(
                      '至少三条已确认购买且填写过购后反馈的同类记录，才会出现候选。只有你确认的内容会参与之后的分析。',
                      'Candidates need at least three confirmed purchases with post-purchase feedback. Only patterns you confirm are used in later analysis.',
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (patterns.isEmpty)
                    Text(copy.t('目前还没有足够证据。', 'Not enough evidence yet.'))
                  else
                    ...patterns.map(
                      (pattern) => Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 8, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    pattern.status == 'confirmed'
                                        ? Icons.check_circle_outline
                                        : Icons.auto_awesome_outlined,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(pattern.text)),
                                ],
                              ),
                              ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                title: Text(
                                  copy.t(
                                    '${pattern.evidence.length} 条依据',
                                    '${pattern.evidence.length} pieces of evidence',
                                  ),
                                ),
                                children: pattern.evidence
                                    .map(
                                      (evidence) => ListTile(
                                        dense: true,
                                        leading: Icon(
                                          evidence.supportsPattern
                                              ? Icons.add_circle_outline
                                              : Icons.remove_circle_outline,
                                        ),
                                        title: Text(evidence.summary),
                                      ),
                                    )
                                    .toList(),
                              ),
                              Wrap(
                                spacing: 8,
                                children: pattern.status == 'candidate'
                                    ? [
                                        FilledButton.tonal(
                                          onPressed: () => _save(
                                            pattern.copyWith(
                                              status: 'confirmed',
                                            ),
                                          ),
                                          child: Text(copy.t('确认', 'Confirm')),
                                        ),
                                        TextButton(
                                          onPressed: () => _save(
                                            pattern.copyWith(status: 'ignored'),
                                          ),
                                          child: Text(copy.t('忽略', 'Ignore')),
                                        ),
                                      ]
                                    : [
                                        TextButton.icon(
                                          onPressed: () => _edit(pattern),
                                          icon: const Icon(Icons.edit_outlined),
                                          label: Text(copy.t('修改', 'Edit')),
                                        ),
                                        TextButton.icon(
                                          onPressed: () => _save(
                                            pattern.copyWith(status: 'ignored'),
                                          ),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          label: Text(copy.t('删除', 'Delete')),
                                        ),
                                      ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          copy.t('消费人格', 'Spending persona'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => _createProfile(allRecords),
                        icon: Icon(
                          profile == null ? Icons.auto_awesome : Icons.refresh,
                        ),
                        label: Text(
                          profile == null
                              ? copy.t('生成', 'Create')
                              : copy.t('重新生成', 'Regenerate'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    copy.t(
                      '有足够的已确认偏好时使用本地证据；否则做四道趣味小题。结果可以修改。',
                      'Uses confirmed local evidence when available, otherwise four fun questions. You can edit the result.',
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (profile == null)
                    Text(copy.t('还没有生成结果。', 'No result yet.'))
                  else ...[
                    RepaintBoundary(
                      key: profileCardKey,
                      child: _ConsumerProfileCard(profile: profile),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            final edited = await _editProfile(profile);
                            if (edited == null) return;
                            await const ConsumerProfileStore().save(edited);
                            if (mounted) setState(() => data = _load());
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(copy.t('修改', 'Edit')),
                        ),
                        FilledButton.icon(
                          onPressed: _saveProfileCard,
                          icon: const Icon(Icons.ios_share_outlined),
                          label: Text(copy.t('保存分享卡', 'Save share card')),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    copy.t('记录概览', 'Decision overview'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  if (!insights.hasEnoughEvidence)
                    Text(
                      copy.t(
                        '有三次以上记录后，再展示统计。',
                        'Statistics appear after at least three decisions.',
                      ),
                    )
                  else
                    Wrap(
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
                    ),
                ],
              );
            },
          ),
    );
  }
}

class _ConsumerProfileCard extends StatelessWidget {
  const _ConsumerProfileCard({required this.profile});

  final ConsumerProfile profile;

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return Semantics(
      label: copy.t('消费人格分享卡', 'Spending persona share card'),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              copy.t('我的消费人格', 'My spending persona'),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              profile.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            for (final trait in profile.traits)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(trait)),
                  ],
                ),
              ),
            const Divider(height: 24),
            Text(
              copy.t('给自己的提醒', 'A reminder'),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(profile.reminder),
            const SizedBox(height: 16),
            Text(
              copy.t(
                ConsumerProfile.disclaimer,
                'For entertainment only; not a psychological or scientific assessment.',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              '购物守护者 · ${ConsumerProfile.projectUrl}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
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
