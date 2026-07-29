part of '../home_shell.dart';

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
    return GuardianPageFrame(
      title: copy.t('稍后再看', 'Later'),
      subtitle: copy.t('到时间了，我们再问一次。', 'We will check in when the time is up.'),
      child: FutureBuilder<List<DecisionRecord>>(
        future: records,
        builder: (context, snapshot) {
          final items = (snapshot.data ?? const [])
              .where(
                (record) =>
                    record.waitUntil != null &&
                    record.currentStatus == 'waiting',
              )
              .toList();
          if (items.isEmpty) {
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
