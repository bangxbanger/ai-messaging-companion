# Complete Setup Guide

This guide walks you through setting up the Bro from scratch.

## Prerequisites

- macOS 13.0+ (for the app)
- Node.js 20+ (for backend)
- Xcode 15+ (for building the app)
- API accounts:
  - Groq
  - ElevenLabs
  - Supabase
  - Convex

## Step 1: Get API Keys

### Groq

1. Go to [console.groq.com](https://console.groq.com)
2. Sign up or log in
3. Navigate to API Keys
4. Create a new API key
5. Save it securely

### ElevenLabs

1. Go to [elevenlabs.io](https://elevenlabs.io)
2. Sign up or log in
3. Go to Profile → API Key
4. Copy your API key
5. (Optional) Create a voice clone in Voice Library

### Supabase

1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Wait for project to be ready (~2 minutes)
4. Go to Settings → API
5. Note down:
   - Project URL
   - `anon` public key
   - `service_role` secret key (keep this secure!)

### Convex

1. Go to [convex.dev](https://convex.dev)
2. Sign up or log in
3. Create a new project
4. Note down your deployment URL

## Step 2: Set Up Supabase

### Run SQL Schema

1. Open your Supabase project
2. Go to SQL Editor
3. Copy contents of `backend/supabase/schema.sql`
4. Paste and run
5. Copy contents of `backend/supabase/seed.sql`
6. Paste and run

### Enable Authentication

1. Go to Authentication → Providers
2. Enable Email (for magic link)
3. Enable GitHub:
   - Create a GitHub OAuth app at [github.com/settings/developers](https://github.com/settings/developers)
   - Set callback URL to: `https://your-project.supabase.co/auth/v1/callback`
   - Copy Client ID and Secret to Supabase
4. Enable Google:
   - Create OAuth credentials in [Google Cloud Console](https://console.cloud.google.com/)
   - Set callback URL to: `https://your-project.supabase.co/auth/v1/callback`
   - Copy Client ID and Secret to Supabase

### Configure Email (for magic links)

1. Go to Authentication → Email Templates
2. Customize magic link email (optional)
3. Set up SMTP (optional, uses Supabase's by default)

## Step 3: Set Up Convex

### Install and Initialize

```bash
cd backend/convex
npm install
npx convex dev
```

This will:
- Create a `.convex` folder
- Generate necessary config files
- Start a local dev server

### Set Environment Variables

In the Convex dashboard:

1. Go to Settings → Environment Variables
2. Add:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_SERVICE_KEY=your-service-role-key
   GROQ_API_KEY=your-groq-api-key
   ELEVENLABS_API_KEY=your-elevenlabs-api-key
   ```

### Deploy

```bash
npx convex deploy
```

Note your deployment URL (e.g., `https://xyz.convex.cloud`)

## Step 4: Install BlackHole

BlackHole is a virtual audio device that allows routing audio between applications.

```bash
brew install blackhole-2ch
```

### Create Multi-Output Device

1. Open **Audio MIDI Setup** (in Applications/Utilities)
2. Click the **+** button at bottom left
3. Select **Create Multi-Output Device**
4. In the right panel, check:
   - ☑ BlackHole 2ch
   - ☑ Your speakers/headphones
5. Optionally rename to "BlackHole + Speakers"
6. Right-click and select "Use This Device For Sound Output"

This allows you to hear the generated audio while also sending it as input.

## Step 5: Build the macOS App

### Create Xcode Project

1. Open Xcode
2. File → New → Project
3. Choose **macOS** → **App**
4. Settings:
   - Product Name: `Bro`
   - Team: Your Apple Developer team
   - Organization Identifier: `com.yourcompany`
   - Interface: **SwiftUI**
   - Language: **Swift**
5. Save to `macos` directory

### Add Files to Project

1. In Xcode, right-click on the project navigator
2. Add Files to "Bro"
3. Select all files from `macos/CompanionApp/App/`
4. Ensure "Copy items if needed" is checked
5. Add to targets: Bro

### Configure Project Settings

1. Select project in navigator
2. Under **Signing & Capabilities**:
   - Select your team
   - Bundle Identifier: `com.yourcompany.ai-messaging-companion`
3. Under **Info**:
   - Minimum Deployment: macOS 13.0
   - Replace `Info.plist` contents with the one from the project
4. Under **Build Settings**:
   - Search for "Hardened Runtime"
   - Set to "Yes"

### Add Frameworks

1. Select target → General → Frameworks and Libraries
2. Click **+** and add:
   - `AVFoundation.framework`
   - `Carbon.framework`
   - `ApplicationServices.framework`

### Update Config.swift

Open `Config.swift` and update:

```swift
static let convexURL = "https://your-project.convex.cloud"
static let supabaseURL = "https://your-project.supabase.co"
static let supabaseAnonKey = "your-anon-key"
```

### Build and Run

1. Press **⌘B** to build
2. Fix any compilation errors
3. Press **⌘R** to run
4. The app will appear in your menu bar

## Step 6: Grant Permissions

### Accessibility Permission

1. Open **System Settings**
2. Go to **Privacy & Security** → **Accessibility**
3. Click the lock to make changes
4. Find "Bro" and enable it
5. If not listed, click **+** and browse to the app

The app will prompt you if permission is needed.

## Step 7: Test the App

### Sign In

1. Click the wand icon in menu bar
2. Click "Sign In"
3. Use GitHub, Google, or magic link
4. App should show "Connected"

### Test Text Rephrasing

1. Open any text field (Notes, Messages, etc.)
2. Type some text
3. Press **⌥⌘R** (Option+Command+R)
4. Overlay should appear with AI-rephrased text
5. Click "Accept & Paste"

### Test Voice Messages

1. Have text selected or in focus
2. Press **⌥⌘V** (Option+Command+V)
3. Wait for audio generation
4. Open WhatsApp/Telegram
5. Hold voice message button
6. Click "Play" in the app dialog
7. Audio should be recorded

## Troubleshooting

### "Not Authenticated" Error

- Click menu bar icon and sign in
- Check that Supabase auth is configured
- Check browser for OAuth redirects

### Hotkeys Don't Work

- Ensure Accessibility permission is enabled
- Quit and restart the app
- Check System Settings → Keyboard → Keyboard Shortcuts for conflicts

### No Text Captured

- Check Accessibility permission
- Try selecting text explicitly
- Some apps (like browsers) may need additional permissions

### Audio Not Playing

- Check output device in System Settings → Sound
- Ensure Multi-Output Device is created and selected
- Test audio with Music app first

### API Errors

- Check Convex dashboard logs
- Verify environment variables are set
- Check API key validity
- Look at Xcode console for error messages

### Overlay Not Showing

- Check screen recording permission (if using OCR fallback)
- Try with a simple app like TextEdit first
- Check Xcode console for errors

## Next Steps

- Customize tone presets in the app settings
- Add your ElevenLabs voice clone
- Adjust hotkeys in code if needed
- Read [ARCHITECTURE.md](./ARCHITECTURE.md) for code structure
- See [CONTRIBUTING.md](./CONTRIBUTING.md) for development guidelines

## Getting Help

- Check GitHub issues
- Review Xcode console logs
- Check Convex dashboard for function errors
- Review Supabase logs for auth issues

