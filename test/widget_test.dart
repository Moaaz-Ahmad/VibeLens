// VibeLens Widget Tests
//
// Basic widget tests for VibeLens app functionality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vibelens/core/theme.dart';
import 'package:vibelens/core/constants.dart';

void main() {
  group('AppTheme tests', () {
    test('has correct primary color', () {
      expect(AppTheme.primaryColor, const Color(0xFF6366F1));
    });

    test('has correct background color', () {
      expect(AppTheme.backgroundColor, const Color(0xFF0F0F0F));
    });

    test('has correct surface color', () {
      expect(AppTheme.surfaceColor, const Color(0xFF1A1A1A));
    });

    test('has 6 mood gradients', () {
      expect(AppTheme.moodGradients.length, 6);
    });

    test('each mood gradient has 3 colors', () {
      for (final gradient in AppTheme.moodGradients) {
        expect(gradient.length, 3);
      }
    });

    test('darkTheme uses Material 3', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, true);
    });

    test('darkTheme has dark brightness', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
    });

    test('darkTheme uses correct background color', () {
      final theme = AppTheme.darkTheme;
      expect(theme.scaffoldBackgroundColor, AppTheme.backgroundColor);
    });
  });

  group('AppConstants tests', () {
    test('model path is correct', () {
      expect(AppConstants.modelPath, 'assets/models/mood_classifier.tflite');
    });

    test('model input size is 224', () {
      expect(AppConstants.modelInputSize, 224);
    });

    test('model has 6 classes', () {
      expect(AppConstants.modelClasses, 6);
    });

    test('has 6 mood labels', () {
      expect(AppConstants.moodLabels.length, 6);
    });

    test('mood labels are correct', () {
      expect(
        AppConstants.moodLabels,
        [
          'Cozy',
          'Energetic',
          'Melancholic',
          'Calm',
          'Nostalgic',
          'Romantic',
        ],
      );
    });

    test('has 6 mood emojis', () {
      expect(AppConstants.moodEmojis.length, 6);
    });

    test('has mood descriptions for all labels', () {
      for (final label in AppConstants.moodLabels) {
        expect(AppConstants.moodDescriptions.containsKey(label), true);
        expect(AppConstants.moodDescriptions[label], isNotNull);
        expect(AppConstants.moodDescriptions[label]!.isNotEmpty, true);
      }
    });

    test('Spotify auth URL is valid', () {
      expect(AppConstants.spotifyAuthUrl.startsWith('https://'), true);
    });

    test('spacing values are positive', () {
      expect(AppConstants.spacingM, greaterThan(0));
    });

    test('animation durations are reasonable', () {
      expect(
        AppConstants.shortAnimation.inMilliseconds,
        greaterThanOrEqualTo(100),
      );
      expect(
        AppConstants.longAnimation.inMilliseconds,
        lessThanOrEqualTo(1000),
      );
    });
  });

  group('Theme configuration tests', () {
    test('card border radius is reasonable', () {
      expect(AppConstants.cardBorderRadius, greaterThan(0));
      expect(AppConstants.cardBorderRadius, lessThanOrEqualTo(32));
    });

    test('button border radius is positive', () {
      expect(AppConstants.buttonBorderRadius, greaterThan(0));
    });

    test('theme has status colors', () {
      expect(AppTheme.successColor, isA<Color>());
      expect(AppTheme.errorColor, isA<Color>());
      expect(AppTheme.warningColor, isA<Color>());
      expect(AppTheme.infoColor, isA<Color>());
    });

    test('theme has text colors', () {
      expect(AppTheme.textPrimary, isA<Color>());
      expect(AppTheme.textSecondary, isA<Color>());
      expect(AppTheme.textTertiary, isA<Color>());
    });
  });
}
