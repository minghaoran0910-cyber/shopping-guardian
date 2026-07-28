import 'package:flutter/material.dart';

import '../copy.dart';
import 'decision_store.dart';

class PurchaseFeedbackDialog extends StatefulWidget {
  const PurchaseFeedbackDialog({super.key});

  @override
  State<PurchaseFeedbackDialog> createState() => _PurchaseFeedbackDialogState();
}

class _PurchaseFeedbackDialogState extends State<PurchaseFeedbackDialog> {
  final regretReason = TextEditingController();
  String outcome = 'satisfied';
  String usageFrequency = 'weekly';
  int satisfaction = 4;

  @override
  void dispose() {
    regretReason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = GuardianCopy.of(context);
    final purchased = outcome != 'not_bought';
    return AlertDialog(
      title: Text(copy.t('后来怎么样？', 'What happened later?')),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: outcome,
                decoration: InputDecoration(labelText: copy.t('结果', 'Outcome')),
                items: [
                  DropdownMenuItem(
                    value: 'satisfied',
                    child: Text(copy.t('买了，整体满意', 'Bought, satisfied')),
                  ),
                  DropdownMenuItem(
                    value: 'regretted',
                    child: Text(copy.t('买了，有些后悔', 'Bought, regretted')),
                  ),
                  DropdownMenuItem(
                    value: 'not_bought',
                    child: Text(copy.t('最后没有买', 'Did not buy')),
                  ),
                ],
                onChanged: (value) => setState(() => outcome = value!),
              ),
              if (purchased) ...[
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: usageFrequency,
                  decoration: InputDecoration(
                    labelText: copy.t('使用频率', 'Usage frequency'),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'not_used',
                      child: Text(copy.t('还没用过', 'Not used yet')),
                    ),
                    DropdownMenuItem(
                      value: 'rarely',
                      child: Text(copy.t('很少使用', 'Rarely')),
                    ),
                    DropdownMenuItem(
                      value: 'monthly',
                      child: Text(copy.t('每月几次', 'A few times a month')),
                    ),
                    DropdownMenuItem(
                      value: 'weekly',
                      child: Text(copy.t('每周几次', 'A few times a week')),
                    ),
                    DropdownMenuItem(
                      value: 'daily',
                      child: Text(copy.t('几乎每天', 'Almost daily')),
                    ),
                  ],
                  onChanged: (value) => setState(() => usageFrequency = value!),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  initialValue: satisfaction,
                  decoration: InputDecoration(
                    labelText: copy.t('满意度', 'Satisfaction'),
                  ),
                  items: [
                    for (var score = 1; score <= 5; score++)
                      DropdownMenuItem(value: score, child: Text('$score / 5')),
                  ],
                  onChanged: (value) => setState(() => satisfaction = value!),
                ),
              ],
              if (outcome == 'regretted') ...[
                const SizedBox(height: 14),
                TextField(
                  controller: regretReason,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: copy.t('后悔原因（选填）', 'Regret reason (optional)'),
                    hintText: copy.t(
                      '例如：使用太少、体验不如预期',
                      'For example: rarely used or disappointing',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(copy.t('取消', 'Cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            PurchaseFeedback(
              outcome: outcome,
              usageFrequency: purchased ? usageFrequency : null,
              satisfaction: purchased ? satisfaction : null,
              regretReason: outcome == 'regretted'
                  ? regretReason.text.trim()
                  : null,
            ),
          ),
          child: Text(copy.t('保存反馈', 'Save feedback')),
        ),
      ],
    );
  }
}
