# VibeLens — AI Mood-Based Music Discovery

> Point your camera at a scene. Capture its mood. Get a perfect Spotify playlist.

VibeLens uses on-device AI to analyze visual scenes and generate personalized music playlists that match the emotional atmosphere of your surroundings.

## ✨ Features

- **🤖 On-device AI** — Privacy-first mood detection using TensorFlow Lite
- **📸 Real-time camera** — Instant mood classification from your surroundings  
- **🎵 Spotify integration** — OAuth authentication and automatic playlist generation
- **📊 Mood history** — Track your mood detections with statistics and filtering
- **🎨 Mood visualization** — Beautiful gradients and animations that reflect emotions
- **⚙️ Comprehensive settings** — Manage Spotify, preferences, and privacy
- **⚡ Fast & lightweight** — <800ms inference, Material Design 3 UI
- **💾 Local storage** — All data stored securely on your device

## 🏗️ Architecture

```
Camera Frame → TFLite Model (MobileNetV2) → Mood Classification → Spotify API → Playlist
```

**Tech Stack:**

- **Frontend:** Flutter 3.35.7 with Material Design 3
- **ML Model:** Keras `MobileNetV2` (ImageNet backbone) + 6-class mood head — **head must be trained, see below**
- **ML Runtime:** TensorFlow Lite (float32 or uint8; types/shapes read from the model)
- **APIs:** Spotify Web API with OAuth 2.0 (PKCE)
- **State:** Riverpod 2.6+
- **Storage:** flutter_secure_storage, SharedPreferences
- **Dependencies:** camera, url_launcher, intl, uuid

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.35.7+
- Dart 3.3+
- Android Studio / Xcode
- Python 3.9-3.13 (for model training/conversion)
- Spotify Developer Account (for playlist features)

### Installation

```bash
# Clone the repository
git clone https://github.com/Moaaz-Ahmad/VibeLens.git
cd vibelens

# Install Flutter dependencies
flutter pub get

# Create .env file with Spotify credentials (optional)
cp .env.example .env
# Edit .env and add your Spotify Client ID
# SPOTIFY_CLIENT_ID=your_client_id_here
# SPOTIFY_REDIRECT_URI=vibelens://callback

# Run the app
flutter run
```

**Note:** The app works without Spotify credentials. Mood detection is fully functional offline. Spotify is only needed for playlist generation.

### Model Setup

The `.tflite` file is **not committed** (it is gitignored). Build it with:

```bash
pip install tensorflow          # Python 3.9-3.12
python ml/build_model.py        # writes assets/models/mood_classifier.tflite
```

[`ml/build_model.py`](ml/build_model.py) uses
[`tf.keras.applications.MobileNetV2`](https://www.tensorflow.org/api_docs/python/tf/keras/applications/MobileNetV2)
as a frozen ImageNet backbone with a new 6-way softmax head, and trains the head
if labelled images exist in `data/train/<mood>/` (optionally `data/val`, `data/test`).

> **Accuracy warning:** ImageNet classes are objects, not moods. Without
> training data the head is random and predictions are meaningless (chance =
> ~17%). Train on labelled mood images and check the printed test accuracy
> before trusting results.

Model contract (enforced in `ModelService`): input `[1,224,224,3]` RGB 0-255
(rescaling is inside the model), output 6 scores in `MoodLabel` enum order
(`cozy, energetic, melancholic, calm, nostalgic, romantic`).

## 📱 Usage

1. **Launch app** and grant camera permissions
2. **Point camera** at any scene (workspace, window view, café, nature, etc.)
3. **Tap capture button** to analyze the scene
4. **View results** — See detected mood with confidence score and mood distribution
5. **Generate playlist** (optional) — Authenticate with Spotify and get personalized recommendations
6. **View history** — Access past mood detections, statistics, and trends
7. **Manage settings** — Configure Spotify, playlist preferences, and privacy options

## 🎨 Mood Categories

| Mood | Emoji | Description | Music Style |
|------|-------|-------------|-------------|
| **Cozy** | ☕ | Warm, comfortable, intimate | Acoustic, Lo-fi, Chill |
| **Energetic** | ⚡ | Dynamic, vibrant, high-energy | Dance, Pop, Electronic |
| **Melancholic** | 🌧️ | Reflective, somber, introspective | Sad, Emotional, Slow |
| **Calm** | 🌊 | Peaceful, serene, tranquil | Ambient, Meditation, Nature |
| **Nostalgic** | � | Sentimental, vintage, reminiscent | Retro, Classics, Throwback |
| **Romantic** | � | Loving, intimate, tender | Love Songs, R&B, Ballads |

## 🧪 Current Status

| Feature | Status |
|---------|--------|
| MobileNetV2 backbone + build script | ✅ Complete |
| Mood head trained on labelled data | ❌ Needs dataset |
| TFLite export | ✅ `ml/build_model.py` |
| Flutter app with camera | ✅ Complete |
| Mood detection inference | ✅ Complete |
| Animated UI with gradients | ✅ Complete |
| Spotify OAuth (PKCE) | ✅ Complete |
| Playlist generation | ✅ Complete |
| Playlist playback | ✅ Complete |
| Mood history tracking | ✅ Complete |
| Settings & preferences | ✅ Complete |
| Widget tests (22 passing) | ✅ Complete |
| GitHub Actions CI/CD | ✅ Complete |
| Production model training | 🔄 Optional enhancement |

**Latest Updates (v0.1.0):**

- ✅ Full Spotify integration with playlist generation
- ✅ Mood history with local storage and statistics
- ✅ Enhanced settings screen (Spotify, preferences, privacy)
- ✅ History filtering and mood distribution analytics
- ✅ Auto-save mood detections
- ✅ GitHub Actions CI/CD pipeline
- ✅ All lint issues resolved
- ✅ iOS build support (Firebase removed)

## 🛠️ Development

### Project Structure

The app follows MVC with a service layer: **Views** (`screens/`, `widgets/`)
render state and navigate; **Controllers** (`controllers/`) orchestrate a
use case; **Services** do one job each (camera, inference, auth, storage);
**Models** (`models/`) are plain Dart data with no Flutter imports.

```
vibelens/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants.dart        # AppConstants (UI), ModelConfig, SpotifyApi
│   │   ├── mood_style.dart       # UI extension on MoodLabel (colors, text)
│   │   ├── theme.dart
│   │   └── utils/logger.dart
│   ├── models/                   # Plain data: MoodLabel/MoodResult, Playlist, MoodHistoryEntry
│   ├── controllers/
│   │   └── camera_screen_controller.dart  # capture -> infer -> cleanup
│   ├── screens/                  # Views
│   ├── services/
│   │   ├── model_service.dart         # TFLite load + run + postprocess
│   │   ├── image_preprocessor.dart    # decode/orient/resize (off UI isolate)
│   │   ├── camera_service.dart
│   │   ├── spotify_auth_service.dart  # PKCE URL + token exchange
│   │   ├── spotify_service.dart       # token storage + Spotify API
│   │   ├── settings_service.dart      # SharedPreferences
│   │   └── history_service.dart
│   └── widgets/
├── ml/build_model.py             # Keras MobileNetV2 -> .tflite
├── assets/models/                # mood_classifier.tflite (generated, gitignored)
├── test/widget_test.dart
└── .github/workflows/            # CI + release
```

### Running Tests

```bash
# Run all tests
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

**Optional:** Spotify is only required for playlist generation. The app works fully for mood detection without it.

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new app
3. Add redirect URI: `vibelens://callback`
4. Copy Client ID (Secret not needed for PKCE OAuth)
5. Create `.env` file in project root:

```env
SPOTIFY_CLIENT_ID=your_client_id_here
SPOTIFY_REDIRECT_URI=vibelens://callback
```

See [SPOTIFY_SETUP.md](SPOTIFY_SETUP.md) for detailed instructions and [SPOTIFY_QUICKSTART.md](SPOTIFY_QUICKSTART.md) for a 10-minute quick start guide.

## 📚 Documentation

- **[SPOTIFY_SETUP.md](SPOTIFY_SETUP.md)** — Comprehensive Spotify setup guide
- **[SPOTIFY_QUICKSTART.md](SPOTIFY_QUICKSTART.md)** — 10-minute quick start
- **[GETTING_STARTED_ML.md](GETTING_STARTED_ML.md)** — ML model training guide
- **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** — Project organization
- **[ARCHITECTURE.md](ARCHITECTURE.md)** — Technical architecture details

## 🐛 Troubleshooting

### Model Inference Error
If you see "invalid argument: input element is double while tensor data type is uint8":

- ✅ **Fixed in v0.1.0** — Model preprocessing now correctly handles uint8 (0-255)

### Camera Permission Denied

- Grant camera permission in Android/iOS settings
- For emulator, ensure virtual camera is enabled
- Check AndroidManifest.xml has camera permissions

### Spotify Auth Failed

- Verify `SPOTIFY_CLIENT_ID` in `.env` file
- Check redirect URI matches: `vibelens://callback`
- Ensure internet connection is active
- See [SPOTIFY_SETUP.md](SPOTIFY_SETUP.md) for troubleshooting

### History Not Saving

- Check "Enable Mood History" in Settings
- Verify app has storage permissions
- History stores up to 100 entries locally

### iOS Build Fails

- ✅ **Fixed in v0.1.0** — Firebase dependencies removed
- Run `pod install` in ios/ directory
- Clean build folder: `flutter clean && flutter pub get`

## 📊 Performance Metrics

| Metric | Current | Target |
|--------|---------|--------|
| Inference time | ~700ms | <200ms |
| Model size (TFLite) | 3-5MB | <15MB |
| App size (APK release) | ~45MB | <60MB |
| Test coverage | 22 tests | 50+ tests |
| Mood accuracy | not measured (untrained head) | >90% |
| History storage | 100 entries | 500+ entries |

## 🗺️ Roadmap

### Phase 1: MVP ✅ (Complete)

- [x] Flutter app scaffold
- [x] Camera integration
- [x] MobileNetV2 backbone
- [x] TFLite inference (uint8)
- [x] Basic UI with mood display
- [x] Unit tests (22 passing)
- [x] Material Design 3 theming

### Phase 2: Features ✅ (Complete)

- [x] Spotify OAuth (PKCE)
- [x] Full playlist generation
- [x] Playlist playback
- [x] Enhanced settings screen
- [x] Mood history tracking
- [x] Statistics and filtering
- [x] GitHub Actions CI/CD

### Phase 3: Polish 📅 (Planned)

- [ ] Custom model training on larger dataset
- [ ] Performance optimization (<200ms inference)
- [ ] UI/UX refinements and animations
- [ ] Integration tests
- [ ] Offline playlist caching
- [ ] Social features (share moods/playlists)
- [ ] Beta release on Play Store / App Store

### Future Enhancements 💡

- [ ] Voice mood detection
- [ ] Location-based mood patterns
- [ ] Mood journal with notes
- [ ] Export mood data
- [ ] Multi-language support
- [ ] Dark/Light theme toggle

## 🤝 Contributing

Contributions are welcome! This project is actively maintained.

**How to contribute:**

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

**Areas needing help:**

- Model training on larger datasets
- iOS testing and optimization
- UI/UX improvements
- Additional test coverage
- Documentation improvements

## 📄 License

MIT License — see [LICENSE](LICENSE) file

## 🙏 Acknowledgments

- Pre-trained MobileNetV2 from [PyTorch Vision](https://pytorch.org/vision/stable/models.html)
- Spotify API for music discovery
- Flutter team for amazing framework
- TensorFlow Lite for on-device ML

---

**Built with Flutter 💙 | On-device AI 🧠 | Music discovery 🎵**

**[⭐ Star this repo](https://github.com/Moaaz-Ahmad/VibeLens)** if you found it useful!
