# Convex to FastAPI Migration Complete

## Summary

Successfully migrated from Convex + Supabase backend to a standalone FastAPI backend using Groq API for text rephrasing.

## Changes Made

### Backend

#### Created: `backend-fastapi/`
- **main.py**: FastAPI server with 3 endpoints
  - `GET /health` - Health check
  - `GET /profiles` - List available tone profiles
  - `POST /rephrase` - Rephrase text with selected profile
- **requirements.txt**: Dependencies (fastapi, uvicorn, openai/requests, python-dotenv)
- **README.md**: Setup and usage instructions
- **.env.example**: Environment variable template

#### Implementation Details
- Uses OpenAI-compatible client to call Groq API
- 4 tone profiles: formal, bestie, degen, flirty
- CORS enabled for local development
- No authentication required
- Synchronous (non-streaming) responses

### macOS App

#### Updated Files

**Config.swift**
- ✅ Removed `convexURL`
- ✅ Removed `supabaseURL` and `supabaseAnonKey`
- ✅ Kept `backendURL = "http://127.0.0.1:8080"`
- Simplified to only include FastAPI backend URL

**APIService.swift**
- ✅ Removed all authentication methods (`setAuthToken`, `clearAuthToken`, `getAuthHeaders`)
- ✅ Removed old `getTonePresets()` and `getVoices()` (Convex endpoints)
- ✅ Removed `generateTTS()` (not implemented yet)
- ✅ Kept `rephrase(text:profile:completion:)` - calls FastAPI `/rephrase`
- ✅ Added `getProfiles()` - calls FastAPI `/profiles`
- ✅ Added `healthCheck()` - calls FastAPI `/health`
- Simplified error handling (removed auth errors)

**AppState.swift**
- ✅ Removed `isAuthenticated` property
- ✅ Removed `tonePresets` and `voices` arrays (old Convex data)
- ✅ Removed `checkAuthentication()`, `signOut()`, `loadTonePresets()`, `loadVoices()`
- ✅ Kept `selectedProfile: ToneProfile` for tone selection
- ✅ Added `availableProfiles: [String]` loaded from backend
- ✅ Added `loadProfiles()` - fetches profiles from FastAPI
- ✅ Added `checkBackendHealth()` - verifies backend connectivity

**MenuBarView.swift**
- ✅ Already updated with profile selector (no auth UI)
- Shows "Ready" status instead of auth status
- Profile selector menu working with FastAPI backend

**AppDelegate.swift**
- ✅ Already updated to use `APIService.rephrase()` with FastAPI
- No authentication checks
- Calls backend directly

**Models.swift**
- ✅ Added `ToneProfile` enum (formal, bestie, degen, flirty)
- Old models (TonePreset, Voice) still exist but unused

#### Files No Longer Used (Can Be Deleted)
- `macos/CompanionApp/App/Services/SupabaseService.swift` - Supabase auth service
- `macos/CompanionApp/App/Views/AuthView.swift` - Authentication UI
- Old TonePreset, Voice models in Models.swift (optional cleanup)

## Running the Application

### 1. Start FastAPI Backend

```bash
cd backend-fastapi
source .venv/bin/activate
pip install -r requirements.txt  # if not already installed

export GROQ_API_KEY=your_groq_api_key_here
uvicorn main:app --host 127.0.0.1 --port 8080 --reload
```

Or run directly with Python:
```bash
GROQ_API_KEY=your_key python main.py
```

### 2. Run macOS App

```bash
cd macos/CompanionApp
open CompanionApp.xcodeproj
# Build and run (⌘R)
```

Or from command line:
```bash
xcodebuild -project CompanionApp.xcodeproj -scheme CompanionApp -configuration Debug
```

## Features

### Working
- ✅ Text rephrasing with 4 tone profiles
- ✅ Profile selector in menu bar
- ✅ Hotkey ⌥⌘R for rephrasing
- ✅ Overlay UI showing rephrased text
- ✅ No authentication required
- ✅ Backend health check

### Not Yet Implemented
- ❌ Voice message generation (ElevenLabs integration)
- ❌ Streaming responses (currently synchronous)
- ❌ Custom profile creation
- ❌ Usage tracking/analytics

## API Endpoints

### GET /health
Returns backend health status.

**Response:**
```json
{ "ok": true }
```

### GET /profiles
Returns available tone profiles.

**Response:**
```json
{ "profiles": ["formal", "bestie", "degen", "flirty"] }
```

### POST /rephrase
Rephrase text with selected profile.

**Request:**
```json
{
  "text": "hey whats up",
  "profile": "formal"
}
```

**Response:**
```json
{
  "rephrased_text": "Hello, how are you doing?"
}
```

## Troubleshooting

### Backend won't start
- **Error: `httpx` compatibility issues**
  - Solution: Use `requests` library instead of `openai`/`groq` SDKs
  - Updated `main.py` to call Groq API directly with `requests.post()`

### macOS app can't connect
- **Error: "Operation not permitted"**
  - Check if backend is running: `curl http://127.0.0.1:8080/health`
  - Verify port 8080 is not blocked
  - Check macOS firewall settings

### No menu bar icon
- Check `Info.plist` has `LSUIElement = true`
- Look for debug logs in Console.app

### App not in Accessibility settings
- The app must make at least one Accessibility API call to appear
- Already implemented in `AppDelegate.checkPermissions()`

## Notes

- All Convex and Supabase references removed
- Authentication completely removed
- Simpler architecture: macOS app → FastAPI → Groq
- No database required (stateless)
- Ready for hackathon demo

