import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'analysis_request_summary.dart';
import 'price_timing_summary.dart';

typedef RetryDelay = Future<void> Function(Duration duration);

enum PurchaseVerdict { buy, wait, skip, alternative, insufficientData }

enum AdviceLevel { low, medium, high }

enum NeedAssessment { established, weak, insufficient }

enum OwnershipRelation { replaces, complements, redundant, insufficient }

class CandidateFact {
  const CandidateFact({required this.text, required this.evidence});

  final String text;
  final String evidence;
}

class PurchaseAdvice {
  const PurchaseAdvice({
    required this.verdict,
    required this.summary,
    required this.reasons,
    required this.missingInformation,
    required this.risk,
    required this.confidence,
    required this.budgetImpact,
    required this.alternatives,
    this.candidateFacts = const [],
    this.waitDays,
    this.needAssessment = NeedAssessment.insufficient,
    this.ownershipRelation = OwnershipRelation.insufficient,
  });

  final PurchaseVerdict verdict;
  final String summary;
  final List<String> reasons;
  final List<String> missingInformation;
  final AdviceLevel risk;
  final AdviceLevel confidence;
  final String budgetImpact;
  final List<String> alternatives;
  final List<CandidateFact> candidateFacts;
  final int? waitDays;
  final NeedAssessment needAssessment;
  final OwnershipRelation ownershipRelation;

  PurchaseAdvice copyWith({
    PurchaseVerdict? verdict,
    String? summary,
    List<String>? reasons,
    int? waitDays,
  }) => PurchaseAdvice(
    verdict: verdict ?? this.verdict,
    summary: summary ?? this.summary,
    reasons: reasons ?? this.reasons,
    missingInformation: missingInformation,
    risk: risk,
    confidence: confidence,
    budgetImpact: budgetImpact,
    alternatives: alternatives,
    candidateFacts: candidateFacts,
    waitDays: waitDays ?? this.waitDays,
    needAssessment: needAssessment,
    ownershipRelation: ownershipRelation,
  );
}

class ModelClient {
  const ModelClient({
    required this.endpoint,
    required this.apiKey,
    required this.model,
    this.useStructuredOutput = true,
    this.maxRetries = 2,
    this.retryDelay = _defaultRetryDelay,
    this.client,
  });

  final String endpoint;
  final String apiKey;
  final String model;
  final bool useStructuredOutput;
  final int maxRetries;
  final RetryDelay retryDelay;
  final http.Client? client;

  Future<PurchaseAdvice> analyze({
    required String itemName,
    required double price,
    String? reason,
    String? category,
    List<String> tags = const [],
    double? monthlyBudget,
    List<String> matchedRules = const [],
    int? minimumRuleWaitDays,
    List<String> relatedHistory = const [],
    List<String> confirmedPatterns = const [],
    List<String> ownedItems = const [],
    PriceTimingSummary priceTiming = const PriceTimingSummary.insufficient(
      '尚未监测此商品',
    ),
  }) async {
    final requestClient = client ?? http.Client();
    try {
      final input = jsonEncode(
        AnalysisRequestSummary(
          endpoint: endpoint,
          itemName: itemName,
          price: price,
          reason: reason,
          category: category,
          tags: tags,
          monthlyBudget: monthlyBudget,
          matchedRules: matchedRules,
          minimumRuleWaitDays: minimumRuleWaitDays,
          relatedHistory: relatedHistory,
          confirmedPatterns: confirmedPatterns,
          ownedItems: ownedItems,
          priceTiming: priceTiming,
        ).requestBody,
      );
      final content = await _complete(requestClient, [
        {
          'role': 'system',
          'content':
              '你是站在用户利益一边的消费决策助手。必须按以下优先级判断：真实需求 > 预算和用户消费规则 > 已有同类物品 > 价格时机。价格证据只能影响“现在买还是等”，绝不能把需求不成立、超预算、命中等待规则或重复购买翻转成 buy。价格证据 status=insufficient 时不得猜测价格趋势或历史低价。若提供了同类已有物品，必须判断候选商品是在替代、补充还是重复购买；没有可靠信息时不要猜。只返回 JSON，字段为 verdict、risk、confidence、summary、reasons、budget_impact、alternatives、missing_information、wait_days、candidate_facts、need_assessment、ownership_relation。need_assessment 只能是 established、weak、insufficient；ownership_relation 只能是 replaces、complements、redundant、insufficient。candidate_facts 最多 3 条，每条格式为 {"text":"可能的个人事实","evidence":"本次输入中的直接依据"}；只能归纳输入直接支持的事实，没有就返回空数组。verdict 只能是 buy、wait、skip、alternative、insufficient_data；risk 和 confidence 只能是 low、medium、high。不要替用户购买。',
        },
        {'role': 'user', 'content': input},
      ]);
      try {
        return _applyGuardrails(
          _parse(content),
          price: price,
          monthlyBudget: monthlyBudget,
          matchedRules: matchedRules,
          minimumRuleWaitDays: minimumRuleWaitDays,
        );
      } on FormatException {
        final repaired = await _complete(requestClient, [
          {
            'role': 'system',
            'content':
                '把下面内容修复成合法 JSON。只返回 JSON，不改变原意。必须包含 verdict、risk、confidence、summary、reasons、budget_impact、alternatives、missing_information、wait_days、need_assessment、ownership_relation；candidate_facts 若存在必须是带 text 和 evidence 的数组。verdict 只能是 buy、wait、skip、alternative、insufficient_data；risk 和 confidence 只能是 low、medium、high；need_assessment 只能是 established、weak、insufficient；ownership_relation 只能是 replaces、complements、redundant、insufficient。',
          },
          {'role': 'user', 'content': content},
        ]);
        try {
          return _applyGuardrails(
            _parse(repaired),
            price: price,
            monthlyBudget: monthlyBudget,
            matchedRules: matchedRules,
            minimumRuleWaitDays: minimumRuleWaitDays,
          );
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
    final uri = Uri.tryParse(endpoint);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      throw const ModelClientException('模型接口地址格式不正确');
    }

    for (var attempt = 0; ; attempt++) {
      final body = <String, Object>{
        'model': model,
        if (useStructuredOutput) 'response_format': {'type': 'json_object'},
        'messages': messages,
      };
      final response = await requestClient
          .post(
            uri,
            headers: {
              if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));
      final retryable =
          response.statusCode == 429 || response.statusCode >= 500;
      if (retryable && attempt < maxRetries) {
        await retryDelay(_retryDuration(response, attempt));
        continue;
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const ModelClientException('API Key 无效或没有权限');
      }
      if (response.statusCode == 404) {
        throw const ModelClientException('模型或接口地址不存在');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ModelClientException('模型服务错误（HTTP ${response.statusCode}）');
      }
      try {
        final envelope = jsonDecode(utf8.decode(response.bodyBytes));
        final content = envelope['choices']?[0]?['message']?['content'];
        if (content is! String) {
          throw const ModelClientException('模型没有返回内容');
        }
        return content;
      } on ModelClientException {
        rethrow;
      } on Object {
        throw const ModelClientException('模型服务返回了无法识别的内容');
      }
    }
  }

  static Duration _retryDuration(http.Response response, int attempt) {
    final retryAfter = int.tryParse(response.headers['retry-after'] ?? '');
    if (retryAfter != null && retryAfter >= 0) {
      return Duration(seconds: retryAfter.clamp(0, 5));
    }
    return Duration(milliseconds: 500 * (1 << attempt).clamp(1, 4));
  }

  static Future<void> _defaultRetryDelay(Duration duration) =>
      Future<void>.delayed(duration);

  static PurchaseAdvice _parse(String content) {
    final data = jsonDecode(content) as Map<String, dynamic>;
    if (!data.containsKey('verdict') ||
        !data.containsKey('summary') ||
        !data.containsKey('reasons') ||
        !data.containsKey('risk') ||
        !data.containsKey('confidence') ||
        !data.containsKey('budget_impact') ||
        !data.containsKey('alternatives') ||
        !data.containsKey('missing_information')) {
      throw const FormatException();
    }
    return PurchaseAdvice(
      verdict: _verdict(data['verdict']),
      summary: '${data['summary'] ?? ''}'.trim(),
      reasons: _strings(data['reasons']),
      missingInformation: _strings(data['missing_information']),
      risk: _level(data['risk']),
      confidence: _level(data['confidence']),
      budgetImpact: '${data['budget_impact'] ?? ''}'.trim(),
      alternatives: _strings(data['alternatives']),
      candidateFacts: _candidateFacts(data['candidate_facts']),
      waitDays: _positiveWaitDays(data['wait_days']),
      needAssessment: _needAssessment(data['need_assessment']),
      ownershipRelation: _ownershipRelation(data['ownership_relation']),
    );
  }

  static PurchaseAdvice _applyGuardrails(
    PurchaseAdvice advice, {
    required double price,
    required double? monthlyBudget,
    required List<String> matchedRules,
    required int? minimumRuleWaitDays,
  }) {
    if (advice.verdict != PurchaseVerdict.buy) return advice;
    if (monthlyBudget != null && price > monthlyBudget) {
      return advice.copyWith(
        verdict: PurchaseVerdict.skip,
        summary: '这件商品已经超过你填写的本月预算，价格优惠不能覆盖预算约束。',
        reasons: [...advice.reasons, '商品价格超过本月预算'],
      );
    }
    if (matchedRules.isNotEmpty) {
      return advice.copyWith(
        verdict: PurchaseVerdict.wait,
        summary: '这件商品命中了你的消费规则，价格优惠不能跳过规则。',
        reasons: [...advice.reasons, '命中已启用的消费规则'],
        waitDays: minimumRuleWaitDays ?? advice.waitDays ?? 1,
      );
    }
    if (advice.ownershipRelation == OwnershipRelation.redundant) {
      return advice.copyWith(
        verdict: PurchaseVerdict.skip,
        summary: '它与仍在使用的同类物品重复，低价本身不足以构成购买理由。',
        reasons: [...advice.reasons, '与已有物品重复'],
      );
    }
    if (advice.needAssessment != NeedAssessment.established) {
      return advice.copyWith(
        verdict: PurchaseVerdict.wait,
        summary: '购买需求还没有说清楚，即使价格合适也建议先等等。',
        reasons: [...advice.reasons, '真实需求尚未确认'],
        waitDays: advice.waitDays ?? 1,
      );
    }
    return advice;
  }

  static PurchaseVerdict _verdict(Object? value) => switch (value) {
    'buy' => PurchaseVerdict.buy,
    'wait' => PurchaseVerdict.wait,
    'skip' => PurchaseVerdict.skip,
    'alternative' => PurchaseVerdict.alternative,
    'insufficient_data' => PurchaseVerdict.insufficientData,
    _ => throw const FormatException(),
  };

  static AdviceLevel _level(Object? value) => switch (value) {
    'low' => AdviceLevel.low,
    'medium' => AdviceLevel.medium,
    'high' => AdviceLevel.high,
    _ => throw const FormatException(),
  };

  static NeedAssessment _needAssessment(Object? value) => switch (value) {
    'established' => NeedAssessment.established,
    'weak' => NeedAssessment.weak,
    _ => NeedAssessment.insufficient,
  };

  static OwnershipRelation _ownershipRelation(Object? value) => switch (value) {
    'replaces' => OwnershipRelation.replaces,
    'complements' => OwnershipRelation.complements,
    'redundant' => OwnershipRelation.redundant,
    _ => OwnershipRelation.insufficient,
  };

  static List<String> _strings(Object? value) => value is List
      ? value
            .map((item) => '$item'.trim())
            .where((item) => item.isNotEmpty)
            .toList()
      : const [];

  static int? _positiveWaitDays(Object? value) {
    if (value is! num) return null;
    final days = value.toInt();
    return days > 0 ? days : null;
  }

  static List<CandidateFact> _candidateFacts(Object? value) {
    if (value is! List) return const [];
    final facts = <CandidateFact>[];
    final seen = <String>{};
    for (final item in value) {
      if (item is! Map) continue;
      final text = '${item['text'] ?? ''}'.trim();
      final evidence = '${item['evidence'] ?? ''}'.trim();
      if (text.isEmpty ||
          evidence.isEmpty ||
          text.length > 120 ||
          evidence.length > 160 ||
          !seen.add(text.toLowerCase())) {
        continue;
      }
      facts.add(CandidateFact(text: text, evidence: evidence));
      if (facts.length == 3) break;
    }
    return facts;
  }
}

class ModelClientException implements Exception {
  const ModelClientException(this.message);
  final String message;
  @override
  String toString() => message;
}
