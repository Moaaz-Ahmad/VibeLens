# VibeLens Architecture

VibeLens is a Flutter app that sends a camera photo to a vision model
(Google Gemini or OpenAI) to classify its mood, then builds a matching Spotify
playlist.

```
Camera -> CameraScreenController -> MoodClassifierService -> CloudMoodService -> Gemini / OpenAI
                                                                  |
                                    Results screen <- MoodResult <-+
                                          |
                                    SpotifyService -> Spotify API -> Playlist screen
```

## Layers (MVC + services)

| Layer | Location | Responsibility |
|---|---|---|
| Model | `lib/models/` | Plain data (`MoodLabel`, `MoodResult`, `Playlist`, `MoodHistoryEntry`). No Flutter imports; colours/text live in `core/mood_style.dart`. |
| View | `lib/screens/`, `lib/widgets/` | Render state, navigate, show errors. No HTTP, storage or AI calls. |
| Controller | `lib/controllers/` | `CameraScreenController` (`ChangeNotifier`): capture -> classify -> delete temp photo. Services are injectable. |
| Services | `lib/services/` | One job each (below). |

### Services

- `MoodClassifierService` — reads the active provider and key, delegates to `CloudMoodService`; errors if not signed in.
- `CloudMoodService` — builds the Gemini (`gemini-2.5-flash`) or OpenAI (`gpt-4o-mini`) request with the image and a JSON-only prompt, parses the six mood probabilities (in `MoodLabel` order), renormalises, picks the top label.
- `AiProviderService` — active provider + per-provider API key in `flutter_secure_storage`.
- `image_preprocessor.dart` — orient, resize (max 768px) and JPEG-encode in an isolate.
- `CameraService`, `HistoryService`, `SettingsService` — camera, mood history (SharedPreferences, 100 entries), user preferences.
- `SpotifyAuthService` (PKCE URL + token exchange) and `SpotifyService` (token storage, search, playlist creation).

## Sign-in

Google and OpenAI don't provide consumer-account OAuth for third-party model
access, so "sign in" means the user's own API key (Settings -> Mood
classifier). Keys stay on the device; photos are sent to the chosen provider.

## Data flow

1. Capture photo (`CameraService`).
2. `MoodClassifierService.classify(path)` -> `CloudMoodService` -> provider JSON.
3. `MoodResult` shown on the results screen and saved to history.
4. Playlist screen: `SpotifyService.createMoodPlaylist(result)` maps the mood to search parameters.

## Privacy

- Photos leave the device only to the provider the user signed in to; they are deleted locally after classification.
- API keys and Spotify tokens are in secure storage; history is local.

## Known gaps

- Services are singletons without interfaces; the playlist, history and results screens still call services directly.
- API keys aren't validated at sign-in; a bad key shows an error on first use.
