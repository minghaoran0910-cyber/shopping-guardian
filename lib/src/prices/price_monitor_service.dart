import '../notifications/local_notification_service.dart';
import 'price_provider.dart';
import 'price_watch.dart';
import 'price_watch_store.dart';

typedef PriceLoader = Future<PriceQuote?> Function(PriceWatch watch);
typedef PriceAlert =
    Future<bool> Function({
      required String id,
      required String title,
      required DateTime at,
    });

class PriceCheckResult {
  const PriceCheckResult({
    required this.checked,
    required this.reachedTarget,
    required this.failed,
  });

  final int checked;
  final int reachedTarget;
  final int failed;
}

class PriceMonitorService {
  const PriceMonitorService({
    this.store = const PriceWatchStore(),
    this.notifications = const LocalNotificationService(),
    this.provider = const JustOneApiPriceProvider(),
    this.loader,
    this.alert,
  });

  final PriceWatchStore store;
  final LocalNotificationService notifications;
  final PriceProvider provider;
  final PriceLoader? loader;
  final PriceAlert? alert;

  Future<PriceCheckResult> checkAll({
    required String token,
    DateTime? now,
    Duration? minimumAge,
  }) async {
    if (token.trim().isEmpty) {
      return const PriceCheckResult(checked: 0, reachedTarget: 0, failed: 0);
    }
    final watches = await store.readAll();
    var checked = 0;
    var reached = 0;
    var failed = 0;
    final checkedAt = now ?? DateTime.now();
    for (final watch in watches.where(
      (watch) =>
          watch.enabled &&
          (minimumAge == null ||
              watch.lastCheckedAt == null ||
              checkedAt.difference(watch.lastCheckedAt!) >= minimumAge),
    )) {
      try {
        final quote = loader == null
            ? await provider.fetch(
                watch,
                credential: token,
                observedAt: checkedAt,
              )
            : await loader!(watch);
        if (quote == null ||
            quote.price <= 0 ||
            !quote.price.isFinite ||
            quote.source.trim().isEmpty ||
            !quote.matchConfidence.isFinite ||
            quote.matchConfidence < 0 ||
            quote.matchConfidence > 1) {
          throw StateError('价格提供者没有返回有效报价');
        }
        final price = quote.price;
        final observedAt = quote.observedAt;
        await store.addObservation(
          PriceSnapshot(
            watchId: watch.id,
            observedAt: observedAt,
            price: price,
            source: quote.source,
            matchConfidence: quote.matchConfidence,
          ),
        );
        if (quote.matchConfidence < 0.8) {
          throw StateError('商品匹配置信度不足，未用于提醒');
        }
        final reachedNow = price <= watch.targetPrice;
        final crossedTarget =
            reachedNow &&
            watch.notifiedAt == null &&
            (watch.lastCheckedAt == null ||
                watch.lastPrice == null ||
                watch.lastPrice! > watch.targetPrice);
        if (crossedTarget) {
          final notify = alert ?? notifications.schedule;
          final scheduled = await notify(
            id: '${watch.id}_price',
            title: '${watch.itemName} 已到 ¥${price.toStringAsFixed(2)}',
            at: observedAt.add(const Duration(seconds: 1)),
          );
          if (!scheduled) {
            throw StateError('系统没有创建价格提醒');
          }
          reached++;
        }
        await store.save(
          watch.copyWith(
            lastPrice: price,
            lastCheckedAt: observedAt,
            notifiedAt: crossedTarget ? observedAt : null,
            clearNotification: !reachedNow,
            clearLastError: true,
          ),
        );
        checked++;
      } on Object catch (error) {
        failed++;
        await store.save(
          watch.copyWith(lastCheckedAt: checkedAt, lastError: '$error'),
        );
      }
    }
    return PriceCheckResult(
      checked: checked,
      reachedTarget: reached,
      failed: failed,
    );
  }
}
