part of '../home_shell.dart';

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

  Future<void> _reload() async {
    final updated = await const DecisionStore().readAll();
    if (mounted) {
      setState(() {
        records = Future.value(updated);
      });
    }
  }

  Future<void> _changeStatus(DecisionRecord record) async {
    final copy = GuardianCopy.of(context);
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(copy.t('现在是什么状态？', 'Current status')),
        children: [
          for (final status in const [
            'waiting',
            'intend_to_buy',
            'purchased',
            'skipped',
            'seeking_alternative',
          ])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, status),
              child: Text(_statusLabel(copy, status)),
            ),
        ],
      ),
    );
    if (selected == null || selected == record.currentStatus) return;
    await const DecisionStore().setStatus(record.id, selected);
    var reminderScheduled = true;
    if (selected == 'purchased') {
      await const LocalNotificationService().cancel(record.id);
      reminderScheduled = await const FeedbackReminderService().schedule(
        decisionId: record.id,
        title: copy.t(
          '回顾一下：${record.itemName}',
          'How is it going: ${record.itemName}',
        ),
      );
    } else {
      if (selected != 'waiting') {
        await const LocalNotificationService().cancel(record.id);
      }
      await const FeedbackReminderService().cancel(record.id);
    }
    if (!reminderScheduled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.t(
              '已标记为购买，但没能创建 7 天后的反馈提醒。',
              'Marked as purchased, but the 7-day feedback reminder could not be created.',
            ),
          ),
        ),
      );
    }
    await _reload();
  }

  Future<void> _feedback(DecisionRecord record) async {
    final value = await showDialog<PurchaseFeedback>(
      context: context,
      builder: (context) => const PurchaseFeedbackDialog(),
    );
    if (value == null) return;
    await const DecisionStore().setStructuredFeedback(record.id, value);
    await const LocalNotificationService().cancel(record.id);
    await const FeedbackReminderService().cancel(record.id);
    await _reload();
  }

  Future<void> _editMetadata(DecisionRecord record) async {
    final copy = GuardianCopy.of(context);
    final category = TextEditingController(text: record.category);
    final tags = TextEditingController(text: record.tags.join('，'));
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(copy.t('分类和标签', 'Category and tags')),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: category,
                decoration: InputDecoration(
                  labelText: copy.t('分类（选填）', 'Category (optional)'),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: tags,
                decoration: InputDecoration(
                  labelText: copy.t('标签（逗号分隔）', 'Tags (comma-separated)'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(copy.t('取消', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(copy.t('保存', 'Save')),
          ),
        ],
      ),
    );
    if (saved == true) {
      await const DecisionStore().setMetadata(
        record.id,
        category: category.text,
        tags: tags.text.split(RegExp(r'[,，]')),
      );
      await _reload();
    }
    category.dispose();
    tags.dispose();
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
                      '后来：${_feedbackLabel(copy, record.feedback!)}',
                      'Later: ${_feedbackLabel(copy, record.feedback!)}',
                    ),
                  ),
                if (record.category?.isNotEmpty == true)
                  Text(
                    copy.t(
                      '分类：${record.category}',
                      'Category: ${record.category}',
                    ),
                  ),
                if (record.tags.isNotEmpty)
                  Text(
                    copy.t(
                      '标签：${record.tags.join('、')}',
                      'Tags: ${record.tags.join(', ')}',
                    ),
                  ),
                if (record.usageFrequency != null)
                  Text(
                    copy.t(
                      '使用频率：${_usageLabel(copy, record.usageFrequency!)}',
                      'Usage: ${_usageLabel(copy, record.usageFrequency!)}',
                    ),
                  ),
                if (record.satisfaction != null)
                  Text(
                    copy.t(
                      '满意度：${record.satisfaction}/5',
                      'Satisfaction: ${record.satisfaction}/5',
                    ),
                  ),
                if (record.regretReason?.isNotEmpty == true)
                  Text(
                    copy.t(
                      '后悔原因：${record.regretReason}',
                      'Regret reason: ${record.regretReason}',
                    ),
                  ),
                const SizedBox(height: 14),
                Text(
                  copy.t('状态时间线', 'Status timeline'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                ...record.effectiveEvents.map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '• ${_statusLabel(copy, event.status)} · '
                      '${event.occurredAt.toLocal().toString().substring(0, 16)}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(record.summary),
                if (record.risk != null || record.confidence != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      copy.t(
                        '风险：${record.risk ?? '—'} · 信心：${record.confidence ?? '—'}',
                        'Risk: ${record.risk ?? '—'} · Confidence: ${record.confidence ?? '—'}',
                      ),
                    ),
                  ),
                if (record.budgetImpact?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      copy.t(
                        '预算影响：${record.budgetImpact}',
                        'Budget impact: ${record.budgetImpact}',
                      ),
                    ),
                  ),
                if (record.alternatives.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    copy.t('当时给出的替代方案', 'Alternatives given'),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  ...record.alternatives.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('• $item'),
                    ),
                  ),
                ],
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
                if (record.referencedPatterns.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    copy.t('本次引用的已确认规律', 'Confirmed patterns used'),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  ...record.referencedPatterns.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('• $item'),
                    ),
                  ),
                ],
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
            onPressed: () => Navigator.pop(context, 'status'),
            child: Text(copy.t('修改状态', 'Change status')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'feedback'),
            child: Text(copy.t('补充反馈', 'Add feedback')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'metadata'),
            child: Text(copy.t('分类标签', 'Category & tags')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(copy.t('关闭', 'Close')),
          ),
        ],
      ),
    );
    if (action == 'status') await _changeStatus(record);
    if (action == 'feedback') await _feedback(record);
    if (action == 'metadata') await _editMetadata(record);
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
        await const FeedbackReminderService().cancel(record.id);
        await _reload();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return GuardianPageFrame(
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in const [
                'all',
                'waiting',
                'intend_to_buy',
                'purchased',
                'skipped',
                'seeking_alternative',
              ])
                FilterChip(
                  label: Text(
                    value == 'all'
                        ? copy.t('全部', 'All')
                        : _statusLabel(copy, value),
                  ),
                  selected: status == value,
                  onSelected: (_) => setState(() => status = value),
                ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<DecisionRecord>>(
            future: records,
            builder: (context, snapshot) {
              final query = search.text.trim().toLowerCase();
              final items = (snapshot.data ?? const [])
                  .where(
                    (record) =>
                        (status == 'all' || _matchesStatus(record, status)) &&
                        (query.isEmpty ||
                            record.itemName.toLowerCase().contains(query)),
                  )
                  .toList();
              if (items.isEmpty) {
                return GuardianEmptyState(
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
                              Text(_statusLabel(copy, record.currentStatus)),
                              if (record.feedback != null)
                                Text(
                                  _feedbackLabel(copy, record.feedback!),
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

  static bool _matchesStatus(DecisionRecord record, String status) {
    if (status == 'purchased') return record.countsAsPurchased;
    if (status == 'skipped' &&
        record.currentStatus == 'feedback_completed' &&
        record.feedback == 'not_bought') {
      return true;
    }
    return record.currentStatus == status;
  }

  static String _statusLabel(GuardianCopy copy, String status) =>
      switch (status) {
        'analyzed' => copy.t('已分析', 'Analyzed'),
        'waiting' => copy.t('冷静中', 'Waiting'),
        'intend_to_buy' => copy.t('打算购买', 'Planning to buy'),
        'purchased' => copy.t('已购买', 'Purchased'),
        'skipped' => copy.t('已放弃', 'Skipped'),
        'seeking_alternative' => copy.t('寻找替代', 'Finding alternatives'),
        'feedback_completed' => copy.t('已反馈', 'Feedback added'),
        _ => status,
      };

  static String _feedbackLabel(GuardianCopy copy, String feedback) =>
      switch (feedback) {
        'satisfied' => copy.t('满意', 'Satisfied'),
        'regretted' => copy.t('后悔', 'Regretted'),
        'not_bought' => copy.t('没有购买', 'Not bought'),
        _ => feedback,
      };

  static String _usageLabel(GuardianCopy copy, String usage) => switch (usage) {
    'not_used' => copy.t('还没用过', 'Not used yet'),
    'rarely' => copy.t('很少使用', 'Rarely'),
    'monthly' => copy.t('每月几次', 'A few times a month'),
    'weekly' => copy.t('每周几次', 'A few times a week'),
    'daily' => copy.t('几乎每天', 'Almost daily'),
    _ => usage,
  };
}
