import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/mood_history.dart';
import '../models/mood_result.dart';
import '../core/utils/logger.dart';

/// Service for managing mood history
class HistoryService {
  static final HistoryService instance = HistoryService._internal();
  HistoryService._internal();

  static const String _historyKey = 'mood_history';
  static const int _maxHistoryEntries = 100;

  final _uuid = const Uuid();
  List<MoodHistoryEntry> _cachedHistory = [];
  bool _isInitialized = false;

  /// Initialize the service and load history
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadHistory();
      _isInitialized = true;
      Logger.success('History service initialized');
    } catch (e, stack) {
      Logger.error('Failed to initialize history service', e, stack);
      _cachedHistory = [];
      _isInitialized = true;
    }
  }

  /// Save a new mood detection to history
  Future<MoodHistoryEntry> saveMoodDetection(
    MoodResult moodResult, {
    String? playlistId,
    String? playlistName,
    String? imagePath,
  }) async {
    final entry = MoodHistoryEntry(
      id: _uuid.v4(),
      moodResult: moodResult,
      timestamp: DateTime.now(),
      playlistId: playlistId,
      playlistName: playlistName,
      imagePath: imagePath,
    );

    _cachedHistory.insert(0, entry);

    // Limit history size
    if (_cachedHistory.length > _maxHistoryEntries) {
      _cachedHistory = _cachedHistory.take(_maxHistoryEntries).toList();
    }

    await _saveHistory();
    Logger.info('Saved mood detection to history: ${moodResult.label.name}');

    return entry;
  }

  /// Get all history entries
  Future<List<MoodHistoryEntry>> getHistory() async {
    if (!_isInitialized) {
      await initialize();
    }
    return List.unmodifiable(_cachedHistory);
  }

  /// Get history entries for a specific mood
  Future<List<MoodHistoryEntry>> getHistoryByMood(MoodLabel mood) async {
    final history = await getHistory();
    return history.where((entry) => entry.moodResult.label == mood).toList();
  }

  /// Get history entries within a date range
  Future<List<MoodHistoryEntry>> getHistoryByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final history = await getHistory();
    return history.where((entry) {
      return entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end);
    }).toList();
  }

  /// Delete a history entry
  Future<void> deleteEntry(String id) async {
    _cachedHistory.removeWhere((entry) => entry.id == id);
    await _saveHistory();
    Logger.info('Deleted history entry: $id');
  }

  /// Clear all history
  Future<void> clearHistory() async {
    _cachedHistory.clear();
    await _saveHistory();
    Logger.info('Cleared all history');
  }

  /// Get mood distribution statistics
  Map<MoodLabel, int> getMoodDistribution() {
    final distribution = <MoodLabel, int>{};

    for (final mood in MoodLabel.values) {
      distribution[mood] = 0;
    }

    for (final entry in _cachedHistory) {
      distribution[entry.moodResult.label] =
          (distribution[entry.moodResult.label] ?? 0) + 1;
    }

    return distribution;
  }

  /// Get most common mood
  MoodLabel? getMostCommonMood() {
    if (_cachedHistory.isEmpty) return null;

    final distribution = getMoodDistribution();
    var maxCount = 0;
    MoodLabel? mostCommon;

    distribution.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = mood;
      }
    });

    return mostCommon;
  }

  // Private methods

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);

    if (historyJson != null) {
      try {
        final List<dynamic> decoded = json.decode(historyJson);
        _cachedHistory =
            decoded.map((item) => MoodHistoryEntry.fromJson(item)).toList();
        Logger.info('Loaded ${_cachedHistory.length} history entries');
      } catch (e) {
        Logger.error('Failed to decode history', e);
        _cachedHistory = [];
      }
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(
        _cachedHistory.map((entry) => entry.toJson()).toList(),
      );
      await prefs.setString(_historyKey, encoded);
    } catch (e, stack) {
      Logger.error('Failed to save history', e, stack);
    }
  }
}
