import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shopping_guardian/src/import/cart_screenshot_importer.dart';
import 'package:shopping_guardian/src/import/share_parser.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('extracts Taobao cart products from OCR lines', () {
    final items = CartScreenshotParser.parse([
      '购物车（30）',
      '天猫 天风音像专营店',
      '原装正版 山下达郎专辑 FOR YOU',
      '满60减3 退货宝 假一赔四',
      '店铺优惠后 ¥378 ¥398 x1',
      '原装正版 山下达郎专辑 BIG WAVE',
      '补贴17元 满60减3',
      '平台加补后 ¥323 ¥360 x1',
      '天猫 akko旗舰店',
      'AKKO 灵犀Linx68 昼光-云朵轴',
      '超级立减300元 退货宝 7天价保',
      '店铺优惠后 ¥699 ¥999 x1',
      '合计：¥0',
      '结算',
    ]);

    expect(items, hasLength(3));
    expect(items.first.platform, ShoppingPlatform.taobao);
    expect(items.first.title, contains('FOR YOU'));
    expect(items.first.price, 378);
    expect(items[1].price, 323);
    expect(items.last.title, contains('Linx68'));
    expect(items.last.price, 699);
  });

  test('detects JD screenshots with the same parser', () {
    final items = CartScreenshotParser.parse([
      '京东购物车',
      '京东自营店',
      'vivo X300 蔡司2亿超级主摄',
      '到手价 ¥3999 x2',
    ]);

    expect(items.single.platform, ShoppingPlatform.jd);
    expect(items.single.quantity, 2);
    expect(items.single.price, 3999);
  });

  test('accepts a yuan sign recognized as Y on Android', () {
    final items = CartScreenshotParser.parse([
      '淘宝 购物车',
      '天猫 天风音像专营店',
      '原装正版 山下达郎专辑 BIG WAVE LP黑胶唱片',
      'Y323 x1',
      '天猫 akko旗舰店',
      'AKKO 灵犀 Linx68 三模机械键盘',
      'Y699 x1',
    ]);

    expect(items, hasLength(2));
    expect(items.first.price, 323);
    expect(items.last.price, 699);
  });

  test('extracts a product detail when price appears before the title', () {
    final items = CartScreenshotParser.parse([
      '14:08',
      'Gooey Goof',
      '1/5',
      '¥249',
      '已售 32',
      'Me and My Sandcastle 《Love is Waiting》12',
      '寸LP彩胶限量500张',
      '送礼',
      '店铺一年回头客3千',
      '预计6小时内发货，明天送达',
      '7天无理由退货',
      '加入购物车',
      '立即购买',
    ]);

    expect(items, hasLength(1));
    expect(items.single.price, 249);
    expect(items.single.title, contains('Love is Waiting'));
    expect(items.single.title, contains('限量500张'));
    expect(items.single.url.host, 'product-screenshot');
  });

  test('accepts a detail price whose currency symbol was dropped by OCR', () {
    final items = CartScreenshotParser.parse([
      '1/5',
      '249',
      '已售32',
      'Me and My Sandcastle Love is Waiting',
      '12寸LP彩胶限量500张',
      '加入购物车',
      '立即购买',
    ]);

    expect(items.single.price, 249);
    expect(items.single.title, contains('Love is Waiting'));
  });

  test(
    'detail parsing tolerates spaced sales text and missing action labels',
    () {
      final items = CartScreenshotParser.parse([
        '1/5',
        r'$ 249',
        '已 售 32',
        'Me and My Sandcastle Love is Waiting 12',
        '寸 LP 彩胶限量 500 张',
        '店铺评分超过 85% 同行',
        '7 天无理由退货',
      ]);

      expect(items.single.price, 249);
      expect(items.single.title, contains('Love is Waiting'));
      expect(items.single.title, contains('500 张'));
    },
  );

  test('extracts detail when ML Kit returns sales after the title block', () {
    final items = CartScreenshotParser.parse([
      '1/5',
      '¥249',
      'Me and My Sandcastle 《Love is Waiting》12',
      '寸LP彩胶限量500张',
      '已售 32',
      '送礼',
      '店铺一年回头客3千',
      '店铺评分超过85%同行',
      '快递：10.00',
      '加入购物车',
      '立即购买',
    ]);

    expect(items, hasLength(1));
    expect(items.single.price, 249);
    expect(
      items.single.title,
      'Me and My Sandcastle 《Love is Waiting》12 寸LP彩胶限量500张',
    );
  });

  test('extracts the real Android ML Kit block order without cover text', () {
    final items = CartScreenshotParser.parse([
      '14:08 品',
      '249',
      '良40',
      'AND ME',
      'LP彩肢限量500张',
      '500/1',
      '1/5',
      'ハPm20 56.1 564会',
      'KB/s ll ll',
      'Me and My Sandcastle 《Love is Waiting》12',
      '店铺一年回头客3千>店铺评分超过85%同行',
      '87天无理由退货极速退款',
      'G预计6小时内发货,明天送达北京 快递:10.00',
      '已售32',
      '|加入购物车',
      '立即购买',
    ]);

    expect(items, hasLength(1));
    expect(items.single.price, 249);
    expect(items.single.title, 'Me and My Sandcastle 《Love is Waiting》12');
  });

  test('does not replace a bare product price with a later shipping fee', () {
    final items = CartScreenshotParser.parse([
      '249',
      '测试商品完整名称',
      '店铺评分超过85%同行',
      '快递 ¥10.00',
      '已售32',
      '加入购物车',
      '立即购买',
    ]);

    expect(items.single.price, 249);
    expect(items.single.title, '测试商品完整名称');
  });

  test(
    'detailed import reports OCR line count without retaining raw text',
    () async {
      const channel = MethodChannel('test/cart-ocr-details');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            expect(call.method, 'pickAndRecognize');
            return ['249', '已售32', '测试商品名称', '加入购物车', '立即购买'];
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );

      final result = await const CartScreenshotImporter(
        channel: channel,
      ).pickAndRecognizeDetailed();

      expect(result.recognizedLineCount, 5);
      expect(result.items.single.title, '测试商品名称');
      expect(result.wasCancelled, isFalse);
    },
  );

  test('detailed import distinguishes a cancelled picker', () async {
    const channel = MethodChannel('test/cart-ocr-cancelled');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => null);
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    final result = await const CartScreenshotImporter(
      channel: channel,
    ).pickAndRecognizeDetailed();

    expect(result.wasCancelled, isTrue);
    expect(result.recognizedLineCount, 0);
    expect(result.items, isEmpty);
  });
}
