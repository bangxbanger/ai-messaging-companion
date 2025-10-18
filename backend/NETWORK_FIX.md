# Fix Network Permission Issue

## Problem
The macOS app can't connect to `127.0.0.1:8080` due to App Sandbox restrictions:
```
nw_socket_connect failed: [1: Operation not permitted]
```

## Solution
Add network entitlements to the Xcode project.

## Steps to Fix in Xcode

### Option 1: Add Entitlements File (Recommended)

1. **Open Xcode project**
   ```bash
   cd macos/CompanionApp
   open CompanionApp.xcodeproj
   ```

2. **Add the entitlements file**
   - In Project Navigator, select the `CompanionApp` target
   - Go to "Signing & Capabilities" tab
   - Click "+ Capability"
   - Add "App Sandbox" (if not already added)
   - Enable "Outgoing Connections (Client)" checkbox
   - Enable "Apple Events" checkbox

3. **Link the entitlements file**
   - Still in "Signing & Capabilities"
   - The entitlements file should auto-link to `App/CompanionApp.entitlements`
   - If not, manually set it in Build Settings → Code Signing Entitlements

4. **Build and Run** (⌘R)

### Option 2: Manual Entitlements Setup

If the file doesn't auto-link:

1. Open Xcode project
2. Select the **CompanionApp** target
3. Go to **Build Settings**
4. Search for "Code Signing Entitlements"
5. Set the value to: `App/CompanionApp.entitlements`
6. Clean Build Folder (⌘⇧K)
7. Build and Run (⌘R)

### Option 3: Quick Xcode UI Method

1. Open Xcode project
2. Select **CompanionApp** target
3. **Signing & Capabilities** tab
4. If "App Sandbox" exists:
   - ✅ Check "Outgoing Connections (Client)"
   - ✅ Check "Apple Events"
5. If "App Sandbox" doesn't exist:
   - Click "+ Capability"
   - Add "App Sandbox"
   - Then check the boxes above

## What the Entitlements File Does

```xml
<key>com.apple.security.network.client</key>
<true/>
```
- Allows outgoing HTTP/HTTPS connections
- Required to call `http://127.0.0.1:8080`

```xml
<key>com.apple.security.automation.apple-events</key>
<true/>
```
- Allows sending Apple Events to other apps
- May be needed for Accessibility features

## Verify It Works

After rebuilding:

1. Run the app
2. Press ⌥⌘R on some text
3. Check Console for successful API call
4. No more "Operation not permitted" errors!

## Alternative: Disable Sandbox (Not Recommended for Production)

If you want to quickly test without sandbox:

1. Open Xcode
2. Select target → "Signing & Capabilities"
3. Remove "App Sandbox" capability
4. Build and run

⚠️ **Warning**: This disables all sandbox protections. Only use for testing!

## Backend Status

✅ Backend is running: `http://127.0.0.1:8080`
✅ Health check works: `curl http://127.0.0.1:8080/health`

The issue is purely the app's network permissions, not the backend.

