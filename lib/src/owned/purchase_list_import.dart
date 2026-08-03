import 'owned_item.dart';

class PurchaseListDraft {
  const PurchaseListDraft({
    required this.name,
    this.category = '其他',
    this.status = 'unknown',
    this.purchasePrice,
    this.acquiredAt,
    this.notes,
    this.itemType,
    this.included = true,
    this.error,
  });

  final String name;
  final String category;
  final String status;
  final double? purchasePrice;
  final DateTime? acquiredAt;
  final String? notes;
  final String? itemType;
  final bool included;
  final String? error;

  bool get isValid => error == null && name.trim().isNotEmpty;

  PurchaseListDraft copyWith({
    String? name,
    String? category,
    String? status,
    double? purchasePrice,
    DateTime? acquiredAt,
    String? notes,
    String? itemType,
    bool? included,
    String? error,
    bool clearPrice = false,
    bool clearDate = false,
    bool clearError = false,
  }) => PurchaseListDraft(
    name: name ?? this.name,
    category: category ?? this.category,
    status: status ?? this.status,
    purchasePrice: clearPrice ? null : purchasePrice ?? this.purchasePrice,
    acquiredAt: clearDate ? null : acquiredAt ?? this.acquiredAt,
    notes: notes ?? this.notes,
    itemType: itemType ?? this.itemType,
    included: included ?? this.included,
    error: clearError ? null : error ?? this.error,
  );
}

class PurchaseListParser {
  const PurchaseListParser();

  List<PurchaseListDraft> parse(String input) {
    final drafts = <PurchaseListDraft>[];
    for (final rawLine in input.split(RegExp(r'\r?\n'))) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final separator = line.contains('\t') ? '\t' : '|';
      final fields = line
          .split(separator)
          .map((value) => value.trim())
          .toList();
      final name = fields.first;
      final category = _category(fields.elementAtOrNull(1));
      final status = _status(fields.elementAtOrNull(2));
      final priceText = fields.elementAtOrNull(3);
      final dateText = fields.elementAtOrNull(4);
      final price = _price(priceText);
      final date = _date(dateText);
      final errors = <String>[
        if (name.isEmpty) 'missing_name',
        if (priceText?.isNotEmpty == true && price == null) 'invalid_price',
        if (dateText?.isNotEmpty == true && date == null) 'invalid_date',
      ];
      drafts.add(
        PurchaseListDraft(
          name: name,
          category: category,
          status: status,
          purchasePrice: price,
          acquiredAt: date,
          notes: fields.elementAtOrNull(5),
          itemType: _itemType(category, fields.elementAtOrNull(6)),
          error: errors.isEmpty ? null : errors.join(','),
        ),
      );
    }
    return drafts;
  }

  static String _category(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return '其他';
    return OwnedItemTemplates.categories.contains(normalized)
        ? normalized
        : '其他';
  }

  static String _status(String? value) {
    final normalized = value?.trim().toLowerCase();
    return switch (normalized) {
      '仍在使用' || '在用' || 'in_use' => 'in_use',
      '备用' || '收藏' || 'backup' => 'backup',
      '已淘汰' || '已转卖' || '淘汰' || '转卖' || 'retired' => 'retired',
      '已退货' || '退货' || 'returned' => 'returned',
      _ => 'unknown',
    };
  }

  static String? _itemType(String category, String? value) {
    final normalized = value?.trim();
    return OwnedItemTemplates.supportsItemType(category, normalized)
        ? normalized?.isEmpty == true
              ? null
              : normalized
        : null;
  }

  static double? _price(String? value) {
    final normalized = value?.replaceAll(RegExp(r'[¥￥,\s]'), '');
    if (normalized == null || normalized.isEmpty) return null;
    final parsed = double.tryParse(normalized);
    return parsed != null && parsed.isFinite && parsed >= 0 ? parsed : null;
  }

  static DateTime? _date(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return DateTime.tryParse(normalized);
  }
}

extension<T> on List<T> {
  T? elementAtOrNull(int index) => index < length ? this[index] : null;
}
