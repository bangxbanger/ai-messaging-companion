# Bro for macOS

A system-wide overlay that enhances your messaging experience with AI-powered text rephrasing and voice generation.

## Features

- **Text Rephrasing**: Global hotkey to rewrite text with customizable tones using Groq
- **Voice Messages**: Generate voice replies with ElevenLabs voice cloning
- **System-Wide**: Works across WhatsApp, Telegram, and any macOS app
- **Real-time Streaming**: Fast response with streaming UI updates
- **Secure**: Server-side API keys, authenticated via Supabase

## Tech Stack

- **macOS App**: Swift/SwiftUI with Accessibility API
- **LLM**: Groq (Llama 3.1)
- **TTS**: ElevenLabs
- **Backend**: Convex.dev (serverless functions)
- **Database**: Supabase (auth, settings, usage tracking)
- **Audio Routing**: BlackHole virtual audio device

## Setup

### Prerequisites

1. **BlackHole**: Install virtual audio device
   ```bash
   brew install blackhole-2ch
   ```

2. **Xcode**: Required for building the macOS app
   ```bash
   xcode-select --install
   ```

3. **API Keys**: Get keys from:
   - [Groq](https://console.groq.com)
   - [ElevenLabs](https://elevenlabs.io)
   - [Supabase](https://supabase.com)
   - [Convex](https://convex.dev)

### Installation

1. Clone the repository
2. Set up backend (see `backend/README.md`)
3. Build macOS app (see `macos/README.md`)
4. Configure permissions in System Settings → Privacy & Security:
   - Accessibility
   - Input Monitoring

## Usage

### Text Rephrasing
1. Type your message in any chat app
2. Press `⌥⌘R` (Option+Command+R)
3. Review the AI-rephrased text in the overlay
4. Click "Accept" to copy and paste, or "Edit" to modify

### Voice Messages
1. Select text you want to reply to
2. Press `⌥⌘V` (Option+Command+V)
3. Hold the voice message button in your chat app
4. The AI-generated voice plays through your microphone

## Architecture

See [mac.plan.md](/mac.plan.md) for detailed architecture and implementation plan.

## License

MIT

