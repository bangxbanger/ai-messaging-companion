# Quick Start Guide

Get the Bro running in under 30 minutes!

## Prerequisites Checklist

- [ ] macOS 13.0+
- [ ] Xcode 15+ installed
- [ ] Node.js 20+ installed
- [ ] Homebrew installed

## Step 1: Get API Keys (10 min)

Open these tabs and sign up:

1. **Groq**: [console.groq.com](https://console.groq.com) → API Keys → Create
2. **ElevenLabs**: [elevenlabs.io](https://elevenlabs.io) → Profile → API Key
3. **Supabase**: [supabase.com](https://supabase.com) → New Project
4. **Convex**: [convex.dev](https://convex.dev) → New Project

Save all keys in a secure note.

## Step 2: Set Up Supabase (5 min)

1. Wait for Supabase project to initialize
2. Go to **SQL Editor**
3. Copy-paste `backend/supabase/schema.sql` → Run
4. Copy-paste `backend/supabase/seed.sql` → Run
5. Go to **Settings → API** → Copy `URL` and `anon public` key
6. Go to **Authentication → Providers** → Enable Email, GitHub, Google

## Step 3: Deploy Backend (5 min)

```bash
cd backend/convex
npm install
npx convex dev
```

In another terminal:
```bash
# Set environment variables in Convex dashboard or:
npx convex env set SUPABASE_URL "https://xxx.supabase.co"
npx convex env set SUPABASE_SERVICE_KEY "your-service-role-key"
npx convex env set GROQ_API_KEY "your-groq-key"
npx convex env set ELEVENLABS_API_KEY "your-elevenlabs-key"
```

Deploy:
```bash
npx convex deploy
```

Note your Convex URL (e.g., `https://xyz.convex.cloud`)

## Step 4: Install BlackHole (2 min)

```bash
brew install blackhole-2ch
```

Create Multi-Output Device:
1. Open **Audio MIDI Setup** (Cmd+Space → "Audio MIDI")
2. Click **+** → **Create Multi-Output Device**
3. Check: ☑ BlackHole 2ch, ☑ Your Speakers
4. Right-click → **Use This Device For Sound Output**

## Step 5: Build macOS App (10 min)

### Create Xcode Project

1. Open Xcode
2. **File → New → Project**
3. Choose **macOS → App**
4. Settings:
   - Product Name: `Bro`
   - Interface: **SwiftUI**
   - Language: **Swift**
5. Save to `macos` folder (create new `CompanionApp.xcodeproj`)

### Add Files

1. In Xcode, right-click project → **Add Files**
2. Select all from `macos/CompanionApp/App/`
3. Check "Copy items if needed"
4. Add to target

### Configure

1. Select project → **General**
2. Set **Minimum Deployment** to macOS 13.0
3. **Signing & Capabilities** → Select your team

4. Open `Config.swift` and update:
```swift
static let convexURL = "https://your-project.convex.cloud"
static let supabaseURL = "https://your-project.supabase.co"
static let supabaseAnonKey = "your-anon-key"
```

5. **Product → Build** (⌘B)
6. Fix any errors
7. **Product → Run** (⌘R)

## Step 6: Grant Permissions (2 min)

1. App launches → Permission dialog appears
2. Click **Open System Settings**
3. Enable **Bro** under Accessibility
4. Return to app

## Step 7: Sign In & Test (5 min)

1. Click **wand icon** in menu bar
2. Click **Sign In**
3. Choose GitHub/Google
4. Authenticate in browser
5. Return to app → Should show "Connected"

### Test Rephrase

1. Open Notes or any text app
2. Type: "hey whats up"
3. Press **⌥⌘R** (Option+Command+R)
4. Overlay appears with rephrased text
5. Click **Accept & Paste**

### Test Voice (Optional)

1. Select some text
2. Press **⌥⌘V** (Option+Command+V)
3. Wait for audio generation
4. Open WhatsApp/Telegram
5. Hold voice button
6. Click **Play** in dialog
7. Voice message recorded!

## Troubleshooting

### "Not Authenticated"
→ Check Supabase OAuth is configured
→ Try magic link instead

### Hotkey doesn't work
→ Grant Accessibility permission
→ Restart app

### "No text found"
→ Make sure text field is focused
→ Try selecting text explicitly

### Audio not playing
→ Check Multi-Output Device is selected
→ Test in Music app first

### Backend errors
→ Check Convex dashboard logs
→ Verify environment variables
→ Check API key validity

## What's Next?

- Customize tone presets in Settings
- Add your ElevenLabs voice clone
- Try in different apps (Slack, Discord, etc.)
- Read [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) to understand the code
- Check [docs/HACKATHON.md](docs/HACKATHON.md) for demo tips

## Need Help?

- See [docs/SETUP.md](docs/SETUP.md) for detailed guide
- Check [PROJECT_STATUS.md](PROJECT_STATUS.md) for what's implemented
- Review Xcode console for errors
- Check Convex dashboard for function logs

---

**Estimated time**: 30-40 minutes from scratch to working app! 🚀

