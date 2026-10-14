/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'VibeLens';
  static const String appVersion = '0.1.0';
  static const String appTagline = 'AI Mood Playlist Generator';

  // UI Configuration
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double iconSize = 24.0;
  static const double largeIconSize = 48.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
}

/// Spotify endpoints.
class SpotifyApi {
  SpotifyApi._();

  static const String authUrl = 'https://accounts.spotify.com/authorize';
  static const String tokenUrl = 'https://accounts.spotify.com/api/token';
  static const String baseUrl = 'https://api.spotify.com/v1';
}
