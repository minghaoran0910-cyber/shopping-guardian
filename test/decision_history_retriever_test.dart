import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/history/decision_history_retriever.dart';
import 'package:shopping_guardian/src/history/decision_store.dart';

void main() {
  const retriever = DecisionHistoryRetriever();

  test('ranks name and price matches and returns at most five', () {
    final records = [
      _record('same', '宁芝静电容键盘', 699, DateTime(2026, 7, 1)),
      _record('price', '显示器', 720, DateTime(2026, 7, 20)),
      _record('old', '机械键盘', 399, DateTime(2026, 6, 1)),
      _record('1', '商品一', 690, DateTime(2026, 5, 1)),
      _record('2', '商品二', 680, DateTime(2026, 4, 1)),
      _record('3', '商品三', 670, DateTime(2026, 3, 1)),
      _record('unrelated', '唱片', 99, DateTime(2026, 7, 23)),
    ];

    final matches = retriever.findRelevant(
      itemName: '宁芝静电容三模键盘',
      price: 699,
      records: records,
    );

    expect(matches, hasLength(5));
    expect(matches.first.record.id, 'same');
    expect(matches.map((item) => item.record.id), isNot(contains('unrelated')));
    expect(matches.first.summary, contains('用户决定：wait'));
  });

  test('returns no history when neither name nor price is related', () {
    final matches = retriever.findRelevant(
      itemName: '山下达郎黑胶唱片',
      price: 323,
      records: [_record('one', '办公椅', 1999, DateTime(2026, 7, 1))],
    );

    expect(matches, isEmpty);
  });
}

DecisionRecord _record(
  String id,
  String name,
  double total,
  DateTime createdAt,
) => DecisionRecord(
  id: id,
  itemName: name,
  total: total,
  verdict: 'wait',
  userChoice: 'wait',
  summary: '先等等',
  createdAt: createdAt,
);
