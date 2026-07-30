import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopping_guardian/src/data/guardian_database.dart';
import 'package:shopping_guardian/src/import/share_parser.dart';
import 'package:shopping_guardian/src/notifications/local_notification_service.dart';
import 'package:shopping_guardian/src/prices/price_monitor_service.dart';
import 'package:shopping_guardian/src/prices/price_provider.dart';
import 'package:shopping_guardian/src/prices/price_watch.dart';
import 'package:shopping_guardian/src/prices/price_watch_store.dart';

class _RecordingPriceProvider implements PriceProvider {
  PriceWatch? receivedWatch;
  String? receivedCredential;
  DateTime? receivedObservedAt;

  @override
  String get id => 'recording-provider';

  @override
  bool supports(PriceWatch watch) => true;

  @override
  Future<PriceQuote> fetch(
    PriceWatch watch, {
    required String credential,
    required DateTime observedAt,
  }) async {
    receivedWatch = watch;
    receivedCredential = credential;
    receivedObservedAt = observedAt;
    return PriceQuote(
      price: 399,
      observedAt: observedAt,
      source: id,
      matchConfidence: 0.85,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GuardianDatabase database;
  late PriceWatchStore store;

  PriceQuote quote(
    double price,
    DateTime observedAt, {
    double confidence = 0.9,
  }) => PriceQuote(
    price: price,
    observedAt: observedAt,
    source: 'test-provider',
    matchConfidence: confidence,
  );

  setUp(() {
    database = GuardianDatabase.memory();
    store = PriceWatchStore(database: database);
  });

  tearDown(() => database.close());

  test('extracts stable Taobao and JD item ids only', () {
    expect(
      PriceWatchIdentity.itemId(
        SharedShoppingItem(
          platform: ShoppingPlatform.taobao,
          kind: ShareKind.product,
          url: Uri.parse('https://item.taobao.com/item.htm?id=123456789'),
        ),
      ),
      '123456789',
    );
    expect(
      PriceWatchIdentity.itemId(
        SharedShoppingItem(
          platform: ShoppingPlatform.jd,
          kind: ShareKind.product,
          url: Uri.parse('https://item.m.jd.com/product/987654321.html'),
        ),
      ),
      '987654321',
    );
    expect(
      PriceWatchIdentity.supports(
        SharedShoppingItem(
          platform: ShoppingPlatform.pinduoduo,
          kind: ShareKind.product,
          url: Uri.parse('https://mobile.yangkeduo.com/goods.html?goods_id=1'),
        ),
      ),
      isFalse,
    );
  });

  test(
    'records real observations and alerts only on a target crossing',
    () async {
      final now = DateTime(2026, 7, 30, 10);
      await store.save(
        PriceWatch(
          id: 'watch-1',
          decisionId: 'decision-1',
          itemName: '测试耳机',
          platform: ShoppingPlatform.jd,
          itemId: '123456789',
          productUrl: Uri.parse('https://item.jd.com/123456789.html'),
          targetPrice: 800,
          createdAt: now,
          lastPrice: 900,
        ),
      );
      var currentPrice = 799.0;
      final alerts = <String>[];
      final service = PriceMonitorService(
        store: store,
        loader: (_) async => quote(currentPrice, now),
        alert: ({required id, required title, required at}) async {
          alerts.add('$id:$title');
          return true;
        },
      );

      final first = await service.checkAll(token: 'test', now: now);
      expect(first.reachedTarget, 1);
      expect(alerts, hasLength(1));
      expect(await store.history('watch-1'), hasLength(1));

      final second = await service.checkAll(
        token: 'test',
        now: now.add(const Duration(hours: 1)),
      );
      expect(second.reachedTarget, 0);
      expect(alerts, hasLength(1));

      currentPrice = 850;
      await service.checkAll(
        token: 'test',
        now: now.add(const Duration(hours: 2)),
      );
      currentPrice = 790;
      final crossedAgain = await service.checkAll(
        token: 'test',
        now: now.add(const Duration(hours: 3)),
      );
      expect(crossedAgain.reachedTarget, 1);
      expect(alerts, hasLength(2));
      expect(await store.history('watch-1'), hasLength(4));
    },
  );

  test('stores a failed check without inventing a price', () async {
    final now = DateTime(2026, 7, 30, 10);
    await store.save(
      PriceWatch(
        id: 'watch-2',
        decisionId: 'decision-2',
        itemName: '测试键盘',
        platform: ShoppingPlatform.taobao,
        itemId: '123456789',
        productUrl: Uri.parse('https://item.taobao.com/item.htm?id=123456789'),
        targetPrice: 300,
        createdAt: now,
      ),
    );
    final result = await PriceMonitorService(
      store: store,
      loader: (_) async => null,
    ).checkAll(token: 'test', now: now);

    expect(result.failed, 1);
    expect(await store.history('watch-2'), isEmpty);
    final watch = (await store.readAll()).single;
    expect(watch.lastPrice, isNull);
    expect(watch.lastError, isNotNull);
  });

  test(
    'alerts on the first check when the target is already reached',
    () async {
      final now = DateTime(2026, 7, 30, 10);
      await store.save(
        PriceWatch(
          id: 'watch-first',
          decisionId: 'decision-first',
          itemName: '测试唱片',
          platform: ShoppingPlatform.taobao,
          itemId: '123456789',
          productUrl: Uri.parse(
            'https://item.taobao.com/item.htm?id=123456789',
          ),
          targetPrice: 250,
          createdAt: now,
          lastPrice: 249,
        ),
      );
      var alerts = 0;
      final result = await PriceMonitorService(
        store: store,
        loader: (_) async => quote(249, now),
        alert: ({required id, required title, required at}) async {
          alerts++;
          return true;
        },
      ).checkAll(token: 'test', now: now);

      expect(result.reachedTarget, 1);
      expect(alerts, 1);
    },
  );

  test('can skip recently checked watches on automatic checks', () async {
    final now = DateTime(2026, 7, 30, 10);
    await store.save(
      PriceWatch(
        id: 'watch-fresh',
        decisionId: 'decision-fresh',
        itemName: '测试音箱',
        platform: ShoppingPlatform.jd,
        itemId: '123456789',
        productUrl: Uri.parse('https://item.jd.com/123456789.html'),
        targetPrice: 500,
        createdAt: now,
        lastCheckedAt: now.subtract(const Duration(hours: 1)),
      ),
    );
    var calls = 0;
    final result = await PriceMonitorService(
      store: store,
      loader: (_) async {
        calls++;
        return quote(499, now);
      },
    ).checkAll(token: 'test', now: now, minimumAge: const Duration(hours: 6));

    expect(result.checked, 0);
    expect(calls, 0);
  });

  test(
    'stores low-confidence quotes but never alerts or trusts them',
    () async {
      final now = DateTime(2026, 7, 30, 10);
      await store.save(
        PriceWatch(
          id: 'watch-low-confidence',
          decisionId: 'decision-low-confidence',
          itemName: '测试耳机',
          platform: ShoppingPlatform.jd,
          itemId: '123456789',
          productUrl: Uri.parse('https://item.jd.com/123456789.html'),
          targetPrice: 800,
          createdAt: now,
          lastPrice: 900,
        ),
      );
      var alerts = 0;
      final result = await PriceMonitorService(
        store: store,
        loader: (_) async => quote(100, now, confidence: 0.4),
        alert: ({required id, required title, required at}) async {
          alerts++;
          return true;
        },
      ).checkAll(token: 'test', now: now);

      expect(result.failed, 1);
      expect(result.reachedTarget, 0);
      expect(alerts, 0);
      final history = await store.history('watch-low-confidence');
      expect(history.single.price, 100);
      expect(history.single.matchConfidence, 0.4);
      final watch = (await store.readAll()).single;
      expect(watch.lastPrice, 900);
      expect(watch.lastError, contains('置信度'));
    },
  );

  test('uses an injected provider without changing monitoring logic', () async {
    final now = DateTime(2026, 7, 30, 10);
    final watch = PriceWatch(
      id: 'watch-provider',
      decisionId: 'decision-provider',
      itemName: '测试商品',
      platform: ShoppingPlatform.unknown,
      itemId: 'provider-item',
      productUrl: Uri.parse('https://example.com/provider-item'),
      targetPrice: 300,
      createdAt: now,
    );
    await store.save(watch);
    final provider = _RecordingPriceProvider();

    final result = await PriceMonitorService(
      store: store,
      provider: provider,
    ).checkAll(token: 'provider-key', now: now);

    expect(result.checked, 1);
    expect(provider.receivedWatch?.id, watch.id);
    expect(provider.receivedCredential, 'provider-key');
    expect(provider.receivedObservedAt, now);
    final history = await store.history(watch.id);
    expect(history.single.source, provider.id);
    expect(history.single.matchConfidence, 0.85);
  });

  test('does not mark a rejected system notification as delivered', () async {
    final now = DateTime(2026, 7, 30, 10);
    await store.save(
      PriceWatch(
        id: 'watch-rejected-alert',
        decisionId: 'decision-rejected-alert',
        itemName: '测试耳机',
        platform: ShoppingPlatform.jd,
        itemId: '123456789',
        productUrl: Uri.parse('https://item.jd.com/123456789.html'),
        targetPrice: 800,
        createdAt: now,
        lastPrice: 900,
      ),
    );
    final service = PriceMonitorService(
      store: store,
      loader: (_) async => quote(799, now),
      alert: ({required id, required title, required at}) async => false,
    );

    final result = await service.checkAll(token: 'test', now: now);
    final watch = (await store.readAll()).single;

    expect(result.failed, 1);
    expect(result.reachedTarget, 0);
    expect(watch.notifiedAt, isNull);
    expect(watch.lastPrice, 900);
    expect(watch.lastError, contains('没有创建价格提醒'));
  });

  test(
    'marks target alerts as price notifications for the native UI',
    () async {
      const channel = MethodChannel('test/price-notification-kind');
      MethodCall? invocation;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            invocation = call;
            return true;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      final now = DateTime(2026, 7, 30, 10);
      await store.save(
        PriceWatch(
          id: 'watch-price-kind',
          decisionId: 'decision-price-kind',
          itemName: '测试耳机',
          platform: ShoppingPlatform.jd,
          itemId: '123456789',
          productUrl: Uri.parse('https://item.jd.com/123456789.html'),
          targetPrice: 800,
          createdAt: now,
          lastPrice: 900,
        ),
      );

      final result = await PriceMonitorService(
        store: store,
        notifications: const LocalNotificationService(channel: channel),
        loader: (_) async => quote(799, now),
      ).checkAll(token: 'test', now: now);

      expect(result.reachedTarget, 1);
      expect(invocation?.method, 'schedule');
      expect(invocation?.arguments, {
        'id': 'watch-price-kind_price',
        'title': '测试耳机 已到 ¥799.00',
        'timestamp': now.add(const Duration(seconds: 1)).millisecondsSinceEpoch,
        'kind': 'price',
      });
    },
  );
}
