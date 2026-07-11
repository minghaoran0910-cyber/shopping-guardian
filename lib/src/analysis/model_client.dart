import 'dart:convert';

import 'package:http/http.dart' as http;

enum PurchaseVerdict { buy, wait, skip, insufficientData }

class PurchaseAdvice {
  const PurchaseAdvice({
    required this.verdict,
    required this.summary,
    required this.reasons,
    required this.missingInformation,
    this.waitDays,
  });

  final PurchaseVerdict verdict;
  final String summary;
  final List<String> reasons;
  final List<String> missingInformation;
  final int? waitDays;
}

class ModelClient {
  const ModelClient({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    this.client,
  });

  final String baseUrl;
  final String apiKey;
  final String model;
  final http.Client? client;

  Future<PurchaseAdvice> analyze({
    required String itemName,
    required double price,
    String? reason,
    double? monthlyBudget,
  }) async {
    final requestClient = client ?? http.Client();
    try {
      final response = await requestClient
          .post(
            Uri.parse(
              '${baseUrl.replaceFirst(RegExp(r'/$'), '')}/chat/completions',
            ),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'response_format': {'type': 'json_object'},
              'messages': [
                {
                  'role': 'system',
                  'content':
                      '你是站在用户利益一边的消费决策助手。只返回 JSON，字段为 verdict、summary、reasons、missing_information、wait_days。verdict 只能是 buy、wait、skip、insufficient_data。不要替用户购买。',
                },
                {
                  'role': 'user',
                  'content': jsonEncode({
                    'item_name': itemName,
                    'price': price,
                    'purchase_reason': reason,
                    'monthly_budget': monthlyBudget,
                  }),
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 45));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ModelClientException('HTTP ${response.statusCode}');
      }
      final envelope = jsonDecode(utf8.decode(response.bodyBytes));
      final content = envelope['choices']?[0]?['message']?['content'];
      if (content is! String) throw const ModelClientException('模型没有返回内容');
      final data = jsonDecode(content) as Map<String, dynamic>;
      return PurchaseAdvice(
        verdict: _verdict(data['verdict']),
        summary: '${data['summary'] ?? ''}'.trim(),
        reasons: _strings(data['reasons']),
        missingInformation: _strings(data['missing_information']),
        waitDays: data['wait_days'] is num
            ? (data['wait_days'] as num).toInt()
            : null,
      );
    } on FormatException {
      throw const ModelClientException('模型返回的 JSON 无法解析');
    } finally {
      if (client == null) requestClient.close();
    }
  }

  static PurchaseVerdict _verdict(Object? value) => switch (value) {
    'buy' => PurchaseVerdict.buy,
    'wait' => PurchaseVerdict.wait,
    'skip' => PurchaseVerdict.skip,
    _ => PurchaseVerdict.insufficientData,
  };

  static List<String> _strings(Object? value) => value is List
      ? value
            .map((item) => '$item'.trim())
            .where((item) => item.isNotEmpty)
            .toList()
      : const [];
}

class ModelClientException implements Exception {
  const ModelClientException(this.message);
  final String message;
  @override
  String toString() => message;
}
