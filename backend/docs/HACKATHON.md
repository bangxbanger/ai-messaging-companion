# Hackathon Submission Guide

## Project Overview

**Bro** is a macOS system-wide overlay that enhances messaging with AI-powered text rephrasing and voice generation. It works seamlessly across WhatsApp, Telegram, and any chat application.

## Sponsor Integration

This project showcases all four hackathon sponsors:

### 🚀 Groq

**Usage**: Real-time text rephrasing with streaming

- **Model**: Llama 3.1 70B (fastest inference available)
- **Implementation**: Streaming SSE endpoint for real-time overlay updates
- **Location**: `backend/convex/rephrase.ts`
- **Why**: Sub-second first-token latency critical for UX; Groq's speed makes the overlay feel instant

```typescript
const stream = await groq.chat.completions.create({
  model: 'llama-3.1-70b-versatile',
  messages: [
    { role: 'system', content: systemPrompt },
    { role: 'user', content: text },
  ],
  stream: true,
});
```

### 🎙️ ElevenLabs

**Usage**: AI voice cloning and text-to-speech

- **Model**: Eleven Turbo v2.5 (lowest latency)
- **Feature**: Clone user's voice for personalized voice messages
- **Implementation**: Audio generation injected via BlackHole virtual audio device
- **Location**: `backend/convex/tts.ts`
- **Why**: Natural-sounding voice with user's own tone; 1-3s generation time

```typescript
const audio = await elevenlabs.textToSpeech.convert(voiceId, {
  text,
  model_id: 'eleven_turbo_v2_5',
});
```

### 🗄️ Supabase

**Usage**: Authentication, user data, and settings storage

- **Auth**: OAuth (GitHub, Google) + Magic Link
- **Database**: PostgreSQL with Row Level Security
- **Tables**: `tone_presets`, `voices`, `usage_events`
- **Location**: `backend/supabase/schema.sql`, `macos/App/Services/SupabaseService.swift`
- **Why**: Secure multi-tenant architecture; seamless auth; real-time subscriptions for settings

```sql
-- RLS ensures data isolation
CREATE POLICY "Users can view their own tone presets"
  ON tone_presets FOR SELECT
  USING (auth.uid() = user_id);
```

### ⚡ Convex.dev

**Usage**: Serverless backend with streaming functions

- **Functions**: `/rephrase/stream`, `/tts/generate`, `/settings/*`, `/usage/*`
- **Features**: 
  - Streaming SSE responses for real-time updates
  - JWT validation with Supabase integration
  - Auto-scaling with zero config
  - Environment variable management
- **Location**: `backend/convex/`
- **Why**: Perfect for streaming AI responses; built-in TypeScript support; instant deployment

```typescript
export const stream = httpAction(async (ctx, request) => {
  const auth = await validateAuth(token);
  const stream = await groq.chat.completions.create({...});
  return new Response(readableStream, {
    headers: { 'Content-Type': 'text/event-stream' }
  });
});
```

## Demo Script

### Setup (Show First)

1. **Point out menu bar icon** - "Non-intrusive, always available"
2. **Open settings** - Show tone presets (Professional, Friendly, etc.)
3. **Show permissions** - Accessibility explained simply
4. **Show BlackHole setup** - Multi-output device for voice

### Feature 1: Text Rephrasing

1. **Open WhatsApp/Telegram**
2. **Type informal message**: "hey whats up, u free 2day?"
3. **Press ⌥⌘R**
4. **Overlay appears** with streaming text: "Hello! How are you doing? Are you available today?"
5. **Show edit capability** - Click edit, modify, save
6. **Click Accept** - Text auto-pastes into chat
7. **Switch tone preset** - Try "Professional" tone
8. **Type**: "sorry im late"
9. **Press ⌥⌘R**
10. **Result**: "I apologize for my tardiness."

### Feature 2: Voice Messages

1. **Select incoming message** in chat
2. **Press ⌥⌘V**
3. **Show generation progress** - ElevenLabs working
4. **Audio ready dialog appears**
5. **Hold voice button** in WhatsApp
6. **Click Play** in dialog
7. **Voice message sent** - with user's cloned voice!

### Feature 3: Sponsor Integration

**Show code snippets** (prepare screenshots):

- **Groq streaming** in `rephrase.ts`
- **ElevenLabs TTS** in `tts.ts`
- **Supabase RLS** in `schema.sql`
- **Convex functions** in `convex.json`

### Feature 4: Real-world Usage

**Show metrics dashboard** (if time permits):
- Usage events table
- Latency stats
- Token usage
- Tone preset popularity

## Technical Highlights

### Innovation

1. **System-wide overlay** - Works in ANY macOS app via Accessibility API
2. **Real-time streaming** - Text appears character-by-character
3. **Voice injection** - BlackHole virtual audio device trick
4. **Context-aware** - Detects chat apps, adjusts behavior
5. **Fallback mechanisms** - Clipboard if AX fails, manual paste option

### Architecture Strengths

- **Security**: Server-side API keys, JWT auth, RLS
- **Scalability**: Convex auto-scales, Supabase connection pooling
- **Performance**: Streaming UX, sub-second latency, local caching
- **Reliability**: Fallback methods, error handling, retry logic

### Code Quality

- **Type safety**: Swift + TypeScript throughout
- **Separation of concerns**: Clear service boundaries
- **Reusability**: Manager classes, shared types
- **Documentation**: Comprehensive README, setup guides, architecture docs

## Unique Selling Points

1. **Works everywhere**: Not just web - native macOS integration
2. **Instant**: Streaming makes it feel real-time
3. **Your voice**: ElevenLabs cloning personalizes messages
4. **Private**: No data stored, RLS enforced
5. **Sponsor showcase**: All four sponsors used meaningfully

## Demo Tips

### Preparation

- Pre-configure tone presets with good examples
- Have test messages ready to type
- Clone your voice in ElevenLabs beforehand
- Test BlackHole setup thoroughly
- Clear any existing chat history for clean demo

### Backup Plans

- If hotkey fails: Use menu bar → quick actions
- If AX blocked: Show clipboard fallback
- If voice fails: Have pre-recorded video
- If network issues: Show local demo with mock responses

### Talking Points

- "Groq's speed is critical - notice the instant streaming"
- "ElevenLabs voice quality is indistinguishable from real"
- "Supabase RLS means multi-tenant security out of the box"
- "Convex makes streaming functions trivial - check the code"

## Judging Criteria Alignment

### Technical Complexity

- ✅ macOS Accessibility API integration
- ✅ Real-time streaming architecture
- ✅ Audio routing via virtual devices
- ✅ Multi-service orchestration
- ✅ Secure JWT-based auth

### Sponsor Integration

- ✅ Groq: Streaming LLM inference
- ✅ ElevenLabs: Voice cloning + TTS
- ✅ Supabase: Auth + Database + RLS
- ✅ Convex: Serverless streaming functions

### Practical Value

- ✅ Solves real problem (communication enhancement)
- ✅ Works in real apps (WhatsApp, Telegram, etc.)
- ✅ Saves time (instant rephrasing)
- ✅ Improves communication quality

### Innovation

- ✅ System-wide overlay (not common)
- ✅ Voice injection technique (creative)
- ✅ Streaming overlay UI (smooth UX)
- ✅ Context-aware behavior

### Polish

- ✅ Native macOS UI (SwiftUI)
- ✅ Smooth animations
- ✅ Error handling
- ✅ Comprehensive docs

## Video Demo Structure (3-5 min)

1. **Intro (30s)**: Problem statement, show app icon
2. **Text Demo (90s)**: Two examples with different tones
3. **Voice Demo (60s)**: Generate and send voice message
4. **Code Tour (60s)**: Quick tour of sponsor integrations
5. **Outro (30s)**: Benefits, availability

## Deployment

**Backend**: Already deployed on Convex
```
https://your-project.convex.cloud
```

**macOS App**: 
- Notarized for easy distribution
- Available as direct download
- Source on GitHub

**Live Demo**: Have running instance ready

## Questions Prep

**Q: Does it work on Windows/Linux?**
A: Currently macOS only, but architecture is portable. Could build Windows version with similar APIs.

**Q: Privacy concerns?**
A: Text never stored. Usage logged but anonymized. RLS ensures data isolation. API keys server-side only.

**Q: Why not a browser extension?**
A: System-wide integration more powerful. Works in desktop apps, not just web. Native feel.

**Q: Cost to run?**
A: Free tier on all sponsors covers moderate usage. Usage tracking helps manage costs.

**Q: Can I customize tones?**
A: Yes! Settings allow creating custom tone presets with your own prompts.

## Post-Hackathon

- [ ] Open source on GitHub
- [ ] Submit to Product Hunt
- [ ] Write blog post on integration
- [ ] Create YouTube tutorial
- [ ] Gather user feedback
- [ ] Iterate on UX

## Contact

- GitHub: [your-username]
- Email: [your-email]
- Twitter: [your-handle]

---

**Thank you to Groq, ElevenLabs, Supabase, and Convex.dev for making this possible!** 🎉

