import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/mood_history.dart';
import '../models/mood_result.dart';
import '../services/history_service.dart';
import '../core/theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _historyService = HistoryService.instance;
  List<MoodHistoryEntry> _history = [];
  bool _isLoading = true;
  MoodLabel? _filterMood;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final history = _filterMood == null
          ? await _historyService.getHistory()
          : await _historyService.getHistoryByMood(_filterMood!);

      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load history: $e')),
        );
      }
    }
  }

  Future<void> _deleteEntry(String id) async {
    await _historyService.deleteEntry(id);
    _loadHistory();
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to delete all mood history? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearHistory();
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Mood History'),
        actions: [
          if (_history.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'clear') {
                  _clearHistory();
                } else if (value == 'stats') {
                  _showStatistics();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'stats',
                  child: Row(
                    children: [
                      Icon(Icons.analytics, size: 20),
                      SizedBox(width: 12),
                      Text('Statistics'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Clear All', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),

          // History list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('All'),
              selected: _filterMood == null,
              onSelected: (selected) {
                setState(() => _filterMood = null);
                _loadHistory();
              },
            ),
            const SizedBox(width: 8),
            ...MoodLabel.values.map((mood) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(mood.displayName),
                  selected: _filterMood == mood,
                  onSelected: (selected) {
                    setState(() => _filterMood = selected ? mood : null);
                    _loadHistory();
                  },
                  avatar: Text(
                    _getMoodEmoji(mood),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    // Group by date
    final groupedHistory = <String, List<MoodHistoryEntry>>{};
    for (final entry in _history) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.timestamp);
      groupedHistory.putIfAbsent(dateKey, () => []).add(entry);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedHistory.length,
      itemBuilder: (context, index) {
        final dateKey = groupedHistory.keys.elementAt(index);
        final entries = groupedHistory[dateKey]!;
        final date = DateTime.parse(dateKey);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _formatDate(date),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Entries for this date
            ...entries.map((entry) => _buildHistoryCard(entry)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildHistoryCard(MoodHistoryEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to results screen with this mood
          Navigator.pushNamed(
            context,
            '/results',
            arguments: entry.moodResult,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Mood indicator
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: entry.moodResult.label.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _getMoodEmoji(entry.moodResult.label),
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Mood info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.moodResult.label.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(entry.moodResult.confidence * 100).toStringAsFixed(0)}% confident',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('h:mm a').format(entry.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    if (entry.playlistName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.playlist_play,
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              entry.playlistName!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red.shade300,
                onPressed: () => _deleteEntry(entry.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppTheme.textTertiary,
          ),
          SizedBox(height: 16),
          Text(
            'No mood history yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Capture your first mood to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showStatistics() {
    final distribution = _historyService.getMoodDistribution();
    final mostCommon = _historyService.getMostCommonMood();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mood Statistics'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total detections: ${_history.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (mostCommon != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Most common: ${_getMoodEmoji(mostCommon)} ${mostCommon.displayName}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Distribution:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...MoodLabel.values.map((mood) {
                final count = distribution[mood] ?? 0;
                final percentage =
                    _history.isEmpty ? 0.0 : (count / _history.length * 100);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${_getMoodEmoji(mood)} ${mood.displayName}'),
                          Text('$count (${percentage.toStringAsFixed(0)}%)'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey.shade800,
                        valueColor: AlwaysStoppedAnimation(
                          mood.gradientColors.first,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

  String _getMoodEmoji(MoodLabel mood) {
    switch (mood) {
      case MoodLabel.cozy:
        return '☕';
      case MoodLabel.energetic:
        return '⚡';
      case MoodLabel.melancholic:
        return '🌧️';
      case MoodLabel.calm:
        return '🌊';
      case MoodLabel.nostalgic:
        return '📼';
      case MoodLabel.romantic:
        return '💖';
    }
  }
}
