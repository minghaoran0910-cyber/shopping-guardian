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
    this.itemType,
    this.purchasePrice,
    this.acquiredAt,
  });

  final String id;
  final String name;
  final String category;
  final String status;
  final int quantity;
  final String? notes;
  final String? itemType;
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
    'itemType': itemType,
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
    itemType: json['itemType']?.toString(),
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

  static const itemTypesByCategory = <String, List<String>>{
    '数码': [
      '耳机 / 音频',
      '键盘 / 鼠标',
      '手机 / 平板',
      '电脑',
      '显示器 / 投影',
      '相机 / 智能穿戴',
      '网络 / 存储',
    ],
    '服饰': ['上衣', '裤装', '鞋靴', '包袋', '配饰'],
    '家居': ['家具', '厨具', '清洁', '家电', '照明 / 收纳'],
    '兴趣收藏': ['唱片 / 图书', '乐器', '游戏', '模型 / 收藏'],
    '运动': ['服装', '鞋类', '器材', '户外'],
    '美妆护理': ['护肤', '彩妆', '个护', '香水'],
    '其他': [],
  };

  static List<String> itemTypesFor(String category) =>
      itemTypesByCategory[category] ?? const [];

  static bool supportsItemType(String category, String? itemType) =>
      itemType == null ||
      itemType.trim().isEmpty ||
      itemTypesFor(category).contains(itemType.trim());
}
