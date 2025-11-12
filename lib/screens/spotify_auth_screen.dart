import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/spotify_service.dart';
import '../core/utils/logger.dart';

class SpotifyAuthScreen extends StatefulWidget {
  const SpotifyAuthScreen({super.key});

  @override
  State<SpotifyAuthScreen> createState() => _SpotifyAuthScreenState();
}

class _SpotifyAuthScreenState extends State<SpotifyAuthScreen> {
  final _spotifyService = SpotifyService.instance;
  final _appLinks = AppLinks();
  StreamSubscription? _linkSubscription;

  bool _isLoading = false;
  String? _error;

  // Load Spotify credentials from .env file
  String get clientId => dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';
  String get redirectUri =>
      dotenv.env['SPOTIFY_REDIRECT_URI'] ?? 'vibelens://callback';

  static const String authorizationEndpoint =
      'https://accounts.spotify.com/authorize';

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinkListener() {
    // Listen for deep link callbacks
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      Logger.error('Deep link error', err);
    });
  }

  void _handleDeepLink(Uri uri) {
    Logger.info('Received deep link: $uri');

    // Extract access token from URI fragment (implicit grant flow)
    // Format: vibelens://callback#access_token=...&token_type=Bearer&expires_in=3600
    final fragment = uri.fragment;
    
    if (fragment.isNotEmpty) {
      final params = Uri.splitQueryString(fragment);
      final accessToken = params['access_token'];
      final expiresIn = int.tryParse(params['expires_in'] ?? '3600') ?? 3600;

      if (accessToken != null && accessToken.isNotEmpty) {
        Logger.success('Access token received from deep link');
        _saveTokenAndReturn(accessToken, expiresIn);
      } else {
        Logger.error('No access token in deep link');
        setState(() {
          _error = 'Authentication failed: No access token received';
          _isLoading = false;
        });
      }
    } else if (uri.queryParameters.containsKey('error')) {
      final error = uri.queryParameters['error'];
      Logger.error('OAuth error: $error');
      setState(() {
        _error = 'Authentication failed: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTokenAndReturn(String accessToken, int expiresIn) async {
    try {
      await _spotifyService.saveToken(accessToken, expiresIn);
      Logger.success('Spotify authentication successful');

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      Logger.error('Failed to save token', e);
      setState(() {
        _error = 'Failed to save authentication';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAuthentication() async {
    final isAuth = await _spotifyService.isAuthenticated();
    if (isAuth && mounted) {
      // Already authenticated, return to previous screen
      Navigator.pop(context, true);
    }
  }

  Future<void> _authenticate() async {
    // Debug: Log what we're loading from .env
    Logger.info(
        'SPOTIFY_CLIENT_ID from .env: ${dotenv.env['SPOTIFY_CLIENT_ID']}');
    Logger.info(
        'SPOTIFY_REDIRECT_URI from .env: ${dotenv.env['SPOTIFY_REDIRECT_URI']}');
    Logger.info('Computed clientId: $clientId');
    Logger.info('Computed redirectUri: $redirectUri');

    // Check if client ID is configured
    if (clientId.isEmpty || clientId == 'your_client_id_here') {
      setState(() {
        _error =
            'Spotify Client ID not configured. Please add SPOTIFY_CLIENT_ID to .env file.';
        _isLoading = false;
      });
      Logger.error('Spotify Client ID not configured');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Logger.info(
          'Starting Spotify authentication with Client ID: ${clientId.substring(0, 8)}...');
      Logger.info('Using redirect URI: $redirectUri');

      // Build Spotify authorization URL with implicit grant flow
      final scopes = [
        'playlist-modify-public',
        'playlist-modify-private',
        'user-read-private',
        'user-read-email',
      ].join('%20');

      final authUrl = Uri.parse(
        '$authorizationEndpoint?'
        'client_id=$clientId&'
        'response_type=token&'
        'redirect_uri=${Uri.encodeComponent(redirectUri)}&'
        'scope=$scopes&'
        'show_dialog=true',
      );

      Logger.info('Opening auth URL: ${authUrl.toString().substring(0, 100)}...');

      // Launch Spotify authorization page
      final launched = await launchUrl(
        authUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not launch Spotify authorization URL');
      }

      Logger.info('Auth URL launched, waiting for callback...');
    } catch (e) {
      Logger.error('Spotify authentication failed', e);
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
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _error!.contains('SPOTIFY_CLIENT_ID')
                                ? _error!
                                : 'Authentication failed. Please check your Spotify Client ID and try again.',
                            style: const TextStyle(color: Colors.white),
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
