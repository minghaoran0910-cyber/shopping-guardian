import 'package:shared_preferences/shared_preferences.dart';

import '../history/decision_store.dart';

class BudgetSnapshot {
  const BudgetSnapshot({required this.limit, required this.spent});
  final double limit;
  final double spent;
  double get left => limit - spent;
}

class BudgetStore {
  const BudgetStore();
  static const _limitKey = 'monthly_budget_limit';

  Future<void> setLimit(double value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(_limitKey, value.clamp(0, double.infinity));
  }

  Future<BudgetSnapshot> snapshot() async {
    final preferences = await SharedPreferences.getInstance();
    final limit = preferences.getDouble(_limitKey) ?? 0;
    final now = DateTime.now();
    final records = await const DecisionStore().readAll();
    final spent = records
        .where(
          (record) =>
              record.userChoice == 'buy' &&
              record.createdAt.year == now.year &&
              record.createdAt.month == now.month,
        )
        .fold<double>(0, (sum, record) => sum + record.total);
    return BudgetSnapshot(limit: limit, spent: spent);
  }
}
