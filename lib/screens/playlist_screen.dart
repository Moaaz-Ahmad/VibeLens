import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/mood_result.dart';
import '../models/playlist.dart';
import '../services/spotify_service.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final _spotifyService = SpotifyService.instance;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  Playlist? _playlist;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAuthAndGenerate();
  }

  Future<void> _checkAuthAndGenerate() async {
    // Check if authenticated
    _isAuthenticated = await _spotifyService.isAuthenticated();

    if (!_isAuthenticated) {
      // Show auth screen
      if (mounted) {
        final result = await Navigator.pushNamed(context, '/spotify-auth');
        if (result == true) {
          _isAuthenticated = true;
          _generatePlaylist();
        }
      }
    } else {
      _generatePlaylist();
    }
  }

  Future<void> _generatePlaylist() async {
    final moodResult =
        ModalRoute.of(context)?.settings.arguments as MoodResult?;

    if (moodResult == null) {
      setState(() {
        _error = 'No mood data available';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final playlist = await _spotifyService.createMoodPlaylist(moodResult);

      setState(() {
        _playlist = playlist;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openInSpotify() async {
    if (_playlist == null) return;

    final appUrl = Uri.parse('spotify:playlist:${_playlist!.id}');
    final webUrl =
        Uri.parse('https://open.spotify.com/playlist/${_playlist!.id}');

    // Try to open in Spotify app first, then fall back to the browser if needed
    try {
      if (await canLaunchUrl(appUrl)) {
        final launched = await launchUrl(
          appUrl,
          mode: LaunchMode.externalNonBrowserApplication,
        );

        if (launched) {
          return;
        }
      }

      if (await canLaunchUrl(webUrl)) {
        final launched = await launchUrl(
          webUrl,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          return;
        }
      }
    } catch (_) {
      // Fall through to the snackbar below.
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No app available to open the playlist.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'Your Playlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF1DB954)),
            SizedBox(height: 24),
            Text(
              'Creating your playlist...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    if (_playlist == null) {
      return const Center(
        child: Text(
          'No playlist available',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return _buildPlaylist();
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error Creating Playlist',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _generatePlaylist,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylist() {
    return Column(
      children: [
        // Playlist header with Hero animation
        Hero(
          tag: 'playlist-header',
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Animated playlist icon
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.library_music,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Playlist name with fade in
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Text(
                        _playlist!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Track count
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_playlist!.tracks.length} tracks',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Track list with staggered animation
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _playlist!.tracks.length,
            itemBuilder: (context, index) {
              return _buildAnimatedTrackItem(
                _playlist!.tracks[index],
                index + 1,
                index,
              );
            },
          ),
        ),

        // Open in Spotify button
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _openInSpotify,
              icon: const Icon(Icons.open_in_new, size: 24),
              label: const Text(
                'Open in Spotify',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: const Color(0xFF1DB954).withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedTrackItem(Track track, int displayIndex, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  // Track number with gradient background
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$displayIndex',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Album art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      track.albumArt,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white54,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Track info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          track.artist,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Duration
                  Text(
                    _formatDuration(track.durationMs),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
