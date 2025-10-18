# macOS App

## Building the App

### Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9+

### Setup

1. **Open the project**
   ```bash
   cd macos
   open CompanionApp.xcodeproj
   ```
   
   Note: If you don't have an `.xcodeproj` file yet, create one:
   - Open Xcode
   - Create a new macOS App project
   - Set Product Name to "Bro"
   - Set Bundle Identifier to "com.yourcompany.ai-messaging-companion"
   - Choose SwiftUI interface and Swift language
   - Save to the `macos` directory

2. **Configure the project**
   - Set minimum deployment target to macOS 13.0
   - Add required frameworks:
     - `AVFoundation.framework`
     - `Carbon.framework`
     - `ApplicationServices.framework`

3. **Update Config.swift**
   - Replace the placeholder URLs and keys with your actual backend URLs
   - Get your Supabase anon key from the Supabase dashboard

4. **Build and run**
   - Select your signing team
   - Build: `⌘B`
   - Run: `⌘R`

### File Structure

Add all files from the `App/` directory to your Xcode project:

```
App/
├── CompanionApp.swift          # Main app entry point
├── AppDelegate.swift           # App lifecycle and hotkeys
├── AppState.swift              # Shared app state
├── Config.swift                # Configuration constants
├── Models/
│   └── Models.swift            # Data models
├── Services/
│   ├── APIService.swift        # Backend API client
│   └── SupabaseService.swift  # Authentication
├── Utilities/
│   ├── AccessibilityManager.swift  # AX API wrapper
│   ├── HotkeyManager.swift         # Global hotkeys
│   └── AudioManager.swift          # Audio playback
└── Views/
    ├── MenuBarView.swift       # Menu bar popover
    ├── OverlayWindow.swift     # Text overlay
    ├── AuthView.swift          # Sign in UI
    └── SettingsView.swift      # Settings UI
```

### Signing & Notarization

For distribution:

1. **Code signing**
   - Use your Apple Developer certificate
   - Enable hardened runtime
   - Add entitlements (see below)

2. **Entitlements**
   Create `CompanionApp.entitlements`:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>com.apple.security.automation.apple-events</key>
       <true/>
       <key>com.apple.security.device.audio-input</key>
       <true/>
   </dict>
   </plist>
   ```

3. **Notarization**
   ```bash
   # Build and archive
   xcodebuild -scheme "Bro" -archivePath "build/App.xcarchive" archive
   
   # Export for notarization
   xcodebuild -exportArchive -archivePath "build/App.xcarchive" -exportPath "build" -exportOptionsPlist ExportOptions.plist
   
   # Submit for notarization
   xcrun notarytool submit "build/Bro.app.zip" --apple-id "your@email.com" --team-id "TEAMID" --wait
   
   # Staple notarization ticket
   xcrun stapler staple "build/Bro.app"
   ```

## Usage

### First Run

1. The app will appear in your menu bar as a wand icon
2. Click the icon to open the menu
3. Click "Sign In" and authenticate with Supabase
4. The app will prompt for Accessibility permission - enable it in System Settings

### Hotkeys

- **⌥⌘R** (Option+Command+R): Rephrase focused text
- **⌥⌘V** (Option+Command+V): Generate voice message

### Audio Setup for Voice Messages

1. Install BlackHole:
   ```bash
   brew install blackhole-2ch
   ```

2. Create a Multi-Output Device:
   - Open Audio MIDI Setup (in Applications/Utilities)
   - Click the "+" button and select "Create Multi-Output Device"
   - Check both "BlackHole 2ch" and your speakers/headphones
   - Set this as your default output

3. When using voice messages:
   - Press ⌥⌘V to generate audio
   - Hold the voice button in WhatsApp/Telegram
   - Click "Play" in the app dialog
   - The audio will be captured as microphone input

## Troubleshooting

### Hotkeys not working
- Check that the app has Accessibility permission
- Try quitting and restarting the app

### Text not pasting
- Ensure Accessibility permission is enabled
- Some apps may block AX modification - use manual paste as fallback

### Audio not playing
- Check your output device is set correctly
- For voice messages, ensure BlackHole is in your Multi-Output Device

### API errors
- Verify your Config.swift has correct backend URLs
- Check that you're signed in (click menu bar icon)
- Ensure backend is deployed and running

## Development

### Debug Logging

Add logging to troubleshoot issues:

```swift
// In AppDelegate
func handleRephraseHotkey() {
    print("Hotkey triggered")
    print("Is authenticated: \(AppState.shared.isAuthenticated)")
    // ... rest of function
}
```

### Testing Accessibility

Test AX reading without hotkeys:

```swift
let text = AccessibilityManager.shared.readFocusedText()
print("Read text: \(text ?? "nil")")
```

### Simulating Backend

For offline development, mock the API service responses.

## License

MIT

