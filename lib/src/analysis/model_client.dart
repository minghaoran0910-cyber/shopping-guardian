import 'dart:async';
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
    List<String> matchedRules = const [],
    List<String> relatedHistory = const [],
  }) async {
    final requestClient = client ?? http.Client();
    try {
      final input = jsonEncode({
        'item_name': itemName,
        'price': price,
        'purchase_reason': reason,
        'monthly_budget': monthlyBudget,
        'matched_rules': matchedRules,
        'related_history': relatedHistory,
      });
      final content = await _complete(requestClient, [
        {
          'role': 'system',
          'content':
              '你是站在用户利益一边的消费决策助手。只返回 JSON，字段为 verdict、summary、reasons、missing_information、wait_days。verdict 只能是 buy、wait、skip、insufficient_data。不要替用户购买。',
        },
        {'role': 'user', 'content': input},
      ]);
      try {
        return _parse(content);
      } on FormatException {
        final repaired = await _complete(requestClient, [
          {
            'role': 'system',
            'content':
                '把下面内容修复成合法 JSON。只返回 JSON，不改变原意。必须包含 verdict、summary、reasons、missing_information、wait_days。',
          },
          {'role': 'user', 'content': content},
        ]);
        try {
          return _parse(repaired);
        } on FormatException {
          throw const ModelClientException('模型两次返回的 JSON 都无法解析');
        }
      }
    } on TimeoutException {
      throw const ModelClientException('连接超时，请检查模型服务');
    } on http.ClientException catch (error) {
      throw ModelClientException('网络不可达：${error.message}');
    } finally {
      if (client == null) requestClient.close();
    }
  }

  Future<String> _complete(
    http.Client requestClient,
    List<Map<String, String>> messages,
  ) async {
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
            'messages': messages,
          }),
        )
        .timeout(const Duration(seconds: 45));
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const ModelClientException('API Key 无效或没有权限');
    }
    if (response.statusCode == 404) {
      throw const ModelClientException('模型或接口地址不存在');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ModelClientException('模型服务错误（HTTP ${response.statusCode}）');
    }
    final envelope = jsonDecode(utf8.decode(response.bodyBytes));
    final content = envelope['choices']?[0]?['message']?['content'];
    if (content is! String) throw const ModelClientException('模型没有返回内容');
    return content;
  }

  static PurchaseAdvice _parse(String content) {
    final data = jsonDecode(content) as Map<String, dynamic>;
    if (!data.containsKey('verdict') ||
        !data.containsKey('summary') ||
        !data.containsKey('reasons') ||
        !data.containsKey('missing_information')) {
      throw const FormatException();
    }
    return PurchaseAdvice(
      verdict: _verdict(data['verdict']),
      summary: '${data['summary'] ?? ''}'.trim(),
      reasons: _strings(data['reasons']),
      missingInformation: _strings(data['missing_information']),
      waitDays: data['wait_days'] is num
          ? (data['wait_days'] as num).toInt()
          : null,
    );
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
