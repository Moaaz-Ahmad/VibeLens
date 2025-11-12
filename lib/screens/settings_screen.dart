import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/spotify_service.dart';
import '../services/history_service.dart';
import '../core/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _spotifyService = SpotifyService.instance;
  final _historyService = HistoryService.instance;

  bool _isSpotifyConnected = false;
  bool _enableHistory = true;
  bool _enableAnimations = true;
  int _playlistLength = 20;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final isConnected = await _spotifyService.isAuthenticated();

    if (mounted) {
      setState(() {
        _isSpotifyConnected = isConnected;
        _enableHistory = prefs.getBool('enableHistory') ?? true;
        _enableAnimations = prefs.getBool('enableAnimations') ?? true;
        _playlistLength = prefs.getInt('playlistLength') ?? 20;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  Future<void> _disconnectSpotify() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Spotify'),
        content: const Text(
          'Are you sure you want to disconnect your Spotify account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _spotifyService.logout();
      setState(() => _isSpotifyConnected = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spotify account disconnected')),
        );
      }
    }
  }

  Future<void> _connectSpotify() async {
    final result = await Navigator.pushNamed(context, '/spotify-auth');
    if (result == true) {
      setState(() => _isSpotifyConnected = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.music_note, color: Colors.green),
            title: const Text('Spotify'),
            subtitle: Text(
              _isSpotifyConnected ? 'Connected' : 'Not connected',
            ),
            trailing: _isSpotifyConnected
                ? TextButton(
                    onPressed: _disconnectSpotify,
                    child: const Text('Disconnect'),
                  )
                : ElevatedButton(
                    onPressed: _connectSpotify,
                    child: const Text('Connect'),
                  ),
          ),

          const Divider(),

          // Playlist Settings
          _buildSectionHeader('Playlist'),
          ListTile(
            leading: const Icon(Icons.playlist_play),
            title: const Text('Default Playlist Length'),
            subtitle: Text('$_playlistLength tracks'),
            trailing: DropdownButton<int>(
              value: _playlistLength,
              items: [10, 15, 20, 25, 30, 50].map((length) {
                return DropdownMenuItem(
                  value: length,
                  child: Text('$length tracks'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _playlistLength = value);
                  _saveSetting('playlistLength', value);
                }
              },
            ),
          ),

          const Divider(),

          // Privacy & Data
          _buildSectionHeader('Privacy & Data'),
          SwitchListTile(
            secondary: const Icon(Icons.history),
            title: const Text('Enable Mood History'),
            subtitle: const Text('Save mood detections locally'),
            value: _enableHistory,
            onChanged: (value) {
              setState(() => _enableHistory = value);
              _saveSetting('enableHistory', value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Clear Mood History'),
            subtitle: const Text('Delete all saved mood detections'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text(
                    'Are you sure? This cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && mounted) {
                await _historyService.clearHistory();
                messenger.showSnackBar(
                  const SnackBar(content: Text('History cleared')),
                );
              }
            },
          ),

          const Divider(),

          // Appearance
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.animation),
            title: const Text('Enable Animations'),
            subtitle: const Text('Smooth transitions and effects'),
            value: _enableAnimations,
            onChanged: (value) {
              setState(() => _enableAnimations = value);
              _saveSetting('enableAnimations', value);
            },
          ),

          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About VibeLens'),
            subtitle: const Text('Version 0.1.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'VibeLens',
                applicationVersion: '0.1.0',
                applicationIcon: const Icon(Icons.camera_alt, size: 48),
                children: [
                  const Text(
                    'AI-powered mood detection and playlist generation app.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Point your camera at a scene and get a perfectly matched playlist based on the mood.',
                  ),
                ],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Source Code'),
            subtitle: const Text('View on GitHub'),
            onTap: () {
              launchUrl(
                Uri.parse('https://github.com/Moaaz-Ahmad/VibeLens'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Privacy Policy'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'VibeLens Privacy Policy\n\n'
                      '1. Data Collection\n'
                      '- Camera images are processed locally on your device\n'
                      '- No images are uploaded or stored\n'
                      '- Mood detection happens entirely offline\n\n'
                      '2. Spotify Integration\n'
                      '- Your Spotify credentials are stored securely\n'
                      '- We only access your public profile and playlists\n'
                      '- No personal data is shared with third parties\n\n'
                      '3. Local Storage\n'
                      '- Mood history is stored locally on your device\n'
                      '- You can clear history anytime from settings\n'
                      '- No data is sent to external servers\n\n'
                      '4. Your Rights\n'
                      '- Full control over your data\n'
                      '- Can disconnect Spotify anytime\n'
                      '- Can clear all local data',
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
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Help & Support'),
                  content: const SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Getting Started',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. Connect your Spotify account\n'
                          '2. Point camera at a scene\n'
                          '3. Capture the mood\n'
                          '4. Get your personalized playlist',
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Common Issues',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Camera not working: Check app permissions\n'
                          '• Spotify not connecting: Check internet connection\n'
                          '• No playlists: Connect Spotify account first',
                        ),
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
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
