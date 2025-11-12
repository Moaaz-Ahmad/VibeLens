import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme.dart';
import 'core/utils/logger.dart';
import 'screens/splash_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/results_screen.dart';
import 'screens/playlist_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/spotify_auth_screen.dart';
import 'screens/history_screen.dart';
import 'services/model_service.dart';
import 'services/camera_service.dart';
import 'services/history_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.info('🚀 Starting VibeLens...');

  try {
    // Load environment variables (use .env if exists, otherwise .env.example)
    try {
      await dotenv.load();
      Logger.success('Environment variables loaded from .env');
    } catch (e) {
      Logger.warning('.env not found, loading .env.example');
      await dotenv.load(fileName: '.env.example');
      Logger.warning(
          'Using .env.example - create .env file with your actual credentials');
    }

    // Lock orientation to portrait
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize services in parallel
    Logger.info('Initializing services...');
    await Future.wait([
      ModelService.instance.initialize(),
      CameraService.instance.initialize(),
      HistoryService.instance.initialize(),
    ]);
    Logger.success('All services initialized');

    runApp(const ProviderScope(child: VibeLensApp()));
  } catch (e, stack) {
    Logger.error('Failed to initialize app', e, stack);
    // Run app anyway to show error screen
    runApp(const ProviderScope(child: VibeLensApp()));
  }
}

class VibeLensApp extends StatelessWidget {
  const VibeLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibeLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/camera': (context) => const CameraScreen(),
        '/results': (context) => const ResultsScreen(),
        '/playlist': (context) => const PlaylistScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/spotify-auth': (context) => const SpotifyAuthScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}
