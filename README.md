# VibeLens — AI Mood-Based Music Discovery

> Point your camera at a scene. Capture its mood. Get a perfect Spotify playlist.

VibeLens uses on-device AI to analyze visual scenes and generate personalized music playlists that match the emotional atmosphere of your surroundings.

## ✨ Features

- **🤖 On-device AI** — Privacy-first mood detection using TensorFlow Lite
- **📸 Real-time camera** — Instant mood classification from your surroundings  
- **🎵 Spotify integration** — Automatic playlist generation based on detected mood
- **🎨 Mood visualization** — Beautiful gradients that reflect detected emotions
- **⚡ Fast & lightweight** — <800ms inference, Material Design 3 UI

## 🏗️ Architecture

```
Camera Frame → TFLite Model (MobileNetV2) → Mood Classification → Spotify API → Playlist
```

**Tech Stack:**

- **Frontend:** Flutter 3.16+ with Material Design 3
- **ML Model:** Pre-trained MobileNetV2 (adapted for 6 mood classes)
- **ML Runtime:** TensorFlow Lite (uint8 quantized)
- **APIs:** Spotify Web API
- **State:** Riverpod 2.4+
- **Storage:** flutter_secure_storage

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.16+
- Dart 3.2+
- Android Studio / Xcode
- Python 3.9-3.13 (for model training/conversion)
- Spotify Developer Account

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/vibelens.git
cd vibelens

# Install Flutter dependencies
flutter pub get

# Create .env file with Spotify credentials
cp .env.example .env
# Edit .env and add your Spotify Client ID and Secret

# Run the app
flutter run
```

### Model Setup (Optional - Pre-trained model included)

The app comes with a pre-trained MobileNetV2 model. To retrain:

```bash
cd ml
pip install -r requirements.txt

# Use pre-trained MobileNetV2
python use_pretrained.py

# Test the model
python test_pretrained.py --image path/to/image.jpg

# Convert to TFLite (use Google Colab for Python 3.9 compatibility)
# Upload colab_tflite_conversion.ipynb to Colab
# Follow instructions in PRETRAINED_QUICKSTART.md
```

## 📱 Usage

1. **Launch app** and grant camera permissions
2. **Point camera** at any scene (workspace, window view, café, etc.)
3. **Tap "Capture Mood"** to analyze the scene
4. **View results** — See detected mood with confidence score
5. **Generate playlist** — Get Spotify recommendations (requires auth)

## 🎨 Mood Categories

| Mood | Emoji | Description | Gradient |
|------|-------|-------------|----------|
| **Cozy** | 🛋️ | Warm, comfortable, intimate | Orange-Red |
| **Energetic** | ⚡ | Dynamic, vibrant, high-energy | Yellow-Green |
| **Melancholic** | 🌧️ | Reflective, somber, introspective | Gray-Blue |
| **Calm** | 🌊 | Peaceful, serene, tranquil | Light Blue |
| **Nostalgic** | 📸 | Sentimental, vintage, reminiscent | Sepia-Brown |
| **Romantic** | 💕 | Loving, intimate, tender | Pink-Red |

## 🧪 Current Status

| Feature | Status |
|---------|--------|
| Pre-trained MobileNetV2 model | ✅ Complete |
| TFLite conversion | ✅ Complete |
| Flutter app with camera | ✅ Complete |
| Mood detection (uint8) | ✅ Complete |
| UI with mood gradients | ✅ Complete |
| Spotify OAuth setup | ✅ Complete |
| Widget tests (22 passing) | ✅ Complete |
| Production model training | 🔄 In progress |
| Full Spotify integration | 🔄 In progress |

**Latest Updates:**

- ✅ Fixed uint8 input/output data type handling
- ✅ Refactored code with centralized constants and theme
- ✅ Added comprehensive logging with Logger utility
- ✅ Created 22 passing unit tests
- ✅ App running successfully on Android emulator

## 🛠️ Development

### Project Structure

```
vibelens/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── core/
│   │   ├── constants.dart        # App-wide constants
│   │   ├── theme.dart            # Material Design 3 theme
│   │   └── utils/
│   │       └── logger.dart       # Logging utility
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── camera_screen.dart
│   │   ├── results_screen.dart
│   │   ├── playlist_screen.dart
│   │   └── settings_screen.dart
│   ├── services/
│   │   ├── model_service.dart    # TFLite inference
│   │   ├── camera_service.dart   # Camera handling
│   │   └── spotify_service.dart  # Spotify API
│   ├── models/
│   │   └── mood_result.dart      # Data models
│   └── widgets/                  # Reusable components
├── ml/
│   ├── use_pretrained.py         # Download pre-trained model
│   ├── test_pretrained.py        # Test model locally
│   ├── colab_tflite_conversion.ipynb  # Convert to TFLite
│   └── models/
│       └── checkpoints/
│           └── pretrained_mobilenet_mood.pth
├── assets/
│   └── models/
│       └── mood_classifier.tflite  # Deployed model
├── test/
│   └── widget_test.dart          # 22 passing tests
├── android/                      # Android config
├── ios/                          # iOS config
└── .env                          # Spotify credentials
```

### Running Tests

```bash
# Run all tests (22 tests)
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

### Building Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (requires Mac)
flutter build ios --release
```

## 🔐 Spotify API Setup

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new app
3. Add redirect URI: `vibelens://callback`
4. Copy Client ID and Client Secret
5. Create `.env` file in project root:

```env
SPOTIFY_CLIENT_ID=your_client_id_here
SPOTIFY_CLIENT_SECRET=your_client_secret_here
SPOTIFY_REDIRECT_URI=vibelens://callback
```

## 📚 Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** — Technical architecture details
- **[PRETRAINED_QUICKSTART.md](PRETRAINED_QUICKSTART.md)** — Quick start with pre-trained model
- **[PRETRAINED_IMPLEMENTATION.md](PRETRAINED_IMPLEMENTATION.md)** — Implementation details
- **[REFACTORING_COMPLETE.md](REFACTORING_COMPLETE.md)** — Code refactoring summary
- **[APP_LAUNCH_STATUS.md](APP_LAUNCH_STATUS.md)** — App launch guide
- **[NEXT_STEPS.md](NEXT_STEPS.md)** — Development roadmap

## 🐛 Troubleshooting

### Model Inference Error
If you see "invalid argument: input element is double while tensor data type is uint8":

- ✅ Fixed in current version
- Model expects uint8 (0-255), preprocessing converts images correctly

### Camera Permission Denied

- Grant camera permission in Android settings
- For emulator, ensure virtual camera is enabled

### Spotify Auth Failed

- Verify credentials in `.env` file
- Check redirect URI matches dashboard settings
- Ensure internet connection is active

## 📊 Performance Metrics

| Metric | Current | Target |
|--------|---------|--------|
| Inference time | ~700ms | <200ms |
| Model size (TFLite) | ~3-5MB | <15MB |
| App size (APK debug) | ~45MB | <60MB |
| Test coverage | 22 tests | >50 tests |

## 🗺️ Roadmap

### Phase 1: MVP ✅

- [x] Flutter app scaffold
- [x] Camera integration
- [x] Pre-trained MobileNetV2
- [x] TFLite inference
- [x] Basic UI with mood display
- [x] Unit tests

### Phase 2: Features 🔄

- [x] Spotify OAuth setup
- [ ] Full playlist generation
- [ ] Playlist playback
- [ ] Settings screen
- [ ] Mood history

### Phase 3: Polish 📅

- [ ] Custom model training on dataset
- [ ] Performance optimization
- [ ] UI/UX refinements
- [ ] Integration tests
- [ ] Beta release

## 🤝 Contributing

This is a portfolio/learning project. Feel free to fork and experiment!

## 📄 License

MIT License — see [LICENSE](LICENSE) file

---

**Built with Flutter 💙 | On-device AI 🧠 | Music discovery 🎵**
