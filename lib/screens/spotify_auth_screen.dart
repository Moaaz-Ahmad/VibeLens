import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import '../services/spotify_auth_service.dart';
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
  final _auth = SpotifyAuthService.instance;
  StreamSubscription<Uri>? _linkSubscription;

  bool _isLoading = false;
  bool _hasHandledDeepLink = false;
  String? _error;
  String? _codeVerifier;
  String? _state;

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
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) => _handleDeepLink(uri),
      onError: (err) => Logger.error('Deep link error', err),
    );

    // Handle case where the app was opened by a deep link while terminated
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }).catchError((err) {
      Logger.error('Failed to retrieve initial deep link', err);
    });
  }

  void _handleDeepLink(Uri uri) {
    Logger.info('Received deep link: $uri');

    if (_hasHandledDeepLink) {
      Logger.warning('Deep link already processed, ignoring');
      return;
    }

    final error = uri.queryParameters['error'];
    if (error != null) {
      Logger.error('OAuth error: $error');
      setState(() {
        _error = 'Authentication failed: $error';
        _isLoading = false;
      });
      return;
    }

    final returnedState = uri.queryParameters['state'];
    if (_state != null && returnedState != _state) {
      Logger.error('State mismatch during OAuth callback');
      setState(() {
        _error = 'Authentication failed: State mismatch. Please try again.';
        _isLoading = false;
      });
      return;
    }

    final code = uri.queryParameters['code'];
    if (code != null && code.isNotEmpty) {
      _hasHandledDeepLink = true;
      Logger.info('Authorization code received, exchanging for token');
      _exchangeCodeForToken(code);
    } else {
      Logger.error('No authorization code found in callback');
      setState(() {
        _error = 'Authentication failed: No authorization code received.';
        _isLoading = false;
      });
    }
  }

  Future<void> _exchangeCodeForToken(String code) async {
    final verifier = _codeVerifier;
    if (verifier == null) {
      Logger.error('Code verifier missing during token exchange');
      setState(() {
        _error =
            'Authentication failed: Missing code verifier. Please try again.';
        _isLoading = false;
      });
      return;
    }

    try {
      final token = await _auth.exchangeCode(code, verifier);
      Logger.success('Access token obtained from Spotify');
      await _saveTokenAndReturn(token.accessToken, token.expiresIn);
    } catch (e) {
      Logger.error('Token exchange error', e);
      setState(() {
        _error = 'Authentication failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTokenAndReturn(String accessToken, int expiresIn) async {
    try {
      await _spotifyService.saveToken(accessToken, expiresIn);
      Logger.success('Spotify authentication successful');

      if (mounted) {
        _codeVerifier = null;
        _state = null;
        _hasHandledDeepLink = false;
        setState(() => _isLoading = false);
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
    if (!_auth.isConfigured) {
      Logger.error('Spotify Client ID not configured');
      setState(() {
        _error =
            'Spotify Client ID not configured. Please add SPOTIFY_CLIENT_ID to .env file.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final request = _auth.createRequest();
      _codeVerifier = request.verifier;
      _state = request.state;
      _hasHandledDeepLink = false;

      final launched = await launchUrl(
        request.uri,
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
                  style: TextStyle(color: Colors.white70, fontSize: 16),
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
                            _error!,
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
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
                    style: TextStyle(color: Colors.white70, fontSize: 16),
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
