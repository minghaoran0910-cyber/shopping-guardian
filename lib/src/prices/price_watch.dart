import '../import/share_parser.dart';

class PriceWatch {
  const PriceWatch({
    required this.id,
    required this.decisionId,
    required this.itemName,
    required this.platform,
    required this.itemId,
    required this.productUrl,
    required this.targetPrice,
    required this.createdAt,
    this.enabled = true,
    this.lastPrice,
    this.lastCheckedAt,
    this.lastError,
    this.notifiedAt,
  });

  final String id;
  final String decisionId;
  final String itemName;
  final ShoppingPlatform platform;
  final String itemId;
  final Uri productUrl;
  final double targetPrice;
  final DateTime createdAt;
  final bool enabled;
  final double? lastPrice;
  final DateTime? lastCheckedAt;
  final String? lastError;
  final DateTime? notifiedAt;

  PriceWatch copyWith({
    double? targetPrice,
    bool? enabled,
    double? lastPrice,
    DateTime? lastCheckedAt,
    String? lastError,
    DateTime? notifiedAt,
    bool clearLastError = false,
    bool clearNotification = false,
    bool clearLastPrice = false,
  }) => PriceWatch(
    id: id,
    decisionId: decisionId,
    itemName: itemName,
    platform: platform,
    itemId: itemId,
    productUrl: productUrl,
    targetPrice: targetPrice ?? this.targetPrice,
    createdAt: createdAt,
    enabled: enabled ?? this.enabled,
    lastPrice: clearLastPrice ? null : lastPrice ?? this.lastPrice,
    lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
    lastError: clearLastError ? null : lastError ?? this.lastError,
    notifiedAt: clearNotification ? null : notifiedAt ?? this.notifiedAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'decisionId': decisionId,
    'itemName': itemName,
    'platform': platform.name,
    'itemId': itemId,
    'productUrl': productUrl.toString(),
    'targetPrice': targetPrice,
    'createdAt': createdAt.toIso8601String(),
    'enabled': enabled,
    'lastPrice': lastPrice,
    'lastCheckedAt': lastCheckedAt?.toIso8601String(),
    'lastError': lastError,
    'notifiedAt': notifiedAt?.toIso8601String(),
  };

  factory PriceWatch.fromJson(Map<String, dynamic> json) => PriceWatch(
    id: '${json['id']}',
    decisionId: '${json['decisionId']}',
    itemName: '${json['itemName']}',
    platform: ShoppingPlatform.values.firstWhere(
      (value) => value.name == json['platform'],
      orElse: () => ShoppingPlatform.unknown,
    ),
    itemId: '${json['itemId']}',
    productUrl: Uri.parse('${json['productUrl']}'),
    targetPrice: (json['targetPrice'] as num).toDouble(),
    createdAt: DateTime.parse('${json['createdAt']}'),
    enabled: json['enabled'] as bool? ?? true,
    lastPrice: (json['lastPrice'] as num?)?.toDouble(),
    lastCheckedAt: json['lastCheckedAt'] == null
        ? null
        : DateTime.parse('${json['lastCheckedAt']}'),
    lastError: json['lastError']?.toString(),
    notifiedAt: json['notifiedAt'] == null
        ? null
        : DateTime.parse('${json['notifiedAt']}'),
  );
}

class PriceSnapshot {
  const PriceSnapshot({
    required this.watchId,
    required this.observedAt,
    required this.price,
    required this.source,
    this.matchConfidence,
  });

  final String watchId;
  final DateTime observedAt;
  final double price;
  final String source;
  final double? matchConfidence;
}

abstract final class PriceWatchIdentity {
  static String? itemId(SharedShoppingItem item) {
    final value = item.url.toString();
    return switch (item.platform) {
      ShoppingPlatform.taobao => RegExp(
        r'(?:[?&](?:id|itemId)=)(\d{6,})',
        caseSensitive: false,
      ).firstMatch(value)?.group(1),
      ShoppingPlatform.jd => RegExp(
        r'(?:item\.jd\.com/|product/)(\d{6,})',
        caseSensitive: false,
      ).firstMatch(value)?.group(1),
      ShoppingPlatform.pinduoduo || ShoppingPlatform.unknown => null,
    };
  }

  static bool supports(SharedShoppingItem item) =>
      item.kind == ShareKind.product && itemId(item) != null;
}
