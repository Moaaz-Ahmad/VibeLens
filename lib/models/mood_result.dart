import 'package:flutter/material.dart';

/// Mood classification labels
enum MoodLabel {
  cozy,
  energetic,
  melancholic,
  calm,
  nostalgic,
  romantic;

  String get displayName {
    switch (this) {
      case MoodLabel.cozy:
        return 'Cozy';
      case MoodLabel.energetic:
        return 'Energetic';
      case MoodLabel.melancholic:
        return 'Melancholic';
      case MoodLabel.calm:
        return 'Calm';
      case MoodLabel.nostalgic:
        return 'Nostalgic';
      case MoodLabel.romantic:
        return 'Romantic';
    }
  }

  String get description {
    switch (this) {
      case MoodLabel.cozy:
        return 'Warm, acoustic, lo-fi vibes';
      case MoodLabel.energetic:
        return 'Upbeat, dance, high-tempo';
      case MoodLabel.melancholic:
        return 'Reflective, emotional, slow';
      case MoodLabel.calm:
        return 'Peaceful, ambient, meditative';
      case MoodLabel.nostalgic:
        return 'Retro, sentimental, throwback';
      case MoodLabel.romantic:
        return 'Love songs, intimate, smooth';
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case MoodLabel.cozy:
        return [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)];
      case MoodLabel.energetic:
        return [const Color(0xFFFF006E), const Color(0xFFFB5607)];
      case MoodLabel.melancholic:
        return [const Color(0xFF4A5568), const Color(0xFF2D3748)];
      case MoodLabel.calm:
        return [const Color(0xFF06B6D4), const Color(0xFF3B82F6)];
      case MoodLabel.nostalgic:
        return [const Color(0xFFEC4899), const Color(0xFF8B5CF6)];
      case MoodLabel.romantic:
        return [const Color(0xFFF472B6), const Color(0xFFE879F9)];
    }
  }
}

/// Mood detection result
class MoodResult {
  final MoodLabel label;
  final double confidence;
  final List<double> embedding;
  final DateTime timestamp;
  final int inferenceTimeMs;

  const MoodResult({
    required this.label,
    required this.confidence,
    required this.embedding,
    required this.timestamp,
    required this.inferenceTimeMs,
  });

  Map<String, dynamic> toJson() => {
        'label': label.name,
        'confidence': confidence,
        'embedding': embedding,
        'timestamp': timestamp.toIso8601String(),
        'inferenceTimeMs': inferenceTimeMs,
      };
}
