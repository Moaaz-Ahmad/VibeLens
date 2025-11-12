import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import '../services/spotify_service.dart';

class SpotifyAuthScreen extends StatefulWidget {
  const SpotifyAuthScreen({super.key});

  @override
  State<SpotifyAuthScreen> createState() => _SpotifyAuthScreenState();
}

class _SpotifyAuthScreenState extends State<SpotifyAuthScreen> {
  final _appAuth = const FlutterAppAuth();
  final _spotifyService = SpotifyService.instance;

  bool _isLoading = false;
  String? _error;

  // TODO: Replace with your Spotify credentials from .env
  static const String clientId = String.fromEnvironment(
    'SPOTIFY_CLIENT_ID',
    defaultValue: 'YOUR_SPOTIFY_CLIENT_ID',
  );
  static const String redirectUri = 'vibelens://callback';
  static const String authorizationEndpoint =
      'https://accounts.spotify.com/authorize';
  static const String tokenEndpoint = 'https://accounts.spotify.com/api/token';

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final isAuth = await _spotifyService.isAuthenticated();
    if (isAuth && mounted) {
      // Already authenticated, return to previous screen
      Navigator.pop(context, true);
    }
  }

  Future<void> _authenticate() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Perform OAuth authorization
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUri,
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: authorizationEndpoint,
            tokenEndpoint: tokenEndpoint,
          ),
          scopes: [
            'playlist-modify-public',
            'playlist-modify-private',
            'user-read-private',
            'user-read-email',
          ],
        ),
      );

      if (result != null && result.accessToken != null) {
        // Save token
        await _spotifyService.saveToken(
          result.accessToken!,
          result.accessTokenExpirationDateTime
                  ?.difference(DateTime.now())
                  .inSeconds ??
              3600,
        );

        if (mounted) {
          // Success - return to previous screen
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1DB954), // Spotify green
              Color(0xFF191414), // Spotify black
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const Spacer(),

                // Spotify logo
                const Icon(
                  Icons.music_note_rounded,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Connect Spotify',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Connect your Spotify account to create personalized mood playlists',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                const Spacer(),

                // Error message
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Authentication failed. Please try again.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Connect button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DB954),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Connect with Spotify',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Skip button
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
