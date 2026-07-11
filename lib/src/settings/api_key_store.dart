import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class ApiKeyStore {
  const ApiKeyStore({this.storage = const FlutterSecureStorage()});

  static const _justOneApiKey = 'justoneapi_token';
  static const _modelApiKey = 'model_api_key';
  final FlutterSecureStorage storage;

  Future<String> readJustOneApiToken() => _read(_justOneApiKey);

  Future<void> writeJustOneApiToken(String value) async {
    await _write(_justOneApiKey, value);
  }

  Future<String> readModelApiKey() => _read(_modelApiKey);

  Future<void> writeModelApiKey(String value) => _write(_modelApiKey, value);

  Future<String> _read(String key) async {
    if (Platform.isMacOS) {
      final file = await _macOsFile(key);
      return file.existsSync() ? (await file.readAsString()).trim() : '';
    }
    return await storage.read(key: key) ?? '';
  }

  Future<void> _write(String key, String value) async {
    final token = value.trim();
    if (Platform.isMacOS) {
      final file = await _macOsFile(key);
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
      await storage.delete(key: key);
    } else {
      await storage.write(key: key, value: token);
    }
  }

  Future<File> _macOsFile(String key) async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$key.key');
  }
}
