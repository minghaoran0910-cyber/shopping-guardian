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

  test('extracts products from the supplied Taobao cart OCR', () {
    final items = CartScreenshotParser.parse([
      '购物车（32）',
      '国际 天猫国际自营全球超级店＞',
      '狂暑季【自营】正版 披头士 Th',
      '官方立减71元',
      '88VIP 9.5折',
      '退货宝',
      '平台加补后¥490.2 ¥587',
      '×1',
      '明细＞',
      '天猫 天风音像专营店〉',
      '披头士专辑 THE BEATLES Abb',
      '官方立减59元 退货宝 假一赔四',
      '店铺优惠后¥431 ¥490',
      '×1',
      '超级立减正版 威肯专辑 盆栽哥',
      '超级立减32元',
      '退货宝',
      '店铺优惠后¥288',
      '¥320',
      '×1',
      '狂暑季星际牛仔 COWBOY BEB',
      '消费券',
      '官方立减48元 退货宝',
      '平台加补后¥326 ¥399比加购降33',
      '×1',
      '合计：¥0',
      '结算',
    ]);

    expect(items, hasLength(4));
    expect(items.map((item) => item.price), [490.2, 431, 288, 326]);
    expect(items[1].title, contains('THE BEATLES'));
    expect(items[2].title, contains('威肯专辑'));
    expect(items[3].title, contains('COWBOY BEB'));
  });

  test('extracts products from the supplied JD cart OCR', () {
    final items = CartScreenshotParser.parse([
      '购物车（2）',
      '水月雨旗舰店〉',
      'MOONDROP',
      'MM3A',
      '多用途有源HFi音箱',
      '水月雨MM3A 桌面音箱五模',
      'MM3A~',
      '3期免息 7天价保险',
      '¥699.9',
      '松下影像京东自营旗舰店＞',
      '松下（Panasonic）有线耳机',
      '墨黑色～',
      '7天价保',
      '¥79',
      '全选',
      '¥778.90',
      '去结算（2）',
    ]);

    expect(items, hasLength(2));
    expect(items.first.platform, ShoppingPlatform.jd);
    expect(items.first.title, '水月雨MM3A 桌面音箱五模');
    expect(items.first.price, 699.9);
    expect(items.last.title, '松下（Panasonic）有线耳机');
    expect(items.last.price, 79);
  });

  test('extracts the supplied JD detail screenshot', () {
    final items = CartScreenshotParser.parse([
      '图集1/5',
      '¥79',
      '已售1万+',
      '单品购买',
      '【京补合约】',
      '自营',
      '松下（Panasonic）有线耳机“重低音“耳挂式',
      '耳机 RP-HS47GK-K1防滑“跑步运动游戏耳~',
      '7天价保',
      '加入购物车',
      '立即购买',
    ]);

    expect(items.single.platform, ShoppingPlatform.jd);
    expect(items.single.price, 79);
    expect(items.single.title, contains('RP-HS47GK-K1'));
  });

  test('extracts the supplied Pinduoduo detail screenshot', () {
    final items = CartScreenshotParser.parse([
      '1/5',
      '大促价￥16.83 ¥39',
      '大促直降22.17元',
      '已拼1284件',
      '季末优惠',
      '唱针清洁用品唱针清洗器黑胶唱机唱头配',
      '件清洁工具唱针清洁凝固胶 退货包运费',
      '手机五星好店',
      '1127人好评',
      '近15天112人已享补贴，1245人已拼',
      '直接拼成',
      '免拼购买',
    ]);

    expect(items.single.platform, ShoppingPlatform.pinduoduo);
    expect(items.single.price, 16.83);
    expect(items.single.title, contains('唱针清洁用品'));
    expect(items.single.title, contains('唱针清洁凝固胶'));
  });

  test('handles Android OCR merged Taobao current and original prices', () {
    final items = CartScreenshotParser.parse([
      '购物车(32)',
      '国际 天猫国际自营全球超级店>',
      'Real Folk BIues',
      '狂暑季【自营】正版披头士Th x1',
      '官方立减71元88VIP9.5折退货宝',
      '平台加补后490.2587',
      '天猫天风音像专营店>',
      '披头士专辑 THE BEATLES Abb x1',
      '店鋪优惠后¥431¥490',
      '合计:¥0',
      '结算',
    ]);

    expect(items, hasLength(2));
    expect(items.first.price, 490.2);
    expect(items.first.title, contains('披头士'));
    expect(items.last.price, 431);
  });

  test('handles Android OCR Taobao detail block order and separators', () {
    final items = CartScreenshotParser.parse([
      '店铺优惠后4311优惠前¥490',
      '已亨受:官方立减12%省59元',
      'Anniversary 绿胶LP果胶唱片',
      'G预计明夭发货|承诺48小时內发货',
      '民猫披头士专辑 THE BEATLES Abbey Road',
      '店铺一年回头客4千> 店铺评分超过95%同行>',
      '已售0',
      '加入购物车',
      '领券购买',
    ]);

    expect(items.single.platform, ShoppingPlatform.taobao);
    expect(items.single.price, 431);
    expect(items.single.title, contains('THE BEATLES Abbey Road'));
    expect(items.single.title, isNot(contains('店铺评分')));
  });

  test('pairs an Android OCR cart price that appears before its title', () {
    final items = CartScreenshotParser.parse([
      '购物车(2)',
      '水月雨旗舰店',
      '水月雨MM3A 桌面音箱五模',
      '¥699.9',
      '国松下影像京东自营旗舰店>',
      '墨黑色',
      '*79',
      '松下(Panasonic)有线耳机',
      'PLUS连续包年,本单即可用补贴 ¥99/年',
      '778.90',
      '去结算(2)',
    ]);

    expect(items, hasLength(2));
    expect(items.first.price, 699.9);
    expect(items.last.title, '松下(Panasonic)有线耳机');
    expect(items.last.price, 79);
  });

  test('prefers the branded Android OCR title on JD details', () {
    final items = CartScreenshotParser.parse([
      '79',
      '取边长短线设计/减少墟绕',
      '线材牢固/绕颈佩戴舒适',
      '网课自习必备',
      '已售1万+',
      '自當松下(Panasonic)有线耳机重低音耳挂式',
      '耳机RP-HS47GK-K1防滑跑步运动游戏耳',
      '可再享:小金库支付减2元 白条減1.07元 最高>',
      '【京补合约】',
      '加入购物车',
      '立即购买',
    ]);

    expect(items.single.price, 79);
    expect(items.single.title, contains('松下(Panasonic)'));
    expect(items.single.title, contains('RP-HS47GK-K1'));
    expect(items.single.title, isNot(contains('减少墟绕')));
  });

  test('reorders split Android OCR title parts on Pinduoduo details', () {
    final items = CartScreenshotParser.parse([
      '大促价¥16.83 *39',
      '已拼1284件',
      '正品发票正品保障,承诺可开具正品发票',
      '件清洁工具唱针清洁凝固胶 退货包运费|',
      '季末优惠唱针漬洁用品唱针清洗器黑胶唱机唱头配',
      '季未优惠',
      '拼单即将结束',
      '退货包运费·7天无理由退货·末发货可秒退等 >',
      '直接拼成',
      '免拼购买',
    ]);

    expect(items.single.price, 16.83);
    expect(items.single.title, startsWith('唱针漬洁用品'));
    expect(items.single.title, contains('唱针清洁凝固胶'));
    expect(items.single.title, isNot(contains('正品发票')));
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
