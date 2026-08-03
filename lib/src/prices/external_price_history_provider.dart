import 'dart:convert';

import 'package:http/http.dart' as http;

import 'price_watch.dart';

/// A user-configured, opt-in history endpoint.
///
/// The endpoint receives `platform` and `item_id` query parameters. It must
/// return a JSON object containing the same `platform` and `item_id`, plus a
/// `history` array. Each observation has `price`, ISO-8601 `observed_at`, and
/// an optional `match_confidence` in the 0–1 range. The identity echo prevents
/// history for a similarly named SKU being silently attached to a watch.
class ExternalPriceHistoryProvider {
  const ExternalPriceHistoryProvider({
    required this.endpoint,
    this.token = '',
    this.client,
  });

  final Uri endpoint;
  final String token;
  final http.Client? client;

  Future<List<PriceSnapshot>> fetch(PriceWatch watch) async {
    if (!endpoint.hasScheme || !endpoint.host.isNotEmpty) {
      throw const ExternalPriceHistoryException('历史价格服务地址无效');
    }
    final uri = endpoint.replace(
      queryParameters: {
        ...endpoint.queryParameters,
        'platform': watch.platform.name,
        'item_id': watch.itemId,
      },
    );
    final response = await (client ?? http.Client()).get(
      uri,
      headers: token.trim().isEmpty
          ? const {}
          : {'Authorization': 'Bearer ${token.trim()}'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ExternalPriceHistoryException(
        '历史价格服务返回 HTTP ${response.statusCode}',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> ||
        decoded['platform']?.toString() != watch.platform.name ||
        decoded['item_id']?.toString() != watch.itemId ||
        decoded['history'] is! List) {
      throw const ExternalPriceHistoryException('历史价格服务没有返回匹配的商品身份');
    }
    final seen = <String>{};
    final result = <PriceSnapshot>[];
    for (final raw in decoded['history'] as List) {
      if (raw is! Map) continue;
      final price = (raw['price'] as num?)?.toDouble();
      final observedAt = DateTime.tryParse(
        raw['observed_at']?.toString() ?? '',
      );
      final confidence = (raw['match_confidence'] as num?)?.toDouble() ?? 0;
      if (price == null ||
          !price.isFinite ||
          price <= 0 ||
          observedAt == null ||
          !confidence.isFinite ||
          confidence < 0 ||
          confidence > 1) {
        continue;
      }
      final key = '${observedAt.toUtc().toIso8601String()}|$price';
      if (seen.add(key)) {
        result.add(
          PriceSnapshot(
            watchId: watch.id,
            observedAt: observedAt,
            price: price,
            source: 'external_history',
            matchConfidence: confidence,
          ),
        );
      }
    }
    result.sort((a, b) => a.observedAt.compareTo(b.observedAt));
    return result;
  }
}

class ExternalPriceHistoryException implements Exception {
  const ExternalPriceHistoryException(this.message);
  final String message;
  @override
  String toString() => message;
}
