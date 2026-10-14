/// Mood classification labels.
/// Declaration order is the model's output order (see ml/build_model.py).
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
