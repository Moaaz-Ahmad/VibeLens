import 'mood_result.dart';

/// Represents a saved mood detection with timestamp
class MoodHistoryEntry {
  final String id;
  final MoodResult moodResult;
  final DateTime timestamp;
  final String? playlistId;
  final String? playlistName;
  final String? imagePath;

  MoodHistoryEntry({
    required this.id,
    required this.moodResult,
    required this.timestamp,
    this.playlistId,
    this.playlistName,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moodResult': {
        'label': moodResult.label.name,
        'confidence': moodResult.confidence,
        'embedding': moodResult.embedding,
        'timestamp': moodResult.timestamp.toIso8601String(),
        'inferenceTimeMs': moodResult.inferenceTimeMs,
      },
      'timestamp': timestamp.toIso8601String(),
      'playlistId': playlistId,
      'playlistName': playlistName,
      'imagePath': imagePath,
    };
  }

  factory MoodHistoryEntry.fromJson(Map<String, dynamic> json) {
    final moodData = json['moodResult'] as Map<String, dynamic>;
    return MoodHistoryEntry(
      id: json['id'] as String,
      moodResult: MoodResult(
        label: MoodLabel.values.firstWhere(
          (e) => e.name == moodData['label'],
        ),
        confidence: (moodData['confidence'] as num).toDouble(),
        embedding: (moodData['embedding'] as List)
            .map((e) => (e as num).toDouble())
            .toList(),
        timestamp: DateTime.parse(moodData['timestamp'] as String),
        inferenceTimeMs: moodData['inferenceTimeMs'] as int,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      playlistId: json['playlistId'] as String?,
      playlistName: json['playlistName'] as String?,
      imagePath: json['imagePath'] as String?,
    );
  }

  MoodHistoryEntry copyWith({
    String? id,
    MoodResult? moodResult,
    DateTime? timestamp,
    String? playlistId,
    String? playlistName,
    String? imagePath,
  }) {
    return MoodHistoryEntry(
      id: id ?? this.id,
      moodResult: moodResult ?? this.moodResult,
      timestamp: timestamp ?? this.timestamp,
      playlistId: playlistId ?? this.playlistId,
      playlistName: playlistName ?? this.playlistName,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
