import 'package:shared_preferences/shared_preferences.dart';

import 'api_key_store.dart';

class ModelConfig {
  const ModelConfig({
    required this.baseUrl,
    required this.model,
    required this.apiKey,
  });
  final String baseUrl;
  final String model;
  final String apiKey;
  bool get isComplete =>
      baseUrl.isNotEmpty && model.isNotEmpty && apiKey.isNotEmpty;
}

class ModelConfigStore {
  const ModelConfigStore({this.keyStore = const ApiKeyStore()});
  final ApiKeyStore keyStore;

  Future<ModelConfig> read() async {
    final preferences = await SharedPreferences.getInstance();
    return ModelConfig(
      baseUrl: preferences.getString('model_base_url') ?? '',
      model: preferences.getString('model_name') ?? '',
      apiKey: await keyStore.readModelApiKey(),
    );
  }

  Future<void> write(ModelConfig config) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('model_base_url', config.baseUrl.trim());
    await preferences.setString('model_name', config.model.trim());
    await keyStore.writeModelApiKey(config.apiKey);
  }
}
