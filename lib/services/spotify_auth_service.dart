import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../core/constants.dart';

/// One PKCE authorization attempt.
class SpotifyAuthRequest {
  const SpotifyAuthRequest(this.uri, this.verifier, this.state);
  final Uri uri;
  final String verifier;
  final String state;
}

class SpotifyToken {
  const SpotifyToken(this.accessToken, this.expiresIn);
  final String accessToken;
  final int expiresIn;
}

/// Spotify OAuth (PKCE): builds the authorize URL and exchanges the code.
class SpotifyAuthService {
  SpotifyAuthService._();
  static final instance = SpotifyAuthService._();

  static const _scope = 'playlist-modify-public playlist-modify-private '
      'user-read-private user-read-email';
  static const _unreserved =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

  final _random = Random.secure();

  String get clientId => dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';
  String get redirectUri =>
      dotenv.env['SPOTIFY_REDIRECT_URI'] ?? 'vibelens://callback';
  bool get isConfigured =>
      clientId.isNotEmpty && clientId != 'your_client_id_here';

  SpotifyAuthRequest createRequest() {
    final verifier = _randomString(64, '$_unreserved-._~');
    final challenge = base64UrlEncode(
      sha256.convert(utf8.encode(verifier)).bytes,
    ).replaceAll('=', '');
    final state = _randomString(32, _unreserved);
    final uri = Uri.parse(SpotifyApi.authUrl).replace(
      queryParameters: {
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': redirectUri,
        'code_challenge_method': 'S256',
        'code_challenge': challenge,
        'scope': _scope,
        'state': state,
        'show_dialog': 'true',
      },
    );
    return SpotifyAuthRequest(uri, verifier, state);
  }

  /// Throws [Exception] with a user-presentable message on failure.
  Future<SpotifyToken> exchangeCode(String code, String verifier) async {
    final response = await http.post(
      Uri.parse(SpotifyApi.tokenUrl),
      body: {
        'client_id': clientId,
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'code_verifier': verifier,
      },
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Unable to retrieve access token (${response.statusCode}).',
      );
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Access token missing in response.');
    }
    final expires = data['expires_in'];
    return SpotifyToken(
      token,
      expires is int ? expires : int.tryParse('$expires') ?? 3600,
    );
  }

  String _randomString(int n, String charset) =>
      List.generate(n, (_) => charset[_random.nextInt(charset.length)]).join();
}
