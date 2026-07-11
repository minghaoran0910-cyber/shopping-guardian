import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/import/share_parser.dart';

void main() {
  group('ShoppingShareParser', () {
    test('recognizes a Taobao cart share', () {
      const input =
          '19🗝7Axcgp18zFw£ https://m.tb.cn/h.RAurQAI  CZ225 快来看我购物车里的好宝贝~';

      final result = ShoppingShareParser.parse(input).single;

      expect(result.platform, ShoppingPlatform.taobao);
      expect(result.kind, ShareKind.collection);
      expect(result.shareCode, 'CZ225');
    });

    test('recognizes a Taobao product and title', () {
      const input =
          '【淘宝】假一赔四 https://e.tb.cn/h.RBCP9cfM6IXx3xO?tk=WFsxgp1QyCK HU287 「原装正版 山下达郎专辑 BIG WAVE LP黑胶唱片 完全生産限定 日版」';

      final result = ShoppingShareParser.parse(input).single;

      expect(result.platform, ShoppingPlatform.taobao);
      expect(result.kind, ShareKind.product);
      expect(result.shareCode, 'HU287');
      expect(result.title, '原装正版 山下达郎专辑 BIG WAVE LP黑胶唱片 完全生産限定 日版');
    });

    test('recognizes JD collection and product shares together', () {
      const input = '''
【京东】https://3.cn/2V-chbKX 「漠城中人的购物清单」
点击链接直接打开
【京东】https://3.cn/2V-chiOQ?jkl=@EDoxt4DBLAN@ MU5104 「vivo X300 蔡司2亿超级主摄」
''';

      final results = ShoppingShareParser.parse(input);

      expect(results, hasLength(2));
      expect(results.first.kind, ShareKind.collection);
      expect(results.first.title, '漠城中人的购物清单');
      expect(results.last.kind, ShareKind.product);
      expect(results.last.title, 'vivo X300 蔡司2亿超级主摄');
      expect(results.last.shareCode, 'MU5104');
    });

    test('ignores unrelated links', () {
      expect(ShoppingShareParser.parse('https://example.com/item'), isEmpty);
    });
  });
}
