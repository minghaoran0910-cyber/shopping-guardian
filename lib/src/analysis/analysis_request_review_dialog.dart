import 'package:flutter/material.dart';

import '../copy.dart';
import '../prices/price_watch.dart';
import 'analysis_request_summary.dart';
import 'price_timing_summary.dart';

class AnalysisRequestReviewDialog extends StatelessWidget {
  const AnalysisRequestReviewDialog({super.key, required this.summary});

  final AnalysisRequestSummary summary;

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    return AlertDialog(
      icon: const Icon(Icons.outbox_outlined),
      title: Text(copy.t('发送前核对', 'Review before sending')),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                copy.t(
                  '以下内容将直达 ${summary.destination}，不会经过本项目的服务器。',
                  'The following goes directly to ${summary.destination}, without passing through this project’s servers.',
                ),
              ),
              const SizedBox(height: 14),
              _SummaryRow(label: copy.t('商品', 'Item'), value: summary.itemName),
              _SummaryRow(
                label: copy.t('价格', 'Price'),
                value: '¥${summary.price.toStringAsFixed(2)}',
              ),
              _SummaryRow(
                label: copy.t('购买理由', 'Reason'),
                value: summary.reason?.isNotEmpty == true
                    ? summary.reason!
                    : copy.t('未填写', 'Not provided'),
              ),
              _SummaryRow(
                label: copy.t('分类', 'Category'),
                value: summary.category?.isNotEmpty == true
                    ? summary.category!
                    : copy.t('未填写', 'Not provided'),
              ),
              _SummaryRow(
                label: copy.t('标签', 'Tags'),
                value: summary.tags.isEmpty
                    ? copy.t('无', 'None')
                    : summary.tags.join('、'),
              ),
              _SummaryRow(
                label: copy.t('本月预算', 'Monthly budget'),
                value: summary.monthlyBudget == null
                    ? copy.t('未填写', 'Not provided')
                    : '¥${summary.monthlyBudget!.toStringAsFixed(2)}',
              ),
              _SummaryRow(
                label: copy.t('命中规则', 'Matched rules'),
                value: summary.matchedRules.isEmpty
                    ? copy.t('无', 'None')
                    : summary.matchedRules.join('\n'),
              ),
              if (summary.minimumRuleWaitDays != null)
                _SummaryRow(
                  label: copy.t('规则要求的等待期', 'Rule waiting period'),
                  value: copy.t(
                    '至少 ${summary.minimumRuleWaitDays} 天',
                    'At least ${summary.minimumRuleWaitDays} days',
                  ),
                ),
              _SummaryRow(
                label: copy.t('相关历史摘要', 'Related history summaries'),
                value: summary.relatedHistory.isEmpty
                    ? copy.t('无', 'None')
                    : summary.relatedHistory.join('\n'),
              ),
              _SummaryRow(
                label: copy.t('同类已有物品', 'Owned items in this category'),
                value: summary.ownedItems.isEmpty
                    ? copy.t('无', 'None')
                    : summary.ownedItems.join('\n'),
              ),
              _SummaryRow(
                label: copy.t('已确认的个人规律', 'Confirmed personal patterns'),
                value: summary.confirmedPatterns.isEmpty
                    ? copy.t('无', 'None')
                    : summary.confirmedPatterns
                          .map((item) => item.auditText)
                          .join('\n\n'),
              ),
              _SummaryRow(
                label: copy.t('价格时机证据', 'Price timing evidence'),
                value: _priceTimingDetails(copy, summary.priceTiming),
              ),
              const SizedBox(height: 8),
              Text(
                copy.t(
                  'API Key 只用于请求头，不在上述正文中。',
                  'The API key is used only in the request header and is not included above.',
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(copy.t('取消', 'Cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(copy.t('确认发送', 'Send')),
        ),
      ],
    );
  }

  String _priceTimingDetails(GuardianCopy copy, PriceTimingSummary timing) {
    final lines = <String>[
      switch (timing.status) {
        PriceTimingStatus.nearLocalLow => copy.t(
          '当前价接近本机 30 天低价',
          'Current price is near this device’s 30-day low',
        ),
        PriceTimingStatus.aboveLocalLow => copy.t(
          '当前价高于本机 30 天低价',
          'Current price is above this device’s 30-day low',
        ),
        PriceTimingStatus.insufficient => copy.t(
          '数据不足，不能判断入手时机',
          'Insufficient evidence to judge timing',
        ),
      },
    ];
    void addSnapshot(String label, PriceSnapshot? value) {
      if (value == null) return;
      lines.add(
        '$label：¥${value.price.toStringAsFixed(2)} · ${value.source} · '
        '${value.observedAt.toLocal().toString().substring(0, 16)}',
      );
    }

    addSnapshot(copy.t('当前价', 'Current'), timing.current);
    addSnapshot(copy.t('上次可信价', 'Previous trusted'), timing.reference);
    addSnapshot(copy.t('本机 30 天低价', '30-day low on device'), timing.recentLow);
    lines.add(
      copy.t(
        '价格只影响现在买还是等，不能覆盖需求、预算、规则或已有物品判断。',
        'Price may affect buy-now versus wait, but cannot override need, budget, rules, or owned items.',
      ),
    );
    return lines.join('\n');
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 2),
        SelectableText(value),
      ],
    ),
  );
}
