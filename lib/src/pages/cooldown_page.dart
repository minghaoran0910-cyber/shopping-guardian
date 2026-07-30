part of '../home_shell.dart';

class CooldownPage extends StatefulWidget {
  const CooldownPage({super.key, required this.justOneApiToken});

  final String justOneApiToken;

  @override
  State<CooldownPage> createState() => _CooldownPageState();
}

class _CooldownPageState extends State<CooldownPage> {
  late Future<(List<DecisionRecord>, List<PriceWatch>)> data = _load();
  bool checkingPrices = false;

  Future<(List<DecisionRecord>, List<PriceWatch>)> _load() async => (
    await const DecisionStore().readAll(),
    await const PriceWatchStore().readAll(),
  );

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
      child: FutureBuilder<(List<DecisionRecord>, List<PriceWatch>)>(
        future: data,
        builder: (context, snapshot) {
          final records = snapshot.data?.$1 ?? const <DecisionRecord>[];
          final watches = snapshot.data?.$2 ?? const <PriceWatch>[];
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
                ...watches.map(
                  (watch) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.trending_down),
                      title: Text(watch.itemName),
                      subtitle: Text(
                        [
                          if (!watch.enabled) copy.t('已暂停', 'Paused'),
                          copy.t(
                            '目标 ¥${watch.targetPrice.toStringAsFixed(2)}',
                            'Target ¥${watch.targetPrice.toStringAsFixed(2)}',
                          ),
                          if (watch.lastPrice != null)
                            copy.t(
                              '最近 ¥${watch.lastPrice!.toStringAsFixed(2)}',
                              'Latest ¥${watch.lastPrice!.toStringAsFixed(2)}',
                            ),
                          if (watch.lastError != null)
                            copy.t('上次检查失败', 'Last check failed'),
                        ].join(' · '),
                      ),
                      trailing: PopupMenuButton<String>(
                        tooltip: copy.t('管理价格监测', 'Manage price watch'),
                        onSelected: (value) {
                          if (value == 'toggle') {
                            _toggle(watch, !watch.enabled);
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
                  ),
                ),
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
