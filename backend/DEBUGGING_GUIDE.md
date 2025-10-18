# Debugging Guide for Bro

## What I Just Fixed

Added comprehensive debug logging throughout the app to help diagnose issues.

## How to Test

### 1. Run the App in Xcode

```bash
# Open the project
open /Users/bang.truong/Documents/Code/ai-messaging-companion/macos/CompanionApp.xcodeproj

# Then in Xcode, press ⌘R to run
```

### 2. Check the Xcode Console

After running, you should see console output like this:

```
🚀 Bro is launching...
✅ Menu bar setup complete
✨ Menu bar button created with wand.and.stars icon
✨ Popover created
✅ Hotkeys registered
✅ Rephrase hotkey registered: ⌥⌘R
✅ Voice hotkey registered: ⌥⌘V
✅ Permission check initiated
🔐 Checking accessibility permissions...
🔍 AccessibilityManager: checkAccessibilityPermission() returned false
🔐 Accessibility permission status: false
⚠️ Showing permission request dialog...
```

### 3. What You Should See

#### Menu Bar Icon
- Look in the **top-right corner** of your screen (menu bar)
- You should see a **⭐️ wand/stars icon**
- Click it to open the menu

#### Permission Dialog
- **~1 second after launch**, a dialog should appear
- Title: "Accessibility Permission Required"
- Two buttons: "Open System Settings" or "Later"

#### If You Click "Open System Settings"
- System Settings will open
- Navigate to: **Privacy & Security** → **Accessibility**
- Your app "Bro" should appear in the list
- **Enable the checkbox** next to it

### 4. Test the Hotkeys

After granting permission:

**Test Rephrase:**
1. Open Notes or TextEdit
2. Type some text: "hey whats up"
3. Press **⌥⌘R** (Option+Command+R)
4. Check Xcode console for: `⌨️ Rephrase hotkey triggered!`

**Test Voice:**
1. Select some text
2. Press **⌥⌘V** (Option+Command+V)
3. Check Xcode console for: `⌨️ Voice hotkey triggered!`

## Troubleshooting

### No Console Output
**Problem:** You don't see any emoji logs in Xcode console

**Solution:**
- Make sure you're running in Xcode (not just opening the .app file)
- Check the console is visible: View → Debug Area → Show Debug Area (⇧⌘Y)

### No Menu Bar Icon
**Problem:** Can't see the wand icon in menu bar

**Check console for:**
- ✅ vs ❌ for "Menu bar button created"
- If ❌, there's an issue with NSStatusBar

### App Crashes
**Problem:** App crashes on launch

**Check console for:**
- Any red error messages
- Stack traces
- Missing resources or files

### Permission Dialog Doesn't Show
**Problem:** No dialog appears after 1 second

**Possible causes:**
1. Dialog is behind other windows - check all desktops/spaces
2. App already has permission - check System Settings manually
3. Console shows what's happening - check the 🔐 messages

### Hotkeys Don't Work
**Problem:** Pressing ⌥⌘R does nothing

**Check:**
1. Console shows: ✅ or ❌ for hotkey registration
2. Try pressing the keys while focused on Xcode console to see trigger message
3. Another app might be using the same hotkey

## Expected Console Flow

```
🚀 Bro is launching...
✅ Menu bar setup complete
✨ Menu bar button created with wand.and.stars icon
✨ Popover created
✅ Hotkeys registered
✅ Rephrase hotkey registered: ⌥⌘R
✅ Voice hotkey registered: ⌥⌘V
✅ Permission check initiated
🔐 Checking accessibility permissions...
🔍 AccessibilityManager: checkAccessibilityPermission() returned false
🔐 Accessibility permission status: false
⚠️ Showing permission request dialog...
[User clicks button]
🔐 User response: Open Settings
[System Settings opens]
```

## Next Steps After Granting Permission

Once permission is granted:
1. Restart the app (⌘R in Xcode)
2. Console should show: `✅ Accessibility permission already granted`
3. Test hotkeys in any text field
4. Menu bar icon should work

## Common Issues

### "Nothing Happens"
- Check console output - it will tell you exactly what's happening
- Look for ❌ red X symbols - these indicate failures
- Look for ✅ green checkmarks - these indicate success

### "I granted permission but hotkeys don't work"
- Restart the app after granting permission
- Check hotkeys aren't conflicting with other apps
- Try in different apps (Notes, TextEdit, etc.)

### "Menu bar icon disappeared"
- App might have crashed - check Xcode console
- Check Activity Monitor for "Bro" process
- Restart the app

## Debug Output Legend

- 🚀 App lifecycle events
- ✅ Success / Completed
- ❌ Failure / Error
- ✨ UI elements created
- 🔐 Permission-related
- 🔍 Detailed inspection
- ⌨️ Hotkey triggered
- ⚠️ Warning

## Getting More Help

If issues persist:
1. Copy ALL console output
2. Note exactly what you see (or don't see)
3. Check Activity Monitor for the process
4. Try restarting your Mac

