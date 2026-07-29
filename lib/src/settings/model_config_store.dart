import 'package:shared_preferences/shared_preferences.dart';

import 'api_key_store.dart';

enum ModelServicePreset { custom, openAI, deepSeek, ollama }

extension ModelServicePresetDefaults on ModelServicePreset {
  String get id => switch (this) {
    ModelServicePreset.custom => 'custom',
    ModelServicePreset.openAI => 'openai',
    ModelServicePreset.deepSeek => 'deepseek',
    ModelServicePreset.ollama => 'ollama',
  };

  String get endpoint => switch (this) {
    ModelServicePreset.custom => '',
    ModelServicePreset.openAI => 'https://api.openai.com/v1/chat/completions',
    ModelServicePreset.deepSeek => 'https://api.deepseek.com/chat/completions',
    ModelServicePreset.ollama => 'http://localhost:11434/v1/chat/completions',
  };

  static ModelServicePreset fromId(String? id) =>
      ModelServicePreset.values.firstWhere(
        (preset) => preset.id == id,
        orElse: () => ModelServicePreset.custom,
      );
}

class ModelConfig {
  const ModelConfig({
    required this.endpoint,
    required this.model,
    required this.apiKey,
    this.structuredOutput = true,
    this.preset = ModelServicePreset.custom,
  });

  final String endpoint;
  final String model;
  final String apiKey;
  final bool structuredOutput;
  final ModelServicePreset preset;

  bool get isComplete {
    final uri = Uri.tryParse(endpoint);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty &&
        model.isNotEmpty;
  }
}

class ModelConfigStore {
  const ModelConfigStore({this.keyStore = const ApiKeyStore()});
  final ApiKeyStore keyStore;

  Future<ModelConfig> read() async {
    final preferences = await SharedPreferences.getInstance();
    final savedEndpoint = preferences.getString('model_endpoint');
    final legacyBaseUrl = preferences.getString('model_base_url');
    return ModelConfig(
      endpoint: normalizeEndpoint(
        savedEndpoint ??
            (legacyBaseUrl == null ? '' : _legacyEndpoint(legacyBaseUrl)),
      ),
      model: preferences.getString('model_name') ?? '',
      apiKey: await keyStore.readModelApiKey(),
      structuredOutput: preferences.getBool('model_structured_output') ?? true,
      preset: ModelServicePresetDefaults.fromId(
        preferences.getString('model_service_preset'),
      ),
    );
  }

  Future<void> write(ModelConfig config) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      'model_endpoint',
      normalizeEndpoint(config.endpoint),
    );
    await preferences.setString('model_name', config.model.trim());
    await preferences.setBool(
      'model_structured_output',
      config.structuredOutput,
    );
    await preferences.setString('model_service_preset', config.preset.id);
    await preferences.remove('model_base_url');
    await keyStore.writeModelApiKey(config.apiKey);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('model_base_url');
    await preferences.remove('model_endpoint');
    await preferences.remove('model_name');
    await preferences.remove('model_structured_output');
    await preferences.remove('model_service_preset');
    await keyStore.writeModelApiKey('');
  }

  static String _legacyEndpoint(String baseUrl) {
    return normalizeEndpoint(baseUrl);
  }

  static String normalizeEndpoint(String value) {
    final normalized = value.trim().replaceFirst(RegExp(r'/$'), '');
    if (normalized.isEmpty ||
        normalized.endsWith('/chat/completions') ||
        !normalized.endsWith('/v1')) {
      return normalized;
    }
    return '$normalized/chat/completions';
  }
}
