import 'cart_screenshot_importer.dart';
import '../owned/purchase_list_import.dart';

class OrderScreenshotImporter {
  const OrderScreenshotImporter({this.ocr = const CartScreenshotImporter()});

  final CartScreenshotImporter ocr;

  Future<OrderScreenshotResult> pickAndRecognize() async {
    final lines = await ocr.recognizeLines();
    if (lines == null) return const OrderScreenshotResult.cancelled();
    return OrderScreenshotResult(
      drafts: OrderScreenshotParser.parse(lines),
      recognizedLineCount: lines.where((line) => line.trim().isNotEmpty).length,
    );
  }
}

class OrderScreenshotResult {
  const OrderScreenshotResult({
    required this.drafts,
    required this.recognizedLineCount,
    this.wasCancelled = false,
  });

  const OrderScreenshotResult.cancelled()
    : drafts = const [],
      recognizedLineCount = 0,
      wasCancelled = true;

  final List<PurchaseListDraft> drafts;
  final int recognizedLineCount;
  final bool wasCancelled;
}

abstract final class OrderScreenshotParser {
  static final _price = RegExp(
    r'(?:[¥￥]|RMB)\s*(\d+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );
  static final _barePrice = RegExp(r'^\s*(\d{1,7}(?:\.\d{1,2})?)\s*$');

  static List<PurchaseListDraft> parse(List<String> source) {
    final lines = source
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final drafts = <PurchaseListDraft>[];
    final seen = <String>{};

    for (var index = 0; index < lines.length; index++) {
      final price = _itemPrice(lines[index]);
      if (price == null || _totalLine(lines[index])) continue;
      final title = _nearestTitle(lines, index);
      if (title == null || !seen.add(title.toLowerCase())) continue;
      drafts.add(
        PurchaseListDraft(
          name: title,
          category: '其他',
          status: _statusAround(lines, index),
          purchasePrice: price,
          notes: '订单截图 OCR，请核对',
        ),
      );
    }
    return drafts;
  }

  static double? _itemPrice(String line) {
    final match = _price.firstMatch(line);
    final bare = match == null ? _barePrice.firstMatch(line) : null;
    final value = double.tryParse(match?.group(1) ?? bare?.group(1) ?? '');
    if (value == null || !value.isFinite || value <= 0) return null;
    if (match == null && value < 10) return null;
    return value;
  }

  static String? _nearestTitle(List<String> lines, int priceIndex) {
    String? best;
    var bestScore = -1;
    final start = (priceIndex - 5).clamp(0, lines.length);
    for (var index = start; index < priceIndex; index++) {
      final line = _clean(lines[index]);
      if (!_titleCandidate(line)) continue;
      final score = line.length + (index * 2);
      if (score > bestScore) {
        best = line;
        bestScore = score;
      }
    }
    return best;
  }

  static bool _titleCandidate(String line) {
    if (line.length < 4 || line.length > 160) return false;
    if (_noise(line) || _itemPrice(line) != null) return false;
    if (!RegExp(r'[\u4e00-\u9fffA-Za-z]').hasMatch(line)) return false;
    return true;
  }

  static String _clean(String line) => line
      .replaceFirst(RegExp(r'^(?:淘宝|天猫|京东|拼多多|自营)\s*'), '')
      .replaceFirst(RegExp(r'^[\[\]【】\s]+'), '')
      .trim();

  static bool _totalLine(String line) {
    final compact = line.replaceAll(RegExp(r'\s'), '');
    return compact.contains('实付款') ||
        compact.contains('实付') ||
        compact.contains('合计') ||
        compact.contains('总计') ||
        compact.contains('应付') ||
        compact.contains('订单金额') ||
        compact.contains('付款金额');
  }

  static bool _noise(String line) {
    final compact = line.replaceAll(RegExp(r'\s'), '');
    const exact = {
      '交易成功',
      '待付款',
      '待发货',
      '待收货',
      '已完成',
      '已取消',
      '查看物流',
      '再次购买',
      '申请售后',
      '评价',
      '删除订单',
      '联系客服',
    };
    if (exact.contains(compact)) return true;
    return compact.contains('订单编号') ||
        compact.contains('下单时间') ||
        compact.contains('付款时间') ||
        compact.contains('收货地址') ||
        compact.contains('运费') ||
        compact.contains('优惠') ||
        compact.contains('共计') ||
        compact.contains('共1件') ||
        compact.startsWith('规格') ||
        compact.startsWith('颜色分类') ||
        compact.startsWith('型号') ||
        compact.startsWith('店铺');
  }

  static String _statusAround(List<String> lines, int index) {
    final start = (index - 8).clamp(0, lines.length);
    for (var cursor = index - 1; cursor >= start; cursor--) {
      final line = lines[cursor].replaceAll(RegExp(r'\s'), '');
      if (line.contains('退款成功') ||
          line.contains('退货成功') ||
          line.contains('已退款')) {
        return 'returned';
      }
      if (line.contains('交易成功') ||
          line.contains('已完成') ||
          line.contains('待发货') ||
          line.contains('待收货') ||
          (_itemPrice(line) != null && !_totalLine(line))) {
        return 'unknown';
      }
    }
    return 'unknown';
  }
}
