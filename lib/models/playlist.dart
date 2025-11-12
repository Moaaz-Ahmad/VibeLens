/// Spotify track model
class Track {
  final String id;
  final String name;
  final String artist;
  final String albumArt;
  final String? previewUrl;
  final String spotifyUrl;
  final int durationMs;

  const Track({
    required this.id,
    required this.name,
    required this.artist,
    required this.albumArt,
    this.previewUrl,
    required this.spotifyUrl,
    required this.durationMs,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as String,
      name: json['name'] as String,
      artist: (json['artists'] as List).first['name'] as String,
      albumArt: json['album']['images'][0]['url'] as String,
      previewUrl: json['preview_url'] as String?,
      spotifyUrl: json['external_urls']['spotify'] as String,
      durationMs: json['duration_ms'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'artist': artist,
    'albumArt': albumArt,
    'previewUrl': previewUrl,
    'spotifyUrl': spotifyUrl,
    'durationMs': durationMs,
  };
}

/// Playlist model
class Playlist {
  final String id;
  final String name;
  final List<Track> tracks;
  final String? coverImage;
  final DateTime createdAt;

  const Playlist({
    required this.id,
    required this.name,
    required this.tracks,
    this.coverImage,
    required this.createdAt,
  });

  int get totalDurationMs =>
      tracks.fold(0, (sum, track) => sum + track.durationMs);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tracks': tracks.map((t) => t.toJson()).toList(),
    'coverImage': coverImage,
    'createdAt': createdAt.toIso8601String(),
  };
}
