import 'package:shared_preferences/shared_preferences.dart';

import '../settings/api_key_store.dart';

class ExternalPriceHistoryConfig {
  const ExternalPriceHistoryConfig({this.endpoint, this.token = ''});
  final Uri? endpoint;
  final String token;
  bool get isEnabled => endpoint != null;
}

class ExternalPriceHistoryConfigStore {
  const ExternalPriceHistoryConfigStore({this.keys = const ApiKeyStore()});
  static const _endpointKey = 'external_price_history_endpoint';
  final ApiKeyStore keys;

  Future<ExternalPriceHistoryConfig> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_endpointKey)?.trim() ?? '';
    final uri = Uri.tryParse(raw);
    return ExternalPriceHistoryConfig(
      endpoint: uri != null && uri.hasScheme && uri.host.isNotEmpty
          ? uri
          : null,
      token: await keys.readExternalPriceHistoryToken(),
    );
  }

  Future<void> save({required String endpoint, required String token}) async {
    final prefs = await SharedPreferences.getInstance();
    final uri = Uri.tryParse(endpoint.trim());
    if (endpoint.trim().isNotEmpty &&
        (uri == null || !uri.hasScheme || uri.host.isEmpty)) {
      throw const FormatException('请输入有效的 HTTPS 历史价格服务地址');
    }
    if (endpoint.trim().isEmpty) {
      await prefs.remove(_endpointKey);
    } else {
      await prefs.setString(_endpointKey, endpoint.trim());
    }
    await keys.writeExternalPriceHistoryToken(token);
  }
}
