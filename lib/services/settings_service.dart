import 'package:shared_preferences/shared_preferences.dart';

/// User preferences backed by SharedPreferences.
class AppSettings {
  const AppSettings({
    this.enableHistory = true,
    this.enableAnimations = true,
    this.playlistLength = 20,
  });
  final bool enableHistory;
  final bool enableAnimations;
  final int playlistLength;
}

class SettingsService {
  SettingsService._();
  static final instance = SettingsService._();

  Future<AppSettings> load() async {
    final p = await SharedPreferences.getInstance();
    return AppSettings(
      enableHistory: p.getBool('enableHistory') ?? true,
      enableAnimations: p.getBool('enableAnimations') ?? true,
      playlistLength: p.getInt('playlistLength') ?? 20,
    );
  }

  Future<void> setBool(String key, bool value) async =>
      (await SharedPreferences.getInstance()).setBool(key, value);

  Future<void> setInt(String key, int value) async =>
      (await SharedPreferences.getInstance()).setInt(key, value);
}
