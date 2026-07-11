import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class JustOneApiProduct {
  const JustOneApiProduct({
    required this.itemId,
    this.title,
    this.price,
    this.lowestPrice,
    this.imageUrl,
    this.shopName,
    this.categoryName,
  });

  final String itemId;
  final String? title;
  final double? price;
  final double? lowestPrice;
  final Uri? imageUrl;
  final String? shopName;
  final String? categoryName;
}

class JustOneApiClient {
  const JustOneApiClient({
    required this.token,
    this.client,
    this.baseUrl = 'https://api.justoneapi.com',
  });

  final String token;
  final http.Client? client;
  final String baseUrl;

  Future<JustOneApiProduct> loadJdProduct(String itemId) async {
    return _loadProduct(itemId: itemId, path: '/api/jd/get-item-detail/v3');
  }

  Future<JustOneApiProduct> loadTaobaoProduct(String itemId) async {
    return _loadProduct(itemId: itemId, path: '/api/taobao/get-item-detail/v9');
  }

  Future<JustOneApiProduct> _loadProduct({
    required String itemId,
    required String path,
  }) async {
    final requestClient = client ?? http.Client();
    try {
      final uri = Uri.parse(
        '$baseUrl$path',
      ).replace(queryParameters: {'token': token, 'itemId': itemId});
      final response = await requestClient
          .get(uri)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw JustOneApiException('HTTP ${response.statusCode}');
      }

      final payload = jsonDecode(response.body);
      if (payload is! Map<String, dynamic> || payload['code'] != 0) {
        throw JustOneApiException(
          payload is Map
              ? '${payload['message'] ?? payload['code']}'
              : '返回格式不正确',
        );
      }
      final result = _result(payload);
      return JustOneApiProduct(
        itemId: itemId,
        title: _string(result['title']),
        price: _number(result['currentPrice']),
        lowestPrice: _number(result['lowerPriceyh']),
        imageUrl: _uri(result['image']),
        shopName: _string(result['shopName']),
        categoryName: _string(result['categoryName']),
      );
    } on FormatException catch (error) {
      throw JustOneApiException('返回内容无法解析：$error');
    } on TimeoutException {
      throw const JustOneApiException('连接超时');
    } on http.ClientException catch (error) {
      throw JustOneApiException('网络请求失败：${error.message}');
    } finally {
      if (client == null) requestClient.close();
    }
  }

  static Map<String, dynamic> _result(Map<String, dynamic> payload) {
    final data = payload['data'];
    final data1 = data is Map ? data['data1'] : null;
    final result = data1 is Map ? data1['result'] : null;
    if (result is Map<String, dynamic>) return result;
    if (result is Map) return Map<String, dynamic>.from(result);
    throw const JustOneApiException('商品详情为空');
  }

  static String? _string(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static double? _number(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value');

  static Uri? _uri(Object? value) {
    final text = _string(value);
    return text == null ? null : Uri.tryParse(text);
  }
}

class JustOneApiException implements Exception {
  const JustOneApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
