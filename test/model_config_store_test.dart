import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_guardian/src/settings/api_key_store.dart';
import 'package:shopping_guardian/src/settings/model_config_store.dart';

class MemoryApiKeyStore extends ApiKeyStore {
  String value = '';

  @override
  Future<String> readModelApiKey() async => value;

  @override
  Future<void> writeModelApiKey(String value) async {
    this.value = value;
  }
}

void main() {
  test('normalizes common OpenAI-compatible base URLs', () {
    expect(
      ModelConfigStore.normalizeEndpoint('https://example.com/v1'),
      'https://example.com/v1/chat/completions',
    );
    expect(
      ModelConfigStore.normalizeEndpoint(
        'https://example.com/v1/chat/completions',
      ),
      'https://example.com/v1/chat/completions',
    );
    expect(
      ModelConfigStore.normalizeEndpoint('http://localhost:11434/api/chat'),
      'http://localhost:11434/api/chat',
    );
  });

  test('reads a legacy base URL as a complete chat endpoint', () async {
    SharedPreferences.setMockInitialValues({
      'model_base_url': 'https://legacy.example/v1/',
      'model_name': 'legacy-model',
    });
    final keyStore = MemoryApiKeyStore()..value = 'secret';

    final config = await ModelConfigStore(keyStore: keyStore).read();

    expect(config.endpoint, 'https://legacy.example/v1/chat/completions');
    expect(config.model, 'legacy-model');
    expect(config.apiKey, 'secret');
    expect(config.structuredOutput, isTrue);
    expect(config.preset, ModelServicePreset.custom);
  });

  test('writes the new endpoint and compatibility options', () async {
    SharedPreferences.setMockInitialValues({
      'model_base_url': 'https://old.example/v1',
    });
    final keyStore = MemoryApiKeyStore();
    final store = ModelConfigStore(keyStore: keyStore);

    await store.write(
      const ModelConfig(
        endpoint: 'http://localhost:11434/v1/chat/completions',
        model: 'local-model',
        apiKey: '',
        structuredOutput: false,
        preset: ModelServicePreset.ollama,
      ),
    );

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey('model_base_url'), isFalse);
    expect(
      preferences.getString('model_endpoint'),
      'http://localhost:11434/v1/chat/completions',
    );
    expect(preferences.getBool('model_structured_output'), isFalse);
    expect(preferences.getString('model_service_preset'), 'ollama');

    final config = await store.read();
    expect(config.isComplete, isTrue);
    expect(config.structuredOutput, isFalse);
    expect(config.preset, ModelServicePreset.ollama);
  });

  test(
    'does not duplicate a full endpoint saved by an older version',
    () async {
      SharedPreferences.setMockInitialValues({
        'model_base_url': 'https://legacy.example/v1/chat/completions',
        'model_name': 'legacy-model',
      });

      final config = await ModelConfigStore(
        keyStore: MemoryApiKeyStore(),
      ).read();

      expect(config.endpoint, 'https://legacy.example/v1/chat/completions');
    },
  );

  test(
    'requires a valid endpoint and model but allows a local service without a key',
    () {
      expect(
        const ModelConfig(
          endpoint: 'http://localhost:11434/v1/chat/completions',
          model: 'local-model',
          apiKey: '',
        ).isComplete,
        isTrue,
      );
      expect(
        const ModelConfig(
          endpoint: 'not a url',
          model: 'local-model',
          apiKey: '',
        ).isComplete,
        isFalse,
      );
    },
  );
}
