# VibeLens Architecture

## Overview

VibeLens is a Flutter mobile application that uses on-device AI to analyze visual scenes and generate mood-based Spotify playlists. Built with Flutter 3.16+, Material Design 3, and TensorFlow Lite.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Flutter App                           │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────────┐    │
│  │   Camera   │──│ Preprocessor │──│  TFLite Model    │    │
│  │   Screen   │  │   (Resize,   │  │  (MobileNetV2    │    │
│  └────────────┘  │  uint8)      │  │   6 classes)     │    │
│         │        └──────────────┘  └──────────────────┘    │
│         │                                     │              │
│         │                                     ↓              │
│         │                            ┌────────────────┐     │
│         │                            │  Mood Result   │     │
│         │                            │ + Confidence   │     │
│         │                            └────────────────┘     │
│         │                                     │              │
│         ↓                                     ↓              │
│  ┌─────────────┐                     ┌──────────────┐      │
│  │   Results   │◄────────────────────│   Spotify    │      │
│  │   Screen    │                     │   Service    │      │
│  └─────────────┘                     └──────────────┘      │
│         │                                     │              │
│         │                                     ↓              │
│         │                            ┌────────────────┐     │
│         │                            │ Spotify API    │     │
│         │                            └────────────────┘     │
│         │                                     │              │
│         ↓                                     ↓              │
│  ┌─────────────┐                     ┌──────────────┐      │
│  │  Playlist   │◄────────────────────│   Playlist   │      │
│  │   Screen    │                     │    Data      │      │
│  └─────────────┘                     └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. Frontend (Flutter/Dart)

#### Screens
- **SplashScreen**: App initialization, service loading
- **CameraScreen**: Live camera feed with capture button
- **ResultsScreen**: Mood visualization with gradients
- **PlaylistScreen**: Spotify playlist display
- **SettingsScreen**: App configuration
- **SpotifyAuthScreen**: OAuth authentication

#### State Management (Riverpod)
- Camera state provider
- Mood result provider  
- Playlist provider
- Authentication provider

#### Core Infrastructure (NEW)
- **AppConstants** (`lib/core/constants.dart`): Centralized app configuration
- **AppTheme** (`lib/core/theme.dart`): Material Design 3 theme
- **Logger** (`lib/core/utils/logger.dart`): Standardized logging utility

### 2. ML Pipeline

#### On-Device Inference
```
Image (224x224x3 uint8) → TFLite Model → uint8 output → Normalized probs → Mood Label
```

**Current Model:**
- **MobileNetV2**: Pre-trained on ImageNet, adapted for 6 mood classes
- **Size**: ~3-5MB (TFLite quantized)
- **Input**: 224×224×3 uint8 tensor
- **Output**: 6 uint8 values (0-255), normalized to probabilities
- **Inference time**: ~700ms on Android emulator

**Preprocessing:**
```dart
1. Load image from file
2. Decode image bytes
3. Resize to 224×224 (cubic interpolation)
4. Convert RGB to uint8 [0-255]  // NO normalization needed
5. Format as [1, 224, 224, 3] tensor
```

**Postprocessing:**
```dart
1. Receive uint8 output [0-255] for 6 classes
2. Convert to double: value / 255.0
3. Normalize to sum = 1.0 (softmax-like)
4. Find argmax for predicted mood
5. Return MoodResult with probabilities
```

**Inference Flow:**
```dart
ModelService.predictMood(imagePath)
  → _preprocessImage() returns List<List<List<List<int>>>>
  → interpreter.run(imageData, output)
  → output: List<List<int>> (uint8)
  → normalize probabilities
  → return MoodResult(label, confidence, embedding)
```

### 3. Spotify Integration

#### Authentication Flow
```
1. User taps "Login with Spotify"
2. App opens Spotify auth URL
3. User approves permissions
4. Redirect to vibelens://callback
5. Exchange auth code for tokens
6. Store tokens in SecureStorage
```

**OAuth Configuration:**
- Client ID & Secret from Spotify Developer Dashboard
- Redirect URI: `vibelens://callback`
- Scopes: `playlist-modify-public`, `playlist-modify-private`

#### Playlist Generation (Planned)
```
MoodResult → Mood Parameters → Spotify Search → Create Playlist
```

**Mood Mapping:**

| Mood         | Spotify Seeds            | Energy  | Valence |
|--------------|--------------------------|---------|---------|
| Cozy         | acoustic, chill, indie   | 0.2-0.4 | 0.4-0.6 |
| Energetic    | dance, electronic, pop   | 0.7-0.9 | 0.6-0.8 |
| Melancholic  | sad, ambient, piano      | 0.1-0.3 | 0.1-0.3 |
| Calm         | ambient, classical, spa  | 0.1-0.3 | 0.5-0.7 |
| Nostalgic    | retro, 80s, vintage      | 0.4-0.6 | 0.4-0.6 |
| Romantic     | love, r-n-b, smooth-jazz | 0.3-0.5 | 0.6-0.8 |

### 4. Services Architecture

#### ModelService
```dart
class ModelService {
  static final instance = ModelService._internal();
  Interpreter? _interpreter;
  
  Future<void> initialize()
  Future<MoodResult> predictMood(String imagePath)
  Future<Map<MoodLabel, double>> getPredictions(String imagePath)
  void dispose()
  Map<String, dynamic> getModelInfo()
}
```

#### CameraService
```dart
class CameraService {
  static final instance = CameraService._internal();
  CameraController? controller;
  
  Future<void> initialize()
  Future<String> captureImage()
  void dispose()
}
```

#### SpotifyService
```dart
class SpotifyService {
  Future<void> authenticate()
  Future<void> refreshToken()
  Future<Playlist> createMoodPlaylist(MoodLabel mood)
  Future<List<Track>> searchTracks(String query)
}
```

## Data Models

### MoodResult
```dart
class MoodResult {
  final MoodLabel label;           // Enum: cozy, energetic, etc.
  final double confidence;          // 0.0 - 1.0
  final List<double> embedding;     // All 6 probabilities
  final DateTime timestamp;
  final int inferenceTimeMs;
}
```

### MoodLabel
```dart
enum MoodLabel {
  cozy,
  energetic,
  melancholic,
  calm,
  nostalgic,
  romantic,
}
```

## Data Flow

### 1. App Launch Flow
```
main()
  → Load environment variables (.env)
  → Initialize ModelService (load TFLite model)
  → Initialize CameraService (setup camera)
  → Navigate to SplashScreen → CameraScreen
```

### 2. Capture & Inference Flow
```
User taps "Capture Mood"
  → CameraService.captureImage()
  → Save to temporary file
  → ModelService.predictMood(path)
    → Preprocess image (resize to 224×224 uint8)
    → Run TFLite inference
    → Normalize uint8 output to probabilities
    → Return MoodResult
  → Navigate to ResultsScreen with MoodResult
  → Display mood with gradient + confidence
```

### 3. Playlist Generation Flow (Planned)
```
User taps "Generate Playlist"
  → Check Spotify auth status
  → If not authenticated:
    → Navigate to SpotifyAuthScreen
    → Complete OAuth flow
  → SpotifyService.createMoodPlaylist(mood)
    → Map mood to search parameters
    → Search for tracks
    → Create playlist
    → Add tracks
  → Navigate to PlaylistScreen with Playlist data
```

## Performance Considerations

### Current Performance
- **Inference time**: ~700ms (Android emulator)
- **Model size**: ~3-5MB (TFLite)
- **App size**: ~45MB (debug APK)
- **Memory usage**: <100MB

### Optimization Strategies

1. **Model Optimization**
   - ✅ uint8 quantization implemented
   - 🔄 Post-training quantization for smaller size
   - 📅 Dynamic range quantization planned

2. **Image Preprocessing**
   - ✅ Cubic interpolation for resize
   - ✅ uint8 format (no float conversion)
   - 🔄 Consider native resizing for speed

3. **UI Performance**
   - ✅ Material Design 3 components
   - ✅ Custom gradients for moods
   - 🔄 Lazy loading for playlist images
   - 🔄 Virtual scrolling for long lists

4. **Caching Strategy**
   - 📅 Cache API responses (24h TTL)
   - 📅 Store mood history locally
   - 📅 Prefetch common playlists

## Security & Privacy

### Data Handling
- **Camera frames**: Processed on-device only, never uploaded
- **Images**: Deleted after inference completes
- **Auth tokens**: Stored in FlutterSecureStorage (AES encrypted)
- **User data**: Minimal collection, no analytics tracking

### Permissions
- **Camera**: Required for core functionality
- **Internet**: Required for Spotify API
- **Storage**: Optional, for caching playlists

### Security Measures
- ✅ OAuth 2.0 with PKCE flow
- ✅ Secure token storage
- ✅ HTTPS-only API calls
- ✅ No hardcoded credentials (uses .env)

## Testing Strategy

### Unit Tests (22 passing ✅)
- AppConstants validation
- AppTheme configuration
- Mood gradient arrays
- Spacing and animation durations

### Widget Tests (Planned)
- Screen rendering
- User interactions
- Navigation flows
- Error states

### Integration Tests (Planned)
- End-to-end: capture → inference → results
- Spotify OAuth flow
- Error handling and recovery

## Deployment

### Android
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build appbundle --release

# Configuration
# - minSdkVersion: 21 (Android 5.0)
# - targetSdkVersion: 34
# - Permissions: CAMERA, INTERNET
```

### iOS (Planned)
```bash
# Release build
flutter build ios --release

# Configuration
# - iOS 12.0+
# - Camera usage description required
```

## Current Implementation Status

### ✅ Completed
- Flutter app scaffold with Material Design 3
- Camera integration with permission handling
- TFLite model service (uint8 input/output)
- Pre-trained MobileNetV2 (adapted for 6 moods)
- Model conversion pipeline (PyTorch → ONNX → TFLite)
- Results screen with mood visualization
- Centralized constants and theme
- Logger utility for debugging
- 22 passing unit tests
- Spotify OAuth configuration

### 🔄 In Progress
- Full Spotify playlist generation
- Playlist playback UI
- Mood history tracking

### 📅 Planned
- Custom model training on dataset
- Performance optimization (<200ms inference)
- Comprehensive integration tests
- App store deployment
- Offline mode with cached playlists

## Future Enhancements

1. **Multi-frame analysis**: Average mood over video clip
2. **Custom mood creation**: User-defined moods and mappings
3. **Social features**: Share mood + playlist with friends
4. **Apple Music integration**: Alternative to Spotify
5. **Real-time mode**: Continuous mood tracking
6. **Mood journal**: Track mood history over time
7. **Widget support**: Home screen mood widget

## Tech Stack Summary

| Layer          | Technology              | Version  | Purpose                    |
|----------------|-------------------------|----------|----------------------------|
| Frontend       | Flutter                 | 3.16+    | Cross-platform UI          |
| Language       | Dart                    | 3.2+     | App logic                  |
| State          | Riverpod                | 2.4+     | State management           |
| ML Runtime     | TensorFlow Lite         | 0.11.0   | On-device inference        |
| ML Model       | MobileNetV2             | Custom   | Mood classification        |
| Storage        | flutter_secure_storage  | 9.0.0    | Encrypted tokens           |
| HTTP           | dio + http              | Latest   | API communication          |
| Auth           | flutter_appauth         | 6.0.4    | OAuth 2.0 flow             |
| Camera         | camera                  | 0.10.5   | Native camera access       |
| Environment    | flutter_dotenv          | 5.1.0    | Environment variables      |
| UI Framework   | Material Design 3       | Built-in | Modern UI components       |

## File Structure

```
lib/
├── main.dart                   # App entry point
├── core/
│   ├── constants.dart          # AppConstants (model config, UI values)
│   ├── theme.dart              # AppTheme (colors, gradients, theme data)
│   └── utils/
│       └── logger.dart         # Logger utility with emoji prefixes
├── models/
│   └── mood_result.dart        # MoodResult, MoodLabel enum
├── services/
│   ├── model_service.dart      # TFLite inference (uint8 handling)
│   ├── camera_service.dart     # Camera controller wrapper
│   └── spotify_service.dart    # Spotify API integration
├── screens/
│   ├── splash_screen.dart      # Initial loading screen
│   ├── camera_screen.dart      # Main camera interface
│   ├── results_screen.dart     # Mood display with gradients
│   ├── playlist_screen.dart    # Spotify playlist view
│   ├── settings_screen.dart    # App settings
│   └── spotify_auth_screen.dart # OAuth flow
└── widgets/                    # Reusable UI components
```

## References

- [TFLite Model Optimization](https://www.tensorflow.org/lite/performance/model_optimization)
- [Spotify Web API](https://developer.spotify.com/documentation/web-api/)
- [Flutter Camera Plugin](https://pub.dev/packages/camera)
- [Material Design 3](https://m3.material.io/)
- [MobileNetV2 Paper](https://arxiv.org/abs/1801.04381)
