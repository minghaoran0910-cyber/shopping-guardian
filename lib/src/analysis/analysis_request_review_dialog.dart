import 'package:flutter/material.dart';

import '../copy.dart';
import 'analysis_request_summary.dart';

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
                    : summary.confirmedPatterns.join('\n'),
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
