part of '../home_shell.dart';

class CooldownPage extends StatefulWidget {
  const CooldownPage({super.key, required this.justOneApiToken});

  final String justOneApiToken;

  @override
  State<CooldownPage> createState() => _CooldownPageState();
}

class _CooldownPageState extends State<CooldownPage> {
  late Future<_CooldownData> data = _load();
  bool checkingPrices = false;

  Future<_CooldownData> _load() async {
    final records = await const DecisionStore().readAll();
    final watches = await const PriceWatchStore().readAll();
    final histories = await Future.wait(
      watches.map((watch) => const PriceWatchStore().history(watch.id)),
    );
    final evidence = <String, PriceEvidence>{};
    final now = DateTime.now();
    for (var index = 0; index < watches.length; index++) {
      final watch = watches[index];
      evidence[watch.id] = PriceEvidence.from(histories[index], now: now);
    }
    return _CooldownData(
      records: records,
      watches: watches,
      evidence: evidence,
    );
  }

  Future<void> _checkPrices() async {
    final copy = GuardianCopy.of(context);
    if (widget.justOneApiToken.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            copy.t(
              '先在设置里填写 JustOneAPI，才能查询真实价格。',
              'Add JustOneAPI in Settings to check real prices.',
            ),
          ),
        ),
      );
      return;
    }
    setState(() => checkingPrices = true);
    final result = await const PriceMonitorService().checkAll(
      token: widget.justOneApiToken,
    );
    if (!mounted) return;
    setState(() {
      checkingPrices = false;
      data = _load();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          copy.t(
            '已检查 ${result.checked} 件，${result.reachedTarget} 件到达目标价'
                '${result.failed == 0 ? '' : '，${result.failed} 件失败'}。',
            'Checked ${result.checked}; ${result.reachedTarget} reached the target'
                '${result.failed == 0 ? '' : '; ${result.failed} failed'}.',
          ),
        ),
      ),
    );
  }

  Future<void> _toggle(PriceWatch watch, bool enabled) async {
    await const PriceWatchStore().save(watch.copyWith(enabled: enabled));
    if (mounted) {
      setState(() {
        data = _load();
      });
    }
  }

  Future<void> _editTarget(PriceWatch watch) async {
    final copy = GuardianCopy.of(context);
    final controller = TextEditingController(
      text: watch.targetPrice.toStringAsFixed(2),
    );
    final value = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(copy.t('修改目标价', 'Change target price')),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: copy.t('目标价', 'Target price'),
            prefixText: '¥ ',
            helperText: copy.t(
              '达到或低于这个价格时提醒你考虑下单。',
              'We will alert you when the price reaches this target.',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(copy.t('取消', 'Cancel')),
          ),
          FilledButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text.trim());
              if (parsed == null || parsed <= 0 || !parsed.isFinite) return;
              Navigator.pop(context, parsed);
            },
            child: Text(copy.t('保存', 'Save')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    await const PriceWatchStore().save(
      watch.copyWith(
        targetPrice: value,
        clearLastPrice: true,
        clearNotification: true,
        clearLastError: true,
      ),
    );
    if (widget.justOneApiToken.trim().isNotEmpty) {
      await const PriceMonitorService().checkAll(token: widget.justOneApiToken);
    }
    if (mounted) setState(() => data = _load());
  }

  Future<void> _deleteWatch(PriceWatch watch) async {
    await const PriceWatchStore().delete(watch.id);
    await const LocalNotificationService().cancel('${watch.id}_price');
    if (mounted) {
      setState(() {
        data = _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return GuardianPageFrame(
      title: copy.t('稍后再看', 'Later'),
      subtitle: copy.t(
        '冷静一下，也可以等到合适的价格。',
        'Wait it out or watch for a better price.',
      ),
      actions: [
        FilledButton.tonalIcon(
          onPressed: checkingPrices ? null : _checkPrices,
          icon: checkingPrices
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          label: Text(copy.t('检查价格', 'Check prices')),
        ),
      ],
      child: FutureBuilder<_CooldownData>(
        future: data,
        builder: (context, snapshot) {
          final records = snapshot.data?.records ?? const <DecisionRecord>[];
          final watches = snapshot.data?.watches ?? const <PriceWatch>[];
          final evidence =
              snapshot.data?.evidence ?? const <String, PriceEvidence>{};
          final items = records
              .where(
                (record) =>
                    record.waitUntil != null &&
                    record.currentStatus == 'waiting',
              )
              .toList();
          if (items.isEmpty && watches.isEmpty) {
            return GuardianEmptyState(
              icon: Icons.hourglass_empty_rounded,
              title: copy.t('这里还空着', 'Nothing here yet'),
              description: copy.t(
                '决定晚点再买的商品会放在这里。',
                'Items you decide to wait on will show up here.',
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (watches.isNotEmpty) ...[
                Text(
                  copy.t('价格监测', 'Price watches'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                ...watches.map((watch) {
                  final prices =
                      evidence[watch.id] ??
                      const PriceEvidence(trustedCount: 0);
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.trending_down),
                      title: Text(watch.itemName),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _PriceEvidenceSummary(
                          watch: watch,
                          evidence: prices,
                          copy: copy,
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        tooltip: copy.t('管理价格监测', 'Manage price watch'),
                        onSelected: (value) {
                          if (value == 'toggle') {
                            _toggle(watch, !watch.enabled);
                          } else if (value == 'target') {
                            _editTarget(watch);
                          } else if (value == 'delete') {
                            _deleteWatch(watch);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'toggle',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                watch.enabled
                                    ? Icons.pause_outlined
                                    : Icons.play_arrow_outlined,
                              ),
                              title: Text(
                                watch.enabled
                                    ? copy.t('暂停监测', 'Pause watch')
                                    : copy.t('继续监测', 'Resume watch'),
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'target',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.price_change_outlined),
                              title: Text(
                                copy.t('修改目标价', 'Change target price'),
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.delete_outline),
                              title: Text(copy.t('停止并删除', 'Stop and delete')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
              if (items.isNotEmpty) ...[
                Text(
                  copy.t('冷静期', 'Cooling-off'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
              ],
              ...items.map((record) {
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
              }),
            ],
          );
        },
      ),
    );
  }
}

class _CooldownData {
  const _CooldownData({
    required this.records,
    required this.watches,
    required this.evidence,
  });

  final List<DecisionRecord> records;
  final List<PriceWatch> watches;
  final Map<String, PriceEvidence> evidence;
}

class _PriceEvidenceSummary extends StatelessWidget {
  const _PriceEvidenceSummary({
    required this.watch,
    required this.evidence,
    required this.copy,
  });

  final PriceWatch watch;
  final PriceEvidence evidence;
  final GuardianCopy copy;

  @override
  Widget build(BuildContext context) {
    final current = evidence.current;
    final reference = evidence.reference;
    final recentLow = evidence.recentLow;
    final manipulation = evidence.manipulation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          [
            if (!watch.enabled) copy.t('已暂停', 'Paused'),
            copy.t(
              '目标 ¥${watch.targetPrice.toStringAsFixed(2)}',
              'Target ¥${watch.targetPrice.toStringAsFixed(2)}',
            ),
            if (watch.lastError != null)
              copy.t('上次检查失败', 'Last check failed'),
          ].join(' · '),
        ),
        const SizedBox(height: 8),
        // Sparkline
        if (evidence.recentHistory.length >= 2) ...[
          PriceSparkline(snapshots: evidence.recentHistory),
          const SizedBox(height: 6),
        ],
        // Manipulation warning
        if (manipulation.detected) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    copy.t(
                      '这个商品在促销前先涨价了 ¥${manipulation.promotionPrice?.toStringAsFixed(0)}，'
                      '现在"降"回 ¥${manipulation.currentPrice?.toStringAsFixed(0)}，'
                      '和之前 ¥${manipulation.prePromotionPrice?.toStringAsFixed(0)} 差不多。'
                      '所谓的折扣可能不是真的便宜。',
                      'This item was raised to ¥${manipulation.promotionPrice?.toStringAsFixed(0)} before the sale, '
                      'then "dropped" to ¥${manipulation.currentPrice?.toStringAsFixed(0)} — '
                      'about the same as the earlier ¥${manipulation.prePromotionPrice?.toStringAsFixed(0)}. '
                      'The "discount" may not be a real deal.',
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
        _PriceEvidenceLine(
          label: copy.t('当前价', 'Current'),
          snapshot: current,
          unknown: copy.t(
            '不知道（缺少 24 小时内可信报价）',
            'Unknown (no trusted quote in 24h)',
          ),
        ),
        _PriceEvidenceLine(
          label: copy.t('参考价（上次记录）', 'Reference (previous quote)'),
          snapshot: reference,
          unknown: copy.t(
            '不知道（还没有上一条可信报价）',
            'Unknown (no previous trusted quote)',
          ),
        ),
        _PriceEvidenceLine(
          label: copy.t('本机 30 天低价', '30-day low on this device'),
          snapshot: recentLow,
          unknown: copy.t(
            '不知道（至少需要两次、间隔 6 小时的可信记录）',
            'Unknown (needs two trusted quotes at least 6h apart)',
          ),
        ),
      ],
    );
  }
}

class _PriceEvidenceLine extends StatelessWidget {
  const _PriceEvidenceLine({
    required this.label,
    required this.snapshot,
    required this.unknown,
  });

  final String label;
  final PriceSnapshot? snapshot;
  final String unknown;

  @override
  Widget build(BuildContext context) {
    final value = snapshot;
    if (value == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Text('$label：$unknown'),
      );
    }
    final local = value.observedAt.toLocal();
    final time =
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        '$label：¥${value.price.toStringAsFixed(2)} · '
        '${_sourceName(value.source)} · $time',
      ),
    );
  }

  String _sourceName(String source) => switch (source) {
        'justoneapi' => 'JustOneAPI',
        _ => source,
      };
}
