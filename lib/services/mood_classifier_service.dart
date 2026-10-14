import '../models/mood_result.dart';
import 'ai_provider_service.dart';
import 'cloud_mood_service.dart';

/// Sends a photo to the signed-in provider and returns its mood scores.
class MoodClassifierService {
  MoodClassifierService({AiProviderService? providers, CloudMoodService? cloud})
      : _providers = providers ?? AiProviderService.instance,
        _cloud = cloud ?? CloudMoodService.instance;

  final AiProviderService _providers;
  final CloudMoodService _cloud;

  Future<MoodResult> classify(String imagePath) async {
    final provider = await _providers.selected();
    if (provider == null) {
      throw Exception(
        'Sign in to Gemini or ChatGPT first (Settings > Mood classifier).',
      );
    }
    final key = await _providers.apiKey(provider);
    if (key == null || key.isEmpty) {
      throw Exception('Not signed in to ${provider.label}.');
    }
    return _cloud.classify(provider, key, imagePath);
  }
}
