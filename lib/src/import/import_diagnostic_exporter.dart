import 'dart:convert';

import 'package:flutter/services.dart';

import 'import_diagnostic_store.dart';

class ImportDiagnosticExporter {
  const ImportDiagnosticExporter({
    this.store = const ImportDiagnosticStore(),
    this.channel = const MethodChannel('shopping_guardian/file_export'),
  });

  final ImportDiagnosticStore store;
  final MethodChannel channel;

  Future<bool> export() async {
    final diagnostics = await store.readAll();
    final content = const JsonEncoder.withIndent('  ').convert({
      'format': 'shopping_guardian_import_diagnostics',
      'version': 1,
      'events': diagnostics.map((item) => item.toJson()).toList(),
    });
    try {
      return await channel.invokeMethod<bool>('saveJson', {
            'content': content,
          }) ??
          false;
    } on MissingPluginException {
      return false;
    }
  }
}
