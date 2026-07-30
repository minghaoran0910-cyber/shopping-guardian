import '../patterns/confirmed_pattern_reference.dart';
import 'consumer_profile.dart';

class ConsumerProfileGenerator {
  const ConsumerProfileGenerator();

  ConsumerProfile? fromEvidence(
    List<ConfirmedPatternReference> patterns, {
    DateTime? now,
  }) {
    if (patterns.length < 3) return null;
    final selected = patterns.take(3).toList();
    final negative = selected
        .where((item) => item.id.endsWith(':negative'))
        .length;
    final positive = selected
        .where((item) => item.id.endsWith(':positive'))
        .length;
    final title = negative >= 2
        ? '清醒避坑派'
        : positive >= 2
        ? '长期使用派'
        : '有据可循派';
    return ConsumerProfile(
      title: title,
      traits: selected.map((item) => item.text).toList(),
      reminder: selected.any((item) => item.contraryEvidence.isNotEmpty)
          ? '偏好不是定论，遇到相反记录时也要重新判断。'
          : '价格再好，也先确认它会被真正使用。',
      source: 'evidence',
      updatedAt: now ?? DateTime.now(),
    );
  }

  ConsumerProfile fromQuiz(List<int> answers, {DateTime? now}) {
    if (answers.length != 4 || answers.any((item) => item != 0 && item != 1)) {
      throw const FormatException('invalid quiz answers');
    }
    final deliberate = (1 - answers[0]) + (1 - answers[1]);
    final exploratory = answers[2] + answers[3];
    final title = deliberate >= 2
        ? '冷静规划派'
        : exploratory >= 2
        ? '灵感探索派'
        : '弹性平衡派';
    final traits = [
      answers[0] == 0 ? '更愿意先列清单再下单' : '容易被当下的新鲜感打动',
      answers[1] == 0 ? '会优先确认已有物品能否继续用' : '更看重新功能带来的变化',
      answers[2] == 0 ? '遇到优惠也愿意先等一晚' : '喜欢在合适时机快速决定',
    ];
    return ConsumerProfile(
      title: title,
      traits: traits,
      reminder: answers[3] == 0
          ? '给真正需要的东西留预算，也给临时心动留冷静期。'
          : '分享的是趣味倾向，不必让标签替你做决定。',
      source: 'quiz',
      updatedAt: now ?? DateTime.now(),
    );
  }
}
