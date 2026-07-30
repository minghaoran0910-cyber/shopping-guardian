import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/history/decision_record.dart';
import 'package:shopping_guardian/src/patterns/pattern_generator.dart';
import 'package:shopping_guardian/src/patterns/personal_pattern.dart';

void main() {
  DecisionRecord record(
    String id, {
    String? feedback = 'regretted',
    String? usage = 'rarely',
    int? satisfaction = 2,
    List<DecisionEvent> events = const [],
  }) => DecisionRecord(
    id: id,
    itemName: '唱片 $id',
    total: 100,
    verdict: 'wait',
    userChoice: 'buy',
    summary: '摘要',
    createdAt: DateTime(2026, 1, int.parse(id)),
    feedback: feedback,
    usageFrequency: usage,
    satisfaction: satisfaction,
    category: '唱片',
    events: events,
  );

  test('少于三条同类记录时不生成规律', () {
    final patterns = const PatternGenerator().generate([
      record('1'),
      record('2'),
    ]);
    expect(patterns, isEmpty);
  });

  test('多数负向记录生成带正反依据的候选规律', () {
    final patterns = const PatternGenerator().generate([
      record('1'),
      record('2'),
      record('3', feedback: 'satisfied', usage: 'daily', satisfaction: 5),
    ]);
    expect(patterns, hasLength(1));
    expect(patterns.single.status, 'candidate');
    expect(
      patterns.single.evidence.where((item) => item.supportsPattern),
      hasLength(2),
    );
    expect(
      patterns.single.evidence.where((item) => !item.supportsPattern),
      hasLength(1),
    );
  });

  test('未确认购买和没有购后证据的记录不参与候选', () {
    final patterns = const PatternGenerator().generate([
      record('1'),
      record('2'),
      record(
        '3',
        events: [
          DecisionEvent(status: 'skipped', occurredAt: DateTime(2026, 1, 3)),
        ],
      ),
      record('4', feedback: null, usage: null, satisfaction: null),
    ]);

    expect(patterns, isEmpty);
  });

  test('候选依据只包含确认购买且有购后证据的记录', () {
    final patterns = const PatternGenerator().generate([
      record('1'),
      record('2'),
      record('3'),
      record(
        '4',
        events: [
          DecisionEvent(status: 'skipped', occurredAt: DateTime(2026, 1, 4)),
        ],
      ),
      record('5', feedback: null, usage: null, satisfaction: null),
    ]);

    expect(patterns, hasLength(1));
    expect(patterns.single.evidence.map((item) => item.decisionId), [
      '1',
      '2',
      '3',
    ]);
  });

  test('忽略项不会复活，已确认项保留用户修改', () {
    final generated = const PatternGenerator().generate([
      record('1'),
      record('2'),
      record('3'),
    ]);
    final ignored = generated.single.copyWith(status: 'ignored');
    expect(const PatternGenerator().merge(generated, [ignored]), isEmpty);

    final confirmed = PersonalPattern(
      id: generated.single.id,
      text: '我修改后的规律',
      status: 'confirmed',
      evidence: generated.single.evidence,
    );
    final merged = const PatternGenerator().merge(generated, [confirmed]);
    expect(merged.single.text, '我修改后的规律');
    expect(merged.single.status, 'confirmed');
  });
}
