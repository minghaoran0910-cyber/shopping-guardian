part of '../home_shell.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  late Future<(List<DecisionRecord>, List<PersonalPattern>)> data = _load();

  Future<(List<DecisionRecord>, List<PersonalPattern>)> _load() async {
    final records = await const DecisionStore().readAll();
    final stored = await const PatternStore().readAll();
    final patterns = const PatternGenerator().merge(
      const PatternGenerator().generate(records),
      stored,
    );
    return (records, patterns);
  }

  Future<void> _save(PersonalPattern pattern) async {
    await const PatternStore().save(pattern);
    if (mounted) setState(() => data = _load());
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

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return GuardianPageFrame(
      title: copy.t('你的习惯', 'Your patterns'),
      subtitle: copy.t('用过一阵子，这里才会有东西。', 'This fills in as you use the app.'),
      child: FutureBuilder<(List<DecisionRecord>, List<PersonalPattern>)>(
        future: data,
        builder: (context, snapshot) {
          final allRecords = snapshot.data?.$1 ?? const <DecisionRecord>[];
          final patterns = snapshot.data?.$2 ?? const <PersonalPattern>[];
          final insights = DecisionInsights.from(allRecords);
          final owned = allRecords.where((record) => record.countsAsPurchased);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                copy.t('我的物品', 'My items'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              if (owned.isEmpty)
                Text(
                  copy.t(
                    '确认购买后，物品会出现在这里。',
                    'Items appear here after you confirm a purchase.',
                  ),
                )
              else
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
                  '至少三条同类记录后才会出现候选。只有你确认的内容会参与之后的分析。',
                  'Candidates need at least three similar records. Only patterns you confirm are used in later analysis.',
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
                                        pattern.copyWith(status: 'confirmed'),
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
                                      icon: const Icon(Icons.delete_outline),
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
