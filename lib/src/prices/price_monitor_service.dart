import '../import/justoneapi_client.dart';
import '../import/share_parser.dart';
import '../notifications/local_notification_service.dart';
import 'price_watch.dart';
import 'price_watch_store.dart';

typedef PriceLoader = Future<double?> Function(PriceWatch watch);
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
    this.loader,
    this.alert,
  });

  final PriceWatchStore store;
  final LocalNotificationService notifications;
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
        final price = loader == null
            ? await _loadPrice(watch, token)
            : await loader!(watch);
        if (price == null || price <= 0 || !price.isFinite) {
          throw const JustOneApiException('接口没有返回可用价格');
        }
        final observedAt = checkedAt;
        await store.addObservation(
          PriceSnapshot(
            watchId: watch.id,
            observedAt: observedAt,
            price: price,
            source: 'justoneapi',
          ),
        );
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

  Future<double?> _loadPrice(PriceWatch watch, String token) async {
    final client = JustOneApiClient(token: token);
    final product = switch (watch.platform) {
      ShoppingPlatform.taobao => await client.loadTaobaoProduct(watch.itemId),
      ShoppingPlatform.jd => await client.loadJdProduct(watch.itemId),
      ShoppingPlatform.pinduoduo || ShoppingPlatform.unknown =>
        throw const JustOneApiException('这个平台暂不支持自动查价'),
    };
    return product.price;
  }
}
