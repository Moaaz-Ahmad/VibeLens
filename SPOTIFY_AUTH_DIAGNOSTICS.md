# Spotify Authentication Diagnostics

## Current Status ✅

Good news! The app is now correctly:
- ✅ Loading `.env` file (not `.env.example`)
- ✅ Reading Client ID: `72cd03abeb0444488b02a5f178a31712`
- ✅ Using redirect URI: `vibelens://callback`
- ✅ Starting authentication flow
- ✅ Android deep link configured

## The Problem ❌

**Error**: `null_intent, Failed to authorize: Null intent received`

This specific error means:
1. The Spotify OAuth page is opening successfully
2. BUT the redirect back to the app is failing
3. This happens when the redirect URI isn't whitelisted in Spotify Dashboard

## Critical Fix Required 🔴

**You MUST add the redirect URI to your Spotify Developer Dashboard:**

### Step-by-Step Instructions:

1. **Open Spotify Developer Dashboard**
   - URL: https://developer.spotify.com/dashboard
   - Log in with your Spotify account

2. **Find Your App**
   - Look for an app with Client ID: `72cd03abeb0444488b02a5f178a31712`
   - Or create a new app if you haven't yet

3. **Open App Settings**
   - Click on your app name
   - Click the "Settings" button (top right)

4. **Add Redirect URI** ⭐ **CRITICAL STEP**
   - Scroll down to "Redirect URIs" section
   - Click "Edit" or "Add URI"
   - Type EXACTLY: `vibelens://callback`
     - Must be lowercase
     - No spaces
     - No trailing slash
     - Scheme: `vibelens`
     - Host: `callback`
   - Click "Add"
   - Click "Save" at the bottom of the page

5. **Wait and Verify**
   - Changes can take 1-2 minutes to take effect
   - Make sure you see `vibelens://callback` in the list
   - The URI should be green/active, not grayed out

## Testing After Adding Redirect URI

1. **Close the app completely** (don't just hot reload)
2. **Restart**: Press `R` for hot restart or `flutter run` again
3. **Try authentication**:
   - Go to Settings
   - Tap "Connect Spotify Account"
   - You should be redirected to Spotify login
   - After login, you should return to the app successfully

## Expected Success Logs

When it works, you'll see:
```
🎵 VibeLens ℹ️  Starting Spotify authentication with Client ID: 72cd03ab...
🎵 VibeLens ℹ️  Using redirect URI: vibelens://callback
🎵 VibeLens ℹ️  Authorization response received
🎵 VibeLens ℹ️  Got authorization code, exchanging for token...
🎵 VibeLens ✅ Access token received: BQDt3zfU8y...
🎵 VibeLens ✅ Spotify authentication successful
```

## Still Not Working?

### Check #1: Verify Redirect URI Format
In Spotify Dashboard, the redirect URI must be:
- ✅ `vibelens://callback`
- ❌ NOT `https://vibelens.com/callback`
- ❌ NOT `http://localhost:8888/callback`
- ❌ NOT `vibelens://callback/`

### Check #2: Verify Client ID
Make sure the Client ID in Spotify Dashboard matches your `.env`:
- Dashboard: (copy from "Client ID" field)
- `.env` file: `72cd03abeb0444488b02a5f178a31712`

### Check #3: App Type
Your Spotify app should be configured as:
- Type: **Web API** (not "Web Playback SDK" only)
- This allows OAuth authentication

### Check #4: Android Package Name
If you're still having issues, you might need to verify your app's package name:
- Package: `com.example.vibelens`
- This is already correct in the code

## Alternative: Test with Web Redirect (Temporary)

If you want to test if your Client ID works at all, try temporarily adding this redirect URI to Spotify Dashboard:
- `https://example.com/callback`

Then update your `.env`:
```
SPOTIFY_REDIRECT_URI=https://example.com/callback
```

If this works, it confirms your Client ID is valid and the issue is specifically with the `vibelens://` deep link.

## Need More Help?

1. Take a screenshot of your Spotify Dashboard "Redirect URIs" section
2. Verify `vibelens://callback` is listed and saved
3. Wait 2-3 minutes after saving
4. Try authentication again
5. Check the logs for any new error messages

---

**Bottom Line**: The "null intent" error is almost certainly because `vibelens://callback` isn't registered in your Spotify Developer Dashboard. Add it there and it should work!
