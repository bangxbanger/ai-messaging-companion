# Quick Run Guide

## Prerequisites
- Python 3.9+ with venv
- Xcode installed
- Groq API key

## Step 1: Start Backend

```bash
cd backend-fastapi

# First time setup
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Every time you run
export GROQ_API_KEY=your_groq_api_key_here
uvicorn main:app --host 127.0.0.1 --port 8080 --reload
```

**Verify it's running:**
```bash
curl http://127.0.0.1:8080/health
# Should return: {"ok":true}
```

## Step 2: Run macOS App

```bash
cd macos/CompanionApp
open CompanionApp.xcodeproj
```

Then press **⌘R** in Xcode to build and run.

## Step 3: Grant Permissions

When the app launches:
1. Click "Open System Settings" when prompted
2. Find "Bro" in Accessibility list
3. Enable the checkbox
4. Restart the app

## Step 4: Use It

1. **Look for the ✨ icon in your menu bar**
2. **Click it** to see:
   - Current tone profile (formal/bestie/degen/flirty)
   - Keyboard shortcuts
   - Settings
3. **Select some text** in any app (e.g., Notes, Messages)
4. **Press ⌥⌘R** to rephrase
5. **An overlay appears** showing the rephrased text
6. **Click "Use This"** to paste it

## Troubleshooting

### Backend not starting?
```bash
# Check what's on port 8080
lsof -i :8080

# Kill it
lsof -ti :8080 | xargs kill -9

# Try again
cd backend-fastapi
source .venv/bin/activate
GROQ_API_KEY=your_key uvicorn main:app --host 127.0.0.1 --port 8080
```

### App not in menu bar?
- Check Console.app for errors
- Look for debug logs starting with 🔍 or ✨
- The app should show a notification when it launches

### Can't connect to backend?
```bash
# Test from terminal
curl -X POST http://127.0.0.1:8080/rephrase \
  -H "Content-Type: application/json" \
  -d '{"text": "hello", "profile": "formal"}'
```

### App not in Accessibility settings?
- Restart the app
- The first launch triggers the permission request
- Check System Settings → Privacy & Security → Accessibility

## Quick Test

```bash
# Terminal 1: Start backend
cd backend-fastapi && source .venv/bin/activate
GROQ_API_KEY=your_key uvicorn main:app --host 127.0.0.1 --port 8080

# Terminal 2: Test it
curl http://127.0.0.1:8080/health
curl -X POST http://127.0.0.1:8080/rephrase \
  -H "Content-Type: application/json" \
  -d '{"text": "yo wassup", "profile": "formal"}'
```

Expected output:
```json
{"ok":true}
{"rephrased_text":"Hello, how may I assist you today?"}
```

## Demo Flow

1. Open Notes app
2. Type: "hey man, can u help me with this thing?"
3. Select the text
4. Press **⌥⌘R**
5. See overlay with formal rephrasing
6. Click "Use This" to replace
7. Try different profiles from menu bar!

## Tone Profiles

- **Formal**: Professional, grammatically correct
- **Bestie**: Warm, friendly, supportive
- **Degen**: Crypto slang, casual, irreverent
- **Flirty**: Playful, light, respectful

