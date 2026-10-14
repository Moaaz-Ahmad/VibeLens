# VibeLens — AI Mood-Based Music Discovery

> Point your camera at a scene. Capture its mood. Get a perfect Spotify playlist.

VibeLens uses a vision AI model (Google Gemini or ChatGPT, with your own API key) to analyze visual scenes and generate personalized music playlists that match the emotional atmosphere of your surroundings.

## Features

- **Cloud AI classification** — Sign in with a Gemini or OpenAI API key; the photo is sent to that provider to classify its mood
- **Real-time camera** — Instant mood classification from your surroundings  
- **Spotify integration** — OAuth authentication and automatic playlist generation
- **Mood history** — Track your mood detections with statistics and filtering
- **Mood visualization** — Beautiful gradients and animations that reflect emotions
- **Comprehensive settings** — Manage Spotify, preferences, and privacy
- **Lightweight** — Material Design 3 UI
- **Local storage** — All data stored securely on your device

## Architecture

```
Camera Frame → Gemini / ChatGPT vision model → Mood Classification → Spotify API → Playlist
```

**Tech Stack:**

- **Frontend:** Flutter 3.35.7 with Material Design 3
- **Mood AI:** Google Gemini (`gemini-2.5-flash`) or OpenAI (`gpt-4o-mini`) vision APIs
- **APIs:** Spotify Web API with OAuth 2.0 (PKCE)
- **State:** Riverpod 2.6+
- **Storage:** flutter_secure_storage, SharedPreferences
- **Dependencies:** camera, url_launcher, intl, uuid

## Quick Start

### Prerequisites

- Flutter SDK 3.35.7+
- Dart 3.3+
- Android Studio / Xcode
- A Google Gemini or OpenAI API key (for mood classification)
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

**Note:** The app works without Spotify credentials. Mood detection needs an internet connection and a Gemini or OpenAI key. Spotify is only needed for playlist generation.

### Mood classifier sign-in (Settings → Mood classifier)

Mood detection needs a provider. Pick **Google Gemini** or **ChatGPT (OpenAI)**
and paste your own API key (Google and OpenAI don't offer consumer-account
sign-in for third-party apps). Keys are kept in secure storage on the device.
The photo is resized to <=768px JPEG and sent to the provider; usage is billed to
your key. Without a key, capture shows a "sign in first" error.

## Usage

1. **Launch app** and grant camera permissions
2. **Point camera** at any scene (workspace, window view, café, nature, etc.)
3. **Tap capture button** to analyze the scene
4. **View results** — See detected mood with confidence score and mood distribution
5. **Generate playlist** (optional) — Authenticate with Spotify and get personalized recommendations
6. **View history** — Access past mood detections, statistics, and trends
7. **Manage settings** — Configure Spotify, playlist preferences, and privacy options

## Mood Categories

| Mood | Description | Music Style |
|------|-------------|-------------|
| **Cozy** | Warm, comfortable, intimate | Acoustic, Lo-fi, Chill |
| **Energetic** | Dynamic, vibrant, high-energy | Dance, Pop, Electronic |
| **Melancholic** | Reflective, somber, introspective | Sad, Emotional, Slow |
| **Calm** | Peaceful, serene, tranquil | Ambient, Meditation, Nature |
| **Nostalgic** | Sentimental, vintage, reminiscent | Retro, Classics, Throwback |
| **Romantic** | Loving, intimate, tender | Love Songs, R&B, Ballads |

## Current Status

| Feature | Status |
|---------|--------|
| Gemini / ChatGPT mood classification | Complete |
| Flutter app with camera | Complete |
| Animated UI with gradients | Complete |
| Spotify OAuth (PKCE) | Complete |
| Playlist generation | Complete |
| Playlist playback | Complete |
| Mood history tracking | Complete |
| Settings & preferences | Complete |
| Widget tests | Complete |
| GitHub Actions CI/CD | Complete |

**Latest Updates (v0.1.0):**

- Full Spotify integration with playlist generation
- Mood history with local storage and statistics
- Enhanced settings screen (Spotify, preferences, privacy)
- History filtering and mood distribution analytics
- Auto-save mood detections
- GitHub Actions CI/CD pipeline
- All lint issues resolved
- iOS build support (Firebase removed)

## Development

### Project Structure

The app follows MVC with a service layer: **Views** (`screens/`, `widgets/`)
render state and navigate; **Controllers** (`controllers/`) orchestrate a
use case; **Services** do one job each (camera, classification, auth, storage);
**Models** (`models/`) are plain Dart data with no Flutter imports.

```
vibelens/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants.dart        # AppConstants (UI), SpotifyApi
│   │   ├── mood_style.dart       # UI extension on MoodLabel (colors, text)
│   │   ├── theme.dart
│   │   └── utils/logger.dart
│   ├── models/                   # Plain data: MoodLabel/MoodResult, Playlist, MoodHistoryEntry
│   ├── controllers/
│   │   └── camera_screen_controller.dart  # capture -> infer -> cleanup
│   ├── screens/                  # Views
│   ├── services/
│   │   ├── mood_classifier_service.dart  # picks signed-in provider
│   │   ├── cloud_mood_service.dart    # Gemini / OpenAI vision calls
│   │   ├── ai_provider_service.dart   # provider + API key storage
│   │   ├── image_preprocessor.dart    # orient/resize/JPEG (off UI isolate)
│   │   ├── camera_service.dart
│   │   ├── spotify_auth_service.dart  # PKCE URL + token exchange
│   │   ├── spotify_service.dart       # token storage + Spotify API
│   │   ├── settings_service.dart      # SharedPreferences
│   │   └── history_service.dart
│   └── widgets/
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

## Spotify API Setup

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

## Documentation

- **[SPOTIFY_SETUP.md](SPOTIFY_SETUP.md)** — Comprehensive Spotify setup guide
- **[SPOTIFY_QUICKSTART.md](SPOTIFY_QUICKSTART.md)** — 10-minute quick start
- **[ARCHITECTURE.md](ARCHITECTURE.md)** — Technical architecture details

## Troubleshooting

### Mood Classification Error

- "Sign in ... first": add a Gemini or OpenAI API key in Settings → Mood classifier
- "API key rejected": the key is invalid or lacks access; sign out and re-enter it
- "Provider error 429": rate limit or exhausted quota on your key

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

- **Fixed in v0.1.0** — Firebase dependencies removed
- Run `pod install` in ios/ directory
- Clean build folder: `flutter clean && flutter pub get`

## Performance Metrics

| Metric | Current | Target |
|--------|---------|--------|
| App size (APK release) | ~45MB | <60MB |
| Tests | 17 | 50+ |
| History storage | 100 entries | 500+ entries |

## Roadmap

### Phase 1: MVP (Complete)

- [x] Flutter app scaffold
- [x] Camera integration
- [x] Cloud mood classification (Gemini / OpenAI)
- [x] Basic UI with mood display
- [x] Unit tests
- [x] Material Design 3 theming

### Phase 2: Features (Complete)

- [x] Spotify OAuth (PKCE)
- [x] Full playlist generation
- [x] Playlist playback
- [x] Enhanced settings screen
- [x] Mood history tracking
- [x] Statistics and filtering
- [x] GitHub Actions CI/CD

### Phase 3: Polish (Planned)

- [ ] Provider key validation at sign-in
- [ ] Performance optimization
- [ ] UI/UX refinements and animations
- [ ] Integration tests
- [ ] Offline playlist caching
- [ ] Social features (share moods/playlists)
- [ ] Beta release on Play Store / App Store

### Future Enhancements

- [ ] Voice mood detection
- [ ] Location-based mood patterns
- [ ] Mood journal with notes
- [ ] Export mood data
- [ ] Multi-language support
- [ ] Dark/Light theme toggle

## Contributing

Contributions are welcome! This project is actively maintained.

**How to contribute:**

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

**Areas needing help:**

- Automated tests for the cloud classification service
- iOS testing and optimization
- UI/UX improvements
- Additional test coverage
- Documentation improvements

## License

MIT License — see [LICENSE](LICENSE) file

## Acknowledgments

- Spotify API for music discovery
- Flutter team for amazing framework
- Google Gemini and OpenAI vision APIs

---

**Built with Flutter | Vision AI | Music discovery **

**[ Star this repo](https://github.com/Moaaz-Ahmad/VibeLens)** if you found it useful!
