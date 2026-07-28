import 'dart:async';

import 'package:http/http.dart' as http;

import 'import_diagnostic.dart';
import 'import_diagnostic_store.dart';
import 'jd_cart_importer.dart';
import 'jd_product_importer.dart';
import 'justoneapi_client.dart';
import 'share_parser.dart';
import 'taobao_product_importer.dart';

class ImportResult {
  const ImportResult({required this.items, required this.warnings});

  final List<SharedShoppingItem> items;
  final List<ImportWarning> warnings;
}

enum ImportWarning { taobaoCollectionNeedsScreenshot, enrichmentFailed }

class ImportCoordinator {
  const ImportCoordinator({
    this.details,
    this.diagnostics = const ImportDiagnosticStore(),
    this.jdCartLoader,
    this.jdProductLoader,
    this.taobaoProductLoader,
  });

  final JustOneApiClient? details;
  final ImportDiagnosticStore diagnostics;
  final Future<List<SharedShoppingItem>> Function(Uri)? jdCartLoader;
  final Future<SharedShoppingItem> Function(Uri)? jdProductLoader;
  final Future<SharedShoppingItem> Function(Uri)? taobaoProductLoader;

  Future<ImportResult> enrich(List<SharedShoppingItem> parsed) async {
    final output = <SharedShoppingItem>[];
    final warnings = <ImportWarning>[];
    for (final item in parsed) {
      if (item.platform == ShoppingPlatform.taobao &&
          item.kind == ShareKind.collection) {
        output.add(item);
        warnings.add(ImportWarning.taobaoCollectionNeedsScreenshot);
        await _record(item, 'extract_collection', 'unsupported');
        continue;
      }
      try {
        if (item.platform == ShoppingPlatform.jd &&
            item.kind == ShareKind.collection) {
          final loader =
              jdCartLoader ??
              (url) => JdCartImporter(productDetails: details).load(url);
          output.addAll(await loader(item.url));
        } else if ((details != null || jdProductLoader != null) &&
            item.platform == ShoppingPlatform.jd) {
          final loader =
              jdProductLoader ??
              (url) => JdProductImporter(productDetails: details!).load(url);
          output.add(await loader(item.url));
        } else if ((details != null || taobaoProductLoader != null) &&
            item.platform == ShoppingPlatform.taobao) {
          final loader =
              taobaoProductLoader ??
              (url) =>
                  TaobaoProductImporter(productDetails: details!).load(url);
          output.add(await loader(item.url));
        } else {
          output.add(item);
        }
      } on Object catch (error) {
        output.add(item);
        warnings.add(ImportWarning.enrichmentFailed);
        await _record(item, _stage(item), _category(error));
      }
    }
    return ImportResult(items: output, warnings: warnings.toSet().toList());
  }

  Future<void> _record(
    SharedShoppingItem item,
    String stage,
    String category,
  ) => diagnostics.add(
    ImportDiagnostic(
      platform: item.platform.name,
      stage: stage,
      category: category,
      occurredAt: DateTime.now(),
    ),
  );

  static String _stage(SharedShoppingItem item) =>
      item.kind == ShareKind.collection ? 'extract_collection' : 'enrich_item';

  static String _category(Object error) {
    if (error is TimeoutException) return 'timeout';
    if (error is http.ClientException) return 'network';
    if (error is JdCartImportException && error.message.startsWith('HTTP ')) {
      return 'http';
    }
    if (error is JdCartImportException ||
        error is JdProductImportException ||
        error is TaobaoImportException ||
        error is JustOneApiException) {
      return 'parse_or_service';
    }
    return 'unexpected';
  }
}
