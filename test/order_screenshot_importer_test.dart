import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/import/cart_screenshot_importer.dart';
import 'package:shopping_guardian/src/import/order_screenshot_importer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pairs order item prices while excluding totals and order controls', () {
    final drafts = OrderScreenshotParser.parse([
      '淘宝',
      '交易成功',
      'Sony WH-1000XM5 无线降噪耳机',
      '颜色分类：黑色',
      '¥ 1999.00',
      '运费 ¥10.00',
      '实付款 ¥2009.00',
      '查看物流',
      '再次购买',
    ]);

    expect(drafts, hasLength(1));
    expect(drafts.single.name, 'Sony WH-1000XM5 无线降噪耳机');
    expect(drafts.single.purchasePrice, 1999);
    expect(drafts.single.status, 'unknown');
    expect(drafts.single.category, '其他');
  });

  test('parses multiple products and marks only nearby returned orders', () {
    final drafts = OrderScreenshotParser.parse([
      '退款成功',
      '松下有线耳机 RP-HS47',
      '¥79',
      '订单编号 123456',
      '交易成功',
      '水月雨 MM3A 桌面音箱',
      '¥699.90',
      '合计 ¥778.90',
    ]);

    expect(drafts, hasLength(2));
    expect(drafts.first.status, 'returned');
    expect(drafts.last.status, 'unknown');
  });

  test('does not treat a bare quantity as a price', () {
    final drafts = OrderScreenshotParser.parse([
      '交易成功',
      '测试商品',
      '1',
      '实付款 ¥9.90',
    ]);

    expect(drafts, isEmpty);
  });

  test(
    'uses the existing local OCR picker and distinguishes cancellation',
    () async {
      const channel = MethodChannel('test/order-ocr');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            channel,
            (_) async => ['交易成功', '测试键盘', '¥399', '实付款 ¥399'],
          );
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );

      final result = await OrderScreenshotImporter(
        ocr: const CartScreenshotImporter(channel: channel),
      ).pickAndRecognize();
      expect(result.wasCancelled, isFalse);
      expect(result.recognizedLineCount, 4);
      expect(result.drafts.single.name, '测试键盘');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) async => null);
      final cancelled = await OrderScreenshotImporter(
        ocr: const CartScreenshotImporter(channel: channel),
      ).pickAndRecognize();
      expect(cancelled.wasCancelled, isTrue);
    },
  );
}
