import 'dart:io';

import 'package:shopping_guardian/src/import/jd_cart_importer.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1) {
    throw ArgumentError(
      'Usage: dart run tool/check_jd_import.dart <share-url>',
    );
  }

  final items = await const JdCartImporter().load(Uri.parse(arguments.single));
  for (final item in items) {
    stdout.writeln('${item.title}\t¥${item.price}\t${item.url}');
  }
}
