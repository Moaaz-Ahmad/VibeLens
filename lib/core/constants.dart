/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'VibeLens';
  static const String appVersion = '0.1.0';
  static const String appTagline = 'AI Mood Playlist Generator';

  // Model Configuration
  static const String modelPath = 'assets/models/mood_classifier.tflite';
  static const int modelInputSize = 224;
  static const int modelChannels = 3;
  static const int modelClasses = 6;

  // Mood Labels
  static const List<String> moodLabels = [
    'Cozy',
    'Energetic',
    'Melancholic',
    'Calm',
    'Nostalgic',
    'Romantic',
  ];

  // Mood Emojis
  static const List<String> moodEmojis = [
    '🛋️',
    '⚡',
    '🌧️',
    '🌊',
    '📸',
    '💕',
  ];

  // Mood Descriptions
  static const Map<String, String> moodDescriptions = {
    'Cozy': 'Warm, comfortable, and intimate',
    'Energetic': 'Dynamic, vibrant, and high-energy',
    'Melancholic': 'Reflective, somber, and introspective',
    'Calm': 'Peaceful, serene, and tranquil',
    'Nostalgic': 'Sentimental, vintage, and reminiscent',
    'Romantic': 'Loving, intimate, and tender',
  };

  // API Configuration
  static const String spotifyAuthUrl = 'https://accounts.spotify.com/authorize';
  static const String spotifyTokenUrl =
      'https://accounts.spotify.com/api/token';
  static const String spotifyApiBase = 'https://api.spotify.com/v1';

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

  // Performance
  static const int imageQuality = 85;
  static const Duration inferenceTimeout = Duration(seconds: 10);
}
