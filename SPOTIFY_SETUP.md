# Spotify Integration Setup Guide

## Current Status

 **Implementation Complete** - All code is ready!

What's implemented:
- OAuth authentication flow (flutter_appauth)
- Token storage and management (flutter_secure_storage)
- Mood-to-music parameter mapping
- Track search API calls
- Playlist creation API calls
- Beautiful UI with animations
- Deep linking configuration (vibelens://callback)
- OAuth manifestPlaceholders in build.gradle.kts

**What's needed:** Only Spotify API credentials!

---

## Setup Steps

### Step 1: Create Spotify Developer Account

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Log in or create a free Spotify account
3. Click **"Create app"**

### Step 2: Configure Your App

**App Name:** VibeLens  
**App Description:** AI-powered mood-based music discovery app  
**Website:** `http://localhost` (or your actual website)  
**Redirect URI:** `vibelens://callback` **CRITICAL - Must be exact**

**API Permissions needed:**
- `playlist-modify-public`
- `playlist-modify-private`
- `user-read-private`
- `user-read-email`

Click **Save** to create the app.

### Step 3: Get Your Credentials

After creating the app:

1. Click on your app name to open settings
2. Click **"Settings"** button
3. You'll see:
   - **Client ID** - Copy this
   - **Client secret** - Click "View client secret" and copy

### Step 4: Configure Environment

1. Open `.env` file in the project root:

```bash
# Spotify API Configuration
SPOTIFY_CLIENT_ID=your_client_id_here_from_step_3
SPOTIFY_REDIRECT_URI=vibelens://callback

# Leave these as-is (not needed)
YOUTUBE_API_KEY=not_used
FIREBASE_API_KEY=not_used
FIREBASE_PROJECT_ID=not_used
FLUTTER_ENV=development
```

2. Replace `your_client_id_here_from_step_3` with your actual Client ID

 **Important:**
- Do NOT commit `.env` to git (already in .gitignore)
- Client secret is NOT needed (PKCE flow handles security)

### Step 5: Rebuild the App

```powershell
# Clean build
flutter clean
flutter pub get

# Run on Android
flutter run

# Or build APK
flutter build apk --debug
```

---

## Testing the Integration

### Test Flow:

1. **Capture a mood:**
   - Open app → Camera screen
   - Take a photo → Wait for mood detection
   - See results screen (e.g., "nostalgic 34.5%")

2. **Generate playlist:**
   - Tap "Generate Playlist" button
   - First time: OAuth screen appears
   - Tap "Connect with Spotify"
   - Browser opens → Spotify login
   - Approve permissions
   - Redirect back to app

3. **View playlist:**
   - Playlist screen shows generated tracks
   - 25 tracks based on detected mood
   - Tap "Open in Spotify" to play

### Expected Behavior:

 **First use:** OAuth login required  
 **Subsequent uses:** Token cached, no login needed  
 **Token expiry:** Auto-refresh or re-login prompt

---

## How It Works

### Mood → Music Mapping

| Mood | Spotify Seeds | Energy | Tempo (BPM) |
|------|---------------|--------|-------------|
| **Cozy** | acoustic, chill, lo-fi | 0.1-0.4 | 60-90 |
| **Energetic** | dance, upbeat, electronic | 0.7-1.0 | 110-140 |
| **Melancholic** | sad, melancholy, emotional | 0.1-0.4 | 50-80 |
| **Calm** | ambient, peaceful, meditation | 0.1-0.3 | 40-70 |
| **Nostalgic** | retro, 80s, throwback | 0.4-0.7 | 90-120 |
| **Romantic** | love, romantic, smooth | 0.3-0.6 | 70-100 |

### API Flow:

```
1. User taps "Generate Playlist"
   ↓
2. Check authentication
   ↓
3. If not authenticated → OAuth flow
   ↓
4. Get mood parameters (seeds, energy, tempo)
   ↓
5. Search Spotify for tracks (3 seeds × 10 tracks each)
   ↓
6. Get current user ID
   ↓
7. Create playlist: "VibeLens: {Mood} Vibes"
   ↓
8. Add 25 selected tracks to playlist
   ↓
9. Show playlist UI with tracks
   ↓
10. User can open in Spotify app
```

---

## Troubleshooting

### "Invalid client" error

**Problem:** Client ID not configured correctly

**Solution:**
- Double-check `.env` file has correct `SPOTIFY_CLIENT_ID`
- Verify no spaces or quotes around the ID
- Run `flutter clean` and `flutter pub get`

### "Invalid redirect URI" error

**Problem:** Redirect URI mismatch

**Solution:**
- In Spotify Dashboard, redirect URI must be **exactly**: `vibelens://callback`
- No trailing slash, no http://, must be lowercase
- If changed, run `flutter clean` and rebuild

### "Authentication failed" error

**Problem:** OAuth flow interrupted or failed

**Solution:**
- Check internet connection
- Try logout: Delete and reinstall app
- Verify Spotify account is valid
- Check if you approved all permissions

### Playlist creation fails

**Problem:** Missing API permissions or token expired

**Solution:**
- Verify all scopes in Step 2 are enabled
- Check token not expired (tokens last ~1 hour)
- Try logout and re-authenticate
- Check Spotify API status: https://developer.spotify.com/status

### "Not authenticated" error

**Problem:** Token not saved or cleared

**Solution:**
- Token stored in secure storage (encrypted)
- Reinstalling app clears tokens
- Re-authenticate after reinstall

---

## Security Notes

### PKCE Flow (Proof Key for Code Exchange)

VibeLens uses OAuth 2.0 with PKCE:
- No client secret needed in app
- Secure for mobile applications
- Prevents authorization code interception
- Tokens stored encrypted (FlutterSecureStorage)

### What's Stored:

```
Secure Storage:
├── spotify_access_token (encrypted, ~1 hour expiry)
└── spotify_token_expiry (datetime string)
```

### What's NOT Stored:

- Client secret (not needed for PKCE)
- Refresh tokens (Spotify doesn't provide for PKCE)
- User passwords
- Personal Spotify data

---

## Production Deployment

### Before Release:

1. **Update redirect URI:**
   - Development: `vibelens://callback`
   - Production: Keep the same (already configured)

2. **Release build:**
   ```powershell
   flutter build appbundle --release
   ```

3. **Test on physical device:**
   - OAuth works better on real devices
   - Test deep linking thoroughly
   - Verify Spotify app opens playlist

4. **Update app listing:**
   - Add Spotify integration to description
   - Include screenshots of playlist feature
   - Note: "Requires Spotify account"

---

## UI Features

### Authentication Screen:
- Spotify green gradient background
- Logo and description
- "Connect with Spotify" button
- Loading state during OAuth
- Error handling with retry

### Playlist Screen:
- Hero animation from results screen
- Animated playlist header with icon
- Track list with album art
- Track number, name, artist, duration
- Staggered fade-in animations
- "Open in Spotify" button (launches app or web player)

### Results Screen:
- "Generate Playlist" button (white with mood color)
- Passes MoodResult to playlist screen
- Hero transition animation

---

## File References

### Implementation Files:

| File | Purpose | Status |
|------|---------|--------|
| `lib/services/spotify_service.dart` | API integration, OAuth, playlist creation | Complete |
| `lib/models/playlist.dart` | Track and Playlist models | Complete |
| `lib/screens/spotify_auth_screen.dart` | OAuth UI | Complete |
| `lib/screens/playlist_screen.dart` | Playlist display UI | Complete |
| `lib/screens/results_screen.dart` | "Generate Playlist" button | Complete |
| `android/app/build.gradle.kts` | OAuth deep linking config | Complete |
| `android/app/src/main/AndroidManifest.xml` | Deep linking intent | Complete |
| `.env` | Spotify credentials | Needs your Client ID |

### Dependencies (already in pubspec.yaml):

- `flutter_appauth: ^6.0.4` - OAuth 2.0
- `flutter_secure_storage: ^9.0.0` - Token storage
- `http: ^1.1.0` - API calls
- `flutter_dotenv: ^5.1.0` - Environment variables
- `url_launcher: ^6.2.1` - Open Spotify app

---

## Quick Checklist

- [ ] Created Spotify Developer account
- [ ] Created app in Spotify Dashboard
- [ ] Added redirect URI: `vibelens://callback`
- [ ] Enabled all required scopes
- [ ] Copied Client ID
- [ ] Updated `.env` with Client ID
- [ ] Ran `flutter clean` and `flutter pub get`
- [ ] Built and ran app
- [ ] Tested mood detection
- [ ] Tested playlist generation
- [ ] Verified OAuth flow works
- [ ] Tested "Open in Spotify" button
- [ ] Playlist created successfully in Spotify account

---

## You're Done!

Once you add your Spotify Client ID, the full integration will work:

1. Detect mood from camera
2. Tap "Generate Playlist"
3. Authenticate with Spotify (first time only)
4. See 25 mood-matched tracks
5. Open and play in Spotify

**Total setup time:** 10 minutes  
**Code changes needed:** 0 (just add Client ID to `.env`)

Enjoy your AI-powered mood playlists!
