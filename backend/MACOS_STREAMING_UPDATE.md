# macOS Streaming Implementation Update

## Summary

Updated macOS app to use **streaming SSE (Server-Sent Events)** for real-time text rephrasing as specified in the original plan, while keeping the backend implementation unchanged.

## Changes Made

### APIService.swift

#### Added: `rephraseStream()` method
```swift
func rephraseStream(text: String,
                   profile: ToneProfile,
                   onChunk: @escaping (String) -> Void,
                   onComplete: @escaping (Result<Void, Error>) -> Void)
```

**Features:**
- ✅ Calls `POST /rephrase/stream` endpoint
- ✅ Parses SSE (Server-Sent Events) format
- ✅ Streams text chunks in real-time via `onChunk` callback
- ✅ Handles completion/errors via `onComplete` callback
- ✅ Supports all tone profiles (formal, bestie, degen, flirty)

#### Kept: `rephrase()` method (fallback)
```swift
func rephrase(text: String,
              profile: ToneProfile,
              completion: @escaping (Result<String, Error>) -> Void)
```

**Features:**
- ✅ Synchronous API call to `POST /rephrase`
- ✅ Returns complete rephrased text
- ✅ Can be used as fallback if streaming endpoint not available

#### Added: `SSEEvent` model
```swift
struct SSEEvent: Decodable {
    let content: String?
    let done: Bool?
    let error: String?
}
```

**Handles:**
- `content`: Text chunks from streaming
- `done`: Stream completion signal
- `error`: Error messages from backend

### AppDelegate.swift

#### Updated: `handleRephraseHotkey()`
```swift
// Now uses streaming instead of synchronous API
APIService.shared.rephraseStream(
    text: text,
    profile: profile,
    onChunk: { [weak self] chunk in
        self?.rephrasedText += chunk
        self?.updateOverlay()
    },
    onComplete: { [weak self] result in
        self?.isStreaming = false
        self?.updateOverlay()
        
        if case .failure(let error) = result {
            self?.hideOverlay()
            self?.showAlert(title: "Error", message: error.localizedDescription)
        }
    }
)
```

**UX Improvements:**
- ✅ Text appears character-by-character (streaming effect)
- ✅ Overlay updates in real-time
- ✅ Better feedback during long rephrasing
- ✅ Graceful error handling

## API Endpoints

### Current Backend Support

The macOS app now calls:

1. **POST /rephrase/stream** (Primary - Streaming)
   - Request: `{ "text": "...", "profile": "formal" }`
   - Response: SSE stream with `data: {"content": "..."}` chunks
   - Used by: `rephraseStream()` method

2. **POST /rephrase** (Fallback - Synchronous)
   - Request: `{ "text": "...", "profile": "formal" }`
   - Response: `{ "rephrased_text": "..." }`
   - Used by: `rephrase()` method (kept for compatibility)

3. **GET /profiles**
   - Response: `{ "profiles": ["formal", "bestie", "degen", "flirty"] }`

4. **GET /health**
   - Response: `{ "ok": true }`

## Backend Requirements

For streaming to work, the backend needs to implement `/rephrase/stream` endpoint:

```python
@app.post("/rephrase/stream")
async def rephrase_stream(body: RephraseReq):
    # ... validation ...
    
    stream = client.chat.completions.create(
        model="llama-3.1-70b-versatile",
        messages=[...],
        stream=True,  # Enable streaming
    )
    
    async def sse_gen():
        for chunk in stream:
            content = chunk.choices[0].delta.get("content", "")
            if content:
                yield f"data: {{\"content\": {content!r}}}\n\n"
        yield "data: {\"done\": true}\n\n"
    
    return StreamingResponse(sse_gen(), media_type="text/event-stream")
```

## Testing

### With Streaming Backend
1. Backend implements `/rephrase/stream` → Real-time streaming UX
2. Text appears character-by-character
3. Fast and responsive

### Without Streaming Backend
1. Backend only has `/rephrase` → Falls back to synchronous
2. Need to update AppDelegate to use `rephrase()` instead
3. Text appears all at once (less cool but works)

## User Experience

### Before (Synchronous)
```
User presses ⌥⌘R
↓
Shows "Rephrasing..." overlay
↓
[Wait 2-5 seconds]
↓
Complete text appears suddenly
```

### After (Streaming)
```
User presses ⌥⌘R
↓
Shows "Rephrasing..." overlay
↓
Text streams in character-by-character
"Hello" → "Hello, how" → "Hello, how are" → "Hello, how are you?"
↓
Complete!
```

## Summary of Methods

| Method | Endpoint | Type | Use Case |
|--------|----------|------|----------|
| `rephraseStream()` | `/rephrase/stream` | SSE Streaming | Primary - Real-time UX |
| `rephrase()` | `/rephrase` | Synchronous | Fallback/compatibility |
| `getProfiles()` | `/profiles` | Synchronous | Load available profiles |
| `healthCheck()` | `/health` | Synchronous | Backend status check |

## Files Modified

- ✅ `APIService.swift` - Added streaming method + SSEEvent model
- ✅ `AppDelegate.swift` - Updated to use streaming
- ⏸️ Backend unchanged (as requested)

## Next Steps

To enable streaming in the backend, add the `/rephrase/stream` endpoint as shown in the backend requirements section above.

