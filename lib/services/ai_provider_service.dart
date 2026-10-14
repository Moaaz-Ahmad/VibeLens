import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Hosted vision model that classifies the photo.
enum AiProvider {
  gemini('Google Gemini'),
  openai('ChatGPT (OpenAI)');

  const AiProvider(this.label);
  final String label;
}

/// Stores the active provider and its API key (secure storage).
///
/// Neither Google nor OpenAI offers consumer-account OAuth for third-party
/// apps' model access, so "sign in" = the user's own API key.
class AiProviderService {
  AiProviderService._();
  static final instance = AiProviderService._();

  final _storage = const FlutterSecureStorage();
  static const _providerKey = 'ai_provider';
  static String _keyName(AiProvider p) => 'ai_key_${p.name}';

  /// The active provider, or null when not signed in to any.
  Future<AiProvider?> selected() async {
    final name = await _storage.read(key: _providerKey);
    for (final p in AiProvider.values) {
      if (p.name == name) return p;
    }
    return null;
  }

  Future<String?> apiKey(AiProvider p) => _storage.read(key: _keyName(p));

  /// Saves [key] and makes [p] the active provider.
  Future<void> signIn(AiProvider p, String key) async {
    await _storage.write(key: _keyName(p), value: key.trim());
    await _storage.write(key: _providerKey, value: p.name);
  }

  /// Deletes the key; if [p] was active, no provider is active afterwards.
  Future<void> signOut(AiProvider p) async {
    await _storage.delete(key: _keyName(p));
    if (await selected() == p) await _storage.delete(key: _providerKey);
  }
}
