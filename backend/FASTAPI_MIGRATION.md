# FastAPI Backend Migration

This document describes the migration from Convex to a Python FastAPI backend using Groq's LLM API.

## What Changed

### Backend (NEW)
- **Location**: `backend-fastapi/`
- **Stack**: Python, FastAPI, Groq (via OpenAI-compatible client)
- **Endpoints**:
  - `GET /health` - Health check
  - `GET /profiles` - List available tone profiles
  - `POST /rephrase` - Rephrase text with selected profile (synchronous, non-streaming)

### Tone Profiles
Four tone profiles for text rephrasing:
- **formal** - Professional, precise, grammatically correct
- **bestie** - Warm, friendly, supportive
- **degen** - Crypto degen slang, casual, irreverent
- **flirty** - Playful, light, respectful

### macOS App Changes

#### Config.swift
- Added `backendURL = "http://127.0.0.1:8080"` pointing to FastAPI server

#### Models.swift
- Added `ToneProfile` enum with cases: formal, bestie, degen, flirty

#### AppState.swift
- Added `@Published var selectedProfile: ToneProfile = .formal`

#### MenuBarView.swift
- Added tone profile selector menu in the UI
- Shows current profile and allows switching between profiles

#### APIService.swift
- Replaced streaming `rephraseStream()` with synchronous `rephrase(text:profile:completion:)`
- Calls FastAPI `POST /rephrase` endpoint
- Returns full rephrased text in completion handler

#### AppDelegate.swift
- Updated `handleRephraseHotkey()` to use `APIService.rephrase()` instead of streaming
- Passes selected profile from AppState
- Displays result in overlay when complete

## Running the Backend

```bash
cd backend-fastapi

# Setup (first time only)
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Set your Groq API key
export GROQ_API_KEY=your_key_here

# Run server
uvicorn main:app --reload --port 8080
```

## Testing

```bash
# Test health
curl http://127.0.0.1:8080/health

# Test profiles
curl http://127.0.0.1:8080/profiles

# Test rephrase
curl -X POST http://127.0.0.1:8080/rephrase \
  -H "Content-Type: application/json" \
  -d '{"text": "hey whats up", "profile": "formal"}'
```

## Running the macOS App

1. Start the FastAPI backend (see above)
2. Open the Xcode project: `ai-messaging-companion/macos/CompanionApp/CompanionApp.xcodeproj`
3. Build and run (⌘R)
4. Grant Accessibility permissions when prompted
5. Use ⌥⌘R to rephrase focused text
6. Click the menu bar icon to change tone profile

## Key Differences from Convex

- **No authentication** - Simplified for local development
- **Synchronous API** - Returns full text instead of streaming chunks
- **Direct Groq integration** - No middleware layers
- **Profile-based prompts** - Different system prompts per profile
- **Simpler error handling** - Standard HTTP status codes

## Next Steps

- Add more tone profiles (sarcastic, concise, verbose, etc.)
- Implement streaming for better UX
- Add voice message generation using ElevenLabs
- Deploy backend to production server
- Add authentication for production use

