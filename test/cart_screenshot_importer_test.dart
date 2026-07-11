import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/import/cart_screenshot_importer.dart';
import 'package:shopping_guardian/src/import/share_parser.dart';

void main() {
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
}
