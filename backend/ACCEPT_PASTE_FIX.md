# Accept & Paste Fix

## Problem
When clicking "Accept & Paste" in the overlay, the rephrased text was not replacing the highlighted/selected text in the input field.

## Root Cause
The `replaceFocusedText` function in `AccessibilityManager.swift` was only trying to set the entire field value using `kAXValueAttribute`, which doesn't properly handle replacing **selected text**. It needed to:

1. Check if there is selected text
2. Replace only the selected portion (not the entire field)
3. Fall back to clipboard paste if direct replacement fails

## Changes Made

### 1. ✅ Updated `AccessibilityManager.swift` - `replaceFocusedText` function

**Before:**
```swift
func replaceFocusedText(with newText: String) -> Bool {
    // ... get focused element ...
    
    // Try to set the value directly (replaces entire field)
    let setValue = AXUIElementSetAttributeValue(
        element,
        kAXValueAttribute as CFString,
        newText as CFTypeRef
    )
    
    if setValue == .success {
        return true
    }
    
    // Fallback to clipboard + paste
    return fallbackWriteViaClipboard(text: newText)
}
```

**After:**
```swift
func replaceFocusedText(with newText: String) -> Bool {
    // ... get focused element ...
    
    // 1. First, check if there's selected text
    var selectedText: CFTypeRef?
    let selectedResult = AXUIElementCopyAttributeValue(
        element,
        kAXSelectedTextAttribute as CFString,
        &selectedText
    )
    
    // 2. If there's selected text, replace it specifically
    if selectedResult == .success, let text = selectedText as? String, !text.isEmpty {
        // Try to replace the selected text
        let setSelectedText = AXUIElementSetAttributeValue(
            element,
            kAXSelectedTextAttribute as CFString,
            newText as CFTypeRef
        )
        
        if setSelectedText == .success {
            return true
        }
    }
    
    // 3. If no selection, try to set the entire value
    let setValue = AXUIElementSetAttributeValue(
        element,
        kAXValueAttribute as CFString,
        newText as CFTypeRef
    )
    
    if setValue == .success {
        return true
    }
    
    // 4. Final fallback to clipboard + paste method
    return fallbackWriteViaClipboard(text: newText)
}
```

### 2. ✅ Updated `AppDelegate.swift` - `acceptRephrase` function

**Improvements:**
- Added debug logging to track the replacement flow
- Hide overlay **first** before attempting paste (so focus can return to the input field)
- Increased delay from 0.1s to 0.2s to give more time for focus restoration
- Added informative alert if direct replacement fails
- Copy to clipboard happens before replacement attempt (as a safety net)

**Updated Flow:**
```swift
func acceptRephrase() {
    print("✅ Accept & Paste called")
    
    // 1. Hide overlay first (restores focus to input field)
    hideOverlay()
    
    // 2. Wait for overlay to close and focus to restore
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
        // 3. Copy to clipboard (safety net)
        pasteboard.setString(self.rephrasedText, forType: .string)
        
        // 4. Try direct text replacement (handles selected text)
        let success = AccessibilityManager.shared.replaceFocusedText(
            with: self.rephrasedText
        )
        
        // 5. If direct fails, fallback (clipboard paste) was triggered
        if !success {
            self.showAlert(/* helpful message */)
        }
    }
}
```

## How It Works Now

### Scenario 1: Selected Text (Most Common)
1. User highlights text in a chat app
2. Presses `⌥⌘R` hotkey
3. Overlay shows rephrased version
4. User clicks "Accept & Paste"
5. **New behavior:** The selected text is replaced directly using `kAXSelectedTextAttribute`
6. If that fails, fallback to Cmd+V paste

### Scenario 2: Cursor in Input Field (No Selection)
1. User focuses input field (no text selected)
2. Presses `⌥⌘R` hotkey
3. Overlay shows rephrased version
4. User clicks "Accept & Paste"
5. **New behavior:** Entire field value is replaced using `kAXValueAttribute`
6. If that fails, fallback to Cmd+V paste

### Scenario 3: App Doesn't Support Accessibility API
1. Direct replacement fails (both methods)
2. **Fallback:** Simulates Cmd+V paste using the clipboard
3. Text is pasted at cursor position
4. Original clipboard is restored after 0.5s

## Testing Checklist

- [ ] Test in **WhatsApp Web** (Chrome/Safari)
- [ ] Test in **Telegram Desktop**
- [ ] Test in **iMessage**
- [ ] Test in **Slack**
- [ ] Test in **Discord**
- [ ] Test with **selected text** (highlight then press hotkey)
- [ ] Test with **cursor in empty field** (no selection)
- [ ] Test with **entire message selected**
- [ ] Test with **partial text selected**

## Debug Output

When you click "Accept & Paste", you'll see console logs like:
```
✅ Accept & Paste called
   Original text: Hello world
   Rephrased text: Greetings, world!
🔄 Attempting to replace text...
   Direct replacement success: true
```

Or if it falls back:
```
✅ Accept & Paste called
   Original text: Hello world
   Rephrased text: Greetings, world!
🔄 Attempting to replace text...
   Direct replacement success: false
   Fallback to clipboard paste was triggered
```

## Additional Notes

- The fix prioritizes **selected text replacement** over full field replacement
- Multiple fallback layers ensure text replacement works even in tricky apps
- Clipboard is safely preserved and restored in fallback scenarios
- Focus restoration delay (0.2s) helps ensure the input field regains focus before paste
- Debug logging helps diagnose issues if text replacement still fails in specific apps

## If It Still Doesn't Work

If "Accept & Paste" still doesn't work in a specific app:

1. **Check Accessibility Permissions:** System Settings → Privacy & Security → Accessibility → Enable "Bro"
2. **Check Console Logs:** Look for the debug output to see which method failed
3. **Manual Paste:** The text is always copied to clipboard, so pressing `⌘V` will work
4. **App-Specific Issues:** Some apps (like WhatsApp Web in a browser) may have limited Accessibility API support

