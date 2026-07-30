class OwnedItem {
  const OwnedItem({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.purchasePrice,
    this.acquiredAt,
  });

  final String id;
  final String name;
  final String category;
  final String status;
  final int quantity;
  final String? notes;
  final double? purchasePrice;
  final DateTime? acquiredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get countsAsCurrentlyOwned => status == 'in_use' || status == 'backup';

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'status': status,
    'quantity': quantity,
    'notes': notes,
    'purchasePrice': purchasePrice,
    'acquiredAt': acquiredAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory OwnedItem.fromJson(Map<String, dynamic> json) => OwnedItem(
    id: '${json['id']}',
    name: '${json['name']}',
    category: '${json['category']}',
    status: '${json['status']}',
    quantity: (json['quantity'] as num).toInt(),
    notes: json['notes']?.toString(),
    purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
    acquiredAt: json['acquiredAt'] == null
        ? null
        : DateTime.parse('${json['acquiredAt']}'),
    createdAt: DateTime.parse('${json['createdAt']}'),
    updatedAt: DateTime.parse('${json['updatedAt']}'),
  );
}

abstract final class OwnedItemTemplates {
  static const categories = <String>[
    '数码',
    '服饰',
    '家居',
    '兴趣收藏',
    '运动',
    '美妆护理',
    '其他',
  ];

  static const statuses = <String>[
    'in_use',
    'backup',
    'retired',
    'returned',
    'unknown',
  ];
}
