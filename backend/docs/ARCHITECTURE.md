# Architecture Overview

## System Design

The Bro is built as three connected components:

1. **macOS Native App** (Swift/SwiftUI)
2. **Backend Functions** (Convex.dev)
3. **Database & Auth** (Supabase)

```
┌─────────────────────────────────────────────────────────────┐
│                       macOS Application                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Menu Bar   │  │   Overlay    │  │   Hotkeys    │      │
│  │   Interface  │  │   Window     │  │   Manager    │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│  ┌──────▼──────────────────▼──────────────────▼───────┐     │
│  │            Accessibility Manager                    │     │
│  │   (Read/Write text in any macOS app)              │     │
│  └──────────────────────────┬──────────────────────────┘     │
│                             │                                │
│  ┌──────────────────────────▼──────────────────────────┐     │
│  │              API Service Layer                      │     │
│  └──────────────────────────┬──────────────────────────┘     │
└─────────────────────────────┼──────────────────────────────┘
                              │ HTTPS + JWT
        ┌─────────────────────▼────────────────────┐
        │        Convex Backend Functions          │
        │  ┌────────────┐  ┌────────────┐         │
        │  │  Rephrase  │  │    TTS     │         │
        │  │  (Stream)  │  │ (Generate) │         │
        │  └─────┬──────┘  └─────┬──────┘         │
        │        │                │                 │
        │  ┌─────▼────────────────▼──────┐         │
        │  │    External AI Services     │         │
        │  │  • Groq (LLM)               │         │
        │  │  • ElevenLabs (TTS)         │         │
        │  └─────────────────────────────┘         │
        └─────────────────┬────────────────────────┘
                          │ SQL + RLS
        ┌─────────────────▼────────────────────┐
        │          Supabase                    │
        │  ┌────────────┐  ┌────────────┐     │
        │  │    Auth    │  │  Postgres  │     │
        │  │ (JWT)      │  │  Database  │     │
        │  └────────────┘  └────────────┘     │
        └──────────────────────────────────────┘
```

## Component Details

### macOS App

**Technology**: Swift 5.9+, SwiftUI, AppKit

**Key Classes**:

- `AppDelegate`: Main coordinator, hotkey registration, window management
- `AppState`: Observable state shared across views
- `AccessibilityManager`: Wraps macOS Accessibility APIs
- `HotkeyManager`: Registers and handles global keyboard shortcuts
- `AudioManager`: Audio playback using AVAudioEngine
- `APIService`: HTTP client for backend
- `SupabaseService`: Authentication and session management

**Data Flow**:

1. User presses hotkey → `HotkeyManager` fires callback
2. `AppDelegate` reads focused text via `AccessibilityManager`
3. Text sent to backend via `APIService` with JWT
4. Stream chunks arrive → overlay updates in real-time
5. User accepts → text written back via `AccessibilityManager`

### Backend (Convex)

**Technology**: TypeScript, Node.js 20, Convex runtime

**Endpoints**:

| Endpoint | Method | Purpose | Streaming |
|----------|--------|---------|-----------|
| `/rephrase/stream` | POST | Rephrase text via Groq | ✅ SSE |
| `/tts/generate` | POST | Generate audio via ElevenLabs | ❌ |
| `/tts/streamGenerate` | POST | Stream audio chunks | ✅ |
| `/settings/getTonePresets` | GET | List user's tone presets | ❌ |
| `/settings/createTonePreset` | POST | Create new preset | ❌ |
| `/settings/updateTonePreset` | POST | Update preset | ❌ |
| `/settings/deleteTonePreset` | DELETE | Delete preset | ❌ |
| `/settings/getVoices` | GET | List user's voices | ❌ |
| `/settings/addVoice` | POST | Add voice | ❌ |
| `/usage/getUsageStats` | GET | Get usage analytics | ❌ |
| `/usage/logEvent` | POST | Log usage event | ❌ |

**Authentication Flow**:

1. Extract `Authorization: Bearer <JWT>` header
2. Call `validateAuth(token)` → verifies with Supabase
3. Returns `{ userId, email }`
4. Use `userId` for RLS queries

**Key Functions**:

- `auth.ts`: JWT validation helpers
- `rephrase.ts`: Groq streaming proxy with tone prompts
- `tts.ts`: ElevenLabs audio generation
- `settings.ts`: CRUD for tone presets and voices
- `usage.ts`: Analytics and usage tracking

### Database (Supabase)

**Technology**: PostgreSQL 15, Row Level Security

**Schema**:

```sql
users (managed by auth.users)
  └─ id: uuid (pk)

tone_presets
  ├─ id: uuid (pk)
  ├─ user_id: uuid (fk → auth.users)
  ├─ name: text
  ├─ system_prompt: text
  ├─ style: jsonb
  ├─ is_default: boolean
  └─ created_at, updated_at: timestamptz

voices
  ├─ id: uuid (pk)
  ├─ user_id: uuid (fk → auth.users)
  ├─ eleven_voice_id: text
  ├─ display_name: text
  └─ created_at: timestamptz

usage_events
  ├─ id: uuid (pk)
  ├─ user_id: uuid (fk → auth.users)
  ├─ event_type: text ('rephrase' | 'tts')
  ├─ tokens_in, tokens_out: integer
  ├─ latency_ms: integer
  └─ created_at: timestamptz
```

**Row Level Security**:

- All tables: `auth.uid() = user_id` for SELECT/INSERT/UPDATE/DELETE
- Ensures users can only access their own data
- Service role key bypasses RLS (used in backend)

**Triggers**:

- `on_auth_user_created`: Seeds default tone presets for new users

## Key Interactions

### Text Rephrasing Flow

```
User presses ⌥⌘R
    ↓
AccessibilityManager reads focused text
    ↓
APIService.rephraseStream(text, tonePresetId)
    ↓
Convex validates JWT
    ↓
Fetch tone preset from Supabase
    ↓
Groq streaming call
    ↓
For each chunk:
    → Send SSE event to client
    → Update overlay UI
    ↓
On complete:
    → Log usage event to Supabase
    → User clicks "Accept"
    ↓
AccessibilityManager replaces text
```

### Voice Message Flow

```
User presses ⌥⌘V
    ↓
AccessibilityManager reads selected text
    ↓
APIService.generateTTS(text, voiceId)
    ↓
Convex validates JWT
    ↓
Fetch voice from Supabase (or use default)
    ↓
ElevenLabs TTS call
    ↓
Return audio data (MP3)
    ↓
AudioManager plays to BlackHole
    ↓
User holds voice button in chat app
    ↓
Audio captured as mic input
```

## Security Considerations

### API Keys

- ✅ All keys stored server-side (Convex environment variables)
- ✅ Never exposed to client
- ✅ Supabase anon key is public (safe for client-side auth)
- ❌ Service role key must never be in client

### Authentication

- JWT issued by Supabase
- Validated on every backend request
- Expires after configurable duration
- Refresh tokens stored locally (encrypted by macOS keychain)

### Permissions

- Accessibility: Read/write UI elements
- Input Monitoring: Capture hotkeys
- Microphone: Not used (audio playback only)
- Screen Recording: Optional fallback for OCR

### Data Privacy

- Text never stored long-term
- Usage events logged (anonymized)
- RLS ensures data isolation
- Audio files deleted after playback

## Performance

### Latency Targets

- Rephrase start: < 500ms (first token)
- Rephrase complete: 2-5s (depends on length)
- TTS generation: 1-3s
- Overlay show: < 100ms

### Optimizations

- Streaming responses (SSE) for real-time feedback
- Groq Llama 3.1 (fast inference)
- ElevenLabs Turbo v2.5 (low latency TTS)
- Local caching of tone presets
- Parallel API calls where possible

### Scalability

- Convex auto-scales functions
- Supabase connection pooling
- Rate limiting per user (configurable)
- Usage tracking for billing/limits

## Error Handling

### macOS App

- Accessibility denied → Prompt user to enable
- No text found → Show alert
- API error → Show user-friendly message
- Network timeout → Retry with backoff

### Backend

- Invalid JWT → 401 Unauthorized
- Missing parameters → 400 Bad Request
- Groq/ElevenLabs error → 500 with detail
- Rate limit exceeded → 429 with retry-after

### Database

- Constraint violation → Caught and returned as error
- RLS denial → Empty result (graceful)
- Connection timeout → Retry automatically

## Testing Strategy

### Unit Tests

- Accessibility functions (mocked)
- API service (mocked responses)
- Auth token validation
- Tone preset CRUD

### Integration Tests

- Supabase connection
- Convex function calls
- Groq/ElevenLabs (with test keys)

### Manual Tests

- Hotkey registration in various apps
- Text capture in WhatsApp, Telegram, etc.
- Audio playback with BlackHole
- OAuth flows

## Deployment

### Backend

```bash
cd backend/convex
npx convex deploy --prod
```

Sets environment variables in dashboard.

### macOS App

1. Archive in Xcode
2. Export for distribution
3. Notarize with Apple
4. Distribute via:
   - Direct download
   - Homebrew cask
   - Mac App Store (requires review)

### Database

- Supabase hosted (no deployment needed)
- Migrations via SQL editor or CLI
- Backups automated by Supabase

## Monitoring

- Convex: Function logs, latency, errors
- Supabase: Query performance, auth events
- Client: Xcode console, crash reports
- Usage: Custom analytics table

## Future Enhancements

- [ ] Custom hotkey configuration
- [ ] More LLM providers (OpenAI, Anthropic)
- [ ] Context-aware rephrasing (conversation history)
- [ ] Real-time voice streaming
- [ ] Browser extension for web apps
- [ ] Mobile companion app
- [ ] Team sharing of tone presets

