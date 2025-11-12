import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/mood_result.dart';
import '../models/playlist.dart';

/// Service for Spotify API integration
class SpotifyService {
  static final SpotifyService instance = SpotifyService._internal();
  SpotifyService._internal();

  final _storage = const FlutterSecureStorage();
  static const String baseUrl = 'https://api.spotify.com/v1';

  String? _accessToken;
  DateTime? _tokenExpiry;

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    _accessToken = await _storage.read(key: 'spotify_access_token');
    final expiryStr = await _storage.read(key: 'spotify_token_expiry');

    if (_accessToken == null || expiryStr == null) return false;

    _tokenExpiry = DateTime.parse(expiryStr);
    return DateTime.now().isBefore(_tokenExpiry!);
  }

  /// Save access token
  Future<void> saveToken(String token, int expiresIn) async {
    _accessToken = token;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

    await _storage.write(key: 'spotify_access_token', value: token);
    await _storage.write(
      key: 'spotify_token_expiry',
      value: _tokenExpiry!.toIso8601String(),
    );
  }

  /// Clear authentication
  Future<void> logout() async {
    await _storage.delete(key: 'spotify_access_token');
    await _storage.delete(key: 'spotify_token_expiry');
    _accessToken = null;
    _tokenExpiry = null;
  }

  /// Create a playlist based on mood
  Future<Playlist> createMoodPlaylist(MoodResult mood) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    // Get mood-based search parameters
    final params = _getMoodSearchParams(mood.label);

    // Search for tracks
    final tracks = await _searchTracks(
      seeds: params['seeds'] as List<String>,
      minEnergy: params['minEnergy'] as double,
      maxEnergy: params['maxEnergy'] as double,
      minTempo: params['minTempo'] as double,
      maxTempo: params['maxTempo'] as double,
    );

    // Create playlist
    final userId = await _getCurrentUserId();
    final playlistName = 'VibeLens: ${mood.label.displayName} Vibes';

    final playlistId = await _createPlaylist(userId, playlistName);
    await _addTracksToPlaylist(playlistId, tracks.map((t) => t.id).toList());

    return Playlist(
      id: playlistId,
      name: playlistName,
      tracks: tracks,
      coverImage: tracks.isNotEmpty ? tracks.first.albumArt : null,
      createdAt: DateTime.now(),
    );
  }

  /// Get mood-specific search parameters
  Map<String, dynamic> _getMoodSearchParams(MoodLabel mood) {
    switch (mood) {
      case MoodLabel.cozy:
        return {
          'seeds': ['acoustic', 'chill', 'lo-fi'],
          'minEnergy': 0.1,
          'maxEnergy': 0.4,
          'minTempo': 60.0,
          'maxTempo': 90.0,
        };
      case MoodLabel.energetic:
        return {
          'seeds': ['dance', 'upbeat', 'electronic'],
          'minEnergy': 0.7,
          'maxEnergy': 1.0,
          'minTempo': 110.0,
          'maxTempo': 140.0,
        };
      case MoodLabel.melancholic:
        return {
          'seeds': ['sad', 'melancholy', 'emotional'],
          'minEnergy': 0.1,
          'maxEnergy': 0.4,
          'minTempo': 50.0,
          'maxTempo': 80.0,
        };
      case MoodLabel.calm:
        return {
          'seeds': ['ambient', 'peaceful', 'meditation'],
          'minEnergy': 0.1,
          'maxEnergy': 0.3,
          'minTempo': 40.0,
          'maxTempo': 70.0,
        };
      case MoodLabel.nostalgic:
        return {
          'seeds': ['retro', '80s', 'throwback'],
          'minEnergy': 0.4,
          'maxEnergy': 0.7,
          'minTempo': 90.0,
          'maxTempo': 120.0,
        };
      case MoodLabel.romantic:
        return {
          'seeds': ['love', 'romantic', 'smooth'],
          'minEnergy': 0.3,
          'maxEnergy': 0.6,
          'minTempo': 70.0,
          'maxTempo': 100.0,
        };
    }
  }

  /// Search for tracks
  Future<List<Track>> _searchTracks({
    required List<String> seeds,
    required double minEnergy,
    required double maxEnergy,
    required double minTempo,
    required double maxTempo,
    int limit = 25,
  }) async {
    final tracks = <Track>[];

    for (final seed in seeds.take(3)) {
      final url = Uri.parse(
        '$baseUrl/search',
      ).replace(queryParameters: {'q': seed, 'type': 'track', 'limit': '10'});

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['tracks']['items'] as List;
        tracks.addAll(items.map((item) => Track.fromJson(item)));
      }
    }

    return tracks.take(limit).toList();
  }

  /// Get current user ID
  Future<String> _getCurrentUserId() async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['id'] as String;
    }

    throw Exception('Failed to get user ID');
  }

  /// Create a playlist
  Future<String> _createPlaylist(String userId, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/playlists'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'description': 'Generated by VibeLens - AI mood-based playlist',
        'public': false,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['id'] as String;
    }

    throw Exception('Failed to create playlist');
  }

  /// Add tracks to playlist
  Future<void> _addTracksToPlaylist(
    String playlistId,
    List<String> trackIds,
  ) async {
    final uris = trackIds.map((id) => 'spotify:track:$id').toList();

    await http.post(
      Uri.parse('$baseUrl/playlists/$playlistId/tracks'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'uris': uris}),
    );
  }
}
