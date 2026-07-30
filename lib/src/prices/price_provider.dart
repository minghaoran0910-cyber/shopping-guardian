import '../import/justoneapi_client.dart';
import '../import/share_parser.dart';
import 'price_watch.dart';

class PriceQuote {
  const PriceQuote({
    required this.price,
    required this.observedAt,
    required this.source,
    required this.matchConfidence,
  });

  final double price;
  final DateTime observedAt;
  final String source;
  final double matchConfidence;
}

abstract interface class PriceProvider {
  String get id;
  bool supports(PriceWatch watch);

  Future<PriceQuote> fetch(
    PriceWatch watch, {
    required String credential,
    required DateTime observedAt,
  });
}

class JustOneApiPriceProvider implements PriceProvider {
  const JustOneApiPriceProvider();

  @override
  String get id => 'justoneapi';

  @override
  bool supports(PriceWatch watch) =>
      watch.platform == ShoppingPlatform.taobao ||
      watch.platform == ShoppingPlatform.jd;

  @override
  Future<PriceQuote> fetch(
    PriceWatch watch, {
    required String credential,
    required DateTime observedAt,
  }) async {
    if (!supports(watch)) {
      throw const JustOneApiException('这个平台暂不支持自动查价');
    }
    final client = JustOneApiClient(token: credential);
    final product = switch (watch.platform) {
      ShoppingPlatform.taobao => await client.loadTaobaoProduct(watch.itemId),
      ShoppingPlatform.jd => await client.loadJdProduct(watch.itemId),
      ShoppingPlatform.pinduoduo || ShoppingPlatform.unknown =>
        throw const JustOneApiException('这个平台暂不支持自动查价'),
    };
    if (product.price == null) {
      throw const JustOneApiException('接口没有返回可用价格');
    }
    // The provider is queried with a stable platform item id and the client
    // preserves that id. The upstream payload does not independently echo a
    // canonical id, so this is high confidence rather than perfect certainty.
    final confidence = product.itemId == watch.itemId ? 0.9 : 0.0;
    return PriceQuote(
      price: product.price!,
      observedAt: observedAt,
      source: id,
      matchConfidence: confidence,
    );
  }
}
