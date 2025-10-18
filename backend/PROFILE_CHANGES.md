# Profile & Hotkey Update Summary

## Changes Made

### 1. ✅ Profile Names Changed

**Old Profiles:**
- `formal` - Professional, precise
- `bestie` - Warm, friendly
- `degen` - Crypto degen slang
- `flirty` - Playful, flirty

**New Profiles:**
- `nice_guy` - Kind, thoughtful, polite, calm, and understanding
- `meme_god` - Pure vibes, funny, dramatic, lowercase chaos with meme energy
- `no_filter` - Direct, confident, efficient, no fluff

### 2. ✅ Hotkey Changed

**Old:** `⌥⌘R` (Option + Command + R)  
**New:** `⇧Space` (Shift + Space)

---

## Files Updated

### Backend (Python FastAPI)

#### ✅ `backend-fastapi/main.py`
- Already had the new profiles configured:
  - `nice_guy` - "Rewrite like a genuinely kind, thoughtful person..."
  - `meme_god` - "Rewrite like someone who texts with pure vibes..."
  - `no_filter` - "Rewrite like someone who has zero time for fluff..."

### macOS App (Swift)

#### ✅ `macos/CompanionApp/App/Models/Models.swift`
```swift
enum ToneProfile: String, CaseIterable, Codable {
    case nice_guy
    case meme_god
    case no_filter
    
    var displayName: String {
        switch self {
        case .nice_guy: return "Nice Guy"
        case .meme_god: return "Meme God"
        case .no_filter: return "No Filter"
        }
    }
}
```

#### ✅ `macos/CompanionApp/App/AppState.swift`
- Changed default profile: `.formal` → `.nice_guy`
- Updated fallback profiles array

#### ✅ `macos/CompanionApp/App/Views/SettingsView.swift`
- Updated profile descriptions
- Changed display to use `profile.displayName` instead of `profile.rawValue.capitalized`
- Updated hotkey display: `⌥⌘R` → `⇧Space`

#### ✅ `macos/CompanionApp/App/Views/MenuBarView.swift`
- Changed profile display to use `profile.displayName`
- Updated hotkey display: `⌥⌘R` → `⇧Space`

#### ✅ `macos/CompanionApp/App/Config.swift`
- Changed rephrase hotkey:
  - From: `(keyCode: UInt32(15), modifiers: UInt32(768))` // ⌥⌘R
  - To: `(keyCode: UInt32(49), modifiers: UInt32(131330))` // ⇧Space

---

## Profile Descriptions

### Nice Guy 😊
**Backend Prompt:** "Rewrite like a genuinely kind, thoughtful person who wants to sound polite, calm, and understanding. Empathetic phrasing, soft edges, maybe one wholesome emoji."

**UI Description:** "Kind, thoughtful, polite, calm, and understanding. Empathetic with soft edges."

### Meme God 🔥
**Backend Prompt:** "Rewrite like someone who texts with pure vibes and no proofreading. Funny, dramatic, and unpredictable. Lowercase chaos with the occasional meme energy."

**UI Description:** "Pure vibes, funny, dramatic. Lowercase chaos with meme energy."

### No Filter 💯
**Backend Prompt:** "Rewrite like someone who has zero time for fluff. Direct, confident, and efficient. No filler words, no emojis, no hedging. Get to the point and move on."

**UI Description:** "Direct, confident, efficient. No fluff, no emojis, straight to the point."

---

## How to Test

1. **Restart the FastAPI backend** (if it's running):
   ```bash
   cd /Users/bang.truong/Documents/Code/ai-messaging-companion/backend-fastapi
   source .venv/bin/activate
   uvicorn main:app --host 127.0.0.1 --port 8080 --reload
   ```

2. **Clean and rebuild the macOS app in Xcode**:
   - Press `⌘⇧K` (Clean Build Folder)
   - Press `⌘R` (Run)

3. **Test the new hotkey**:
   - Select some text in any app
   - Press `Shift + Space` (instead of Option + Command + R)
   - The overlay should appear with rephrasing

4. **Test the profiles**:
   - Click the menu bar icon
   - Select different tone profiles: Nice Guy, Meme God, No Filter
   - Try rephrasing the same text with different profiles

---

## Notes

- All profile keys use snake_case (`nice_guy`, `meme_god`, `no_filter`) for consistency with Python backend
- Display names use proper capitalization ("Nice Guy", "Meme God", "No Filter") in the UI
- The new Shift+Space hotkey is more convenient and less likely to conflict with app shortcuts
- No linter errors detected in any of the updated Swift files

