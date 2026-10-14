import 'package:flutter/material.dart';

import '../models/mood_result.dart';

/// UI-only presentation of [MoodLabel] (kept out of the model layer).
extension MoodStyle on MoodLabel {
  String get description => switch (this) {
        MoodLabel.cozy => 'Warm, acoustic, lo-fi vibes',
        MoodLabel.energetic => 'Upbeat, dance, high-tempo',
        MoodLabel.melancholic => 'Reflective, emotional, slow',
        MoodLabel.calm => 'Peaceful, ambient, meditative',
        MoodLabel.nostalgic => 'Retro, sentimental, throwback',
        MoodLabel.romantic => 'Love songs, intimate, smooth',
      };

  List<Color> get gradientColors => switch (this) {
        MoodLabel.cozy => [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
        MoodLabel.energetic => [
            const Color(0xFFFF006E),
            const Color(0xFFFB5607),
          ],
        MoodLabel.melancholic => [
            const Color(0xFF4A5568),
            const Color(0xFF2D3748),
          ],
        MoodLabel.calm => [const Color(0xFF06B6D4), const Color(0xFF3B82F6)],
        MoodLabel.nostalgic => [
            const Color(0xFFEC4899),
            const Color(0xFF8B5CF6),
          ],
        MoodLabel.romantic => [
            const Color(0xFFF472B6),
            const Color(0xFFE879F9),
          ],
      };
}
