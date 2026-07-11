import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class ApiKeyStore {
  const ApiKeyStore({this.storage = const FlutterSecureStorage()});

  static const _justOneApiKey = 'justoneapi_token';
  final FlutterSecureStorage storage;

  Future<String> readJustOneApiToken() async {
    if (Platform.isMacOS) {
      final file = await _macOsFile();
      return file.existsSync() ? (await file.readAsString()).trim() : '';
    }
    return await storage.read(key: _justOneApiKey) ?? '';
  }

  Future<void> writeJustOneApiToken(String value) async {
    final token = value.trim();
    if (Platform.isMacOS) {
      final file = await _macOsFile();
      if (token.isEmpty) {
        if (file.existsSync()) await file.delete();
      } else {
        await file.parent.create(recursive: true);
        await file.writeAsString(token, flush: true);
        await Process.run('/bin/chmod', ['600', file.path]);
      }
      return;
    }
    if (token.isEmpty) {
      await storage.delete(key: _justOneApiKey);
    } else {
      await storage.write(key: _justOneApiKey, value: token);
    }
  }

  Future<File> _macOsFile() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/justoneapi.key');
  }
}
