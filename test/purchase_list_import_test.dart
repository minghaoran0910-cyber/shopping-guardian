import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/owned/purchase_list_import.dart';

void main() {
  const parser = PurchaseListParser();

  test('parses purchase history without assuming current ownership', () {
    final items = parser.parse(
      'AirPods Pro | 数码 | 仍在使用 | ¥1,499 | 2024-06-18 | 通勤 | 耳机 / 音频\n'
      '旧键盘 | 数码 | 已转卖 | 399 | 2022-03-01\n'
      '买过的唱片',
    );

    expect(items, hasLength(3));
    expect(items[0].status, 'in_use');
    expect(items[0].purchasePrice, 1499);
    expect(items[0].acquiredAt, DateTime(2024, 6, 18));
    expect(items[0].notes, '通勤');
    expect(items[0].itemType, '耳机 / 音频');
    expect(items[1].status, 'retired');
    expect(items[2].status, 'unknown');
    expect(items[2].category, '其他');
  });

  test('accepts tab-separated rows and reports invalid fields', () {
    final items = parser.parse(
      '键盘\t数码\tbackup\t699\t2025-01-02\n'
      '耳机|数码|仍在使用|不是价格|昨天',
    );

    expect(items.first.status, 'backup');
    expect(items.first.isValid, isTrue);
    expect(items.last.isValid, isFalse);
    expect(items.last.error, contains('invalid_price'));
    expect(items.last.error, contains('invalid_date'));
  });

  test('ignores comments and maps unknown values safely', () {
    final items = parser.parse(
      '# 名称 | 分类 | 状态\n'
      '旧物 | 自定义分类 | 不知道',
    );

    expect(items, hasLength(1));
    expect(items.single.category, '其他');
    expect(items.single.status, 'unknown');
  });

  test('drops an item type that does not belong to its category', () {
    final item = parser
        .parse('台灯 | 家居 | 仍在使用 | 99 | 2025-01-01 | 卧室 | 耳机 / 音频')
        .single;

    expect(item.itemType, isNull);
  });
}
