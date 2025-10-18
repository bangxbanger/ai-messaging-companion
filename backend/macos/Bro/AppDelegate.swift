//
//  AppDelegate.swift
//  Bro
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var overlayWindow: OverlayWindow?
    
    // State for overlay
    var rephrasedText = ""
    var isStreaming = false
    var originalText = ""
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 Bro is launching...")
        print("📍 Current working directory: \(FileManager.default.currentDirectoryPath)")
        print("📍 Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
        
        // Create menu bar item
        setupMenuBar()
        print("✅ Menu bar setup complete")
        
        // Verify status item exists
        if statusItem != nil {
            print("✅ Status item created and retained")
        } else {
            print("❌ Status item is nil!")
        }
        
        // Register hotkeys
        setupHotkeys()
        print("✅ Hotkeys registered")
        
        // Check permissions
        checkPermissions()
        print("✅ Permission check initiated")
        
        // Show a notification to confirm app launched
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let notification = NSUserNotification()
            notification.title = "Bro"
            notification.informativeText = "App is running! Look for ✨ in menu bar"
            notification.soundName = nil
            NSUserNotificationCenter.default.deliver(notification)
            print("📢 Launch notification sent")
        }
    }
    
    // MARK: - Menu Bar Setup
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            // Try SF Symbol first, fallback to text emoji
            if let image = NSImage(systemSymbolName: "wand.and.stars", accessibilityDescription: "Bro") {
                button.image = image
                print("✨ Menu bar button created with SF Symbol icon")
            } else {
                // Fallback to text-based icon
                button.title = "✨"
                print("✨ Menu bar button created with emoji icon (SF Symbol not available)")
            }
            
            button.action = #selector(togglePopover)
            button.target = self
            print("✅ Menu bar button configured successfully")
        } else {
            print("❌ Failed to create menu bar button")
        }
        
        // Create popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 280, height: 400)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: MenuBarView(appState: AppState.shared)
        )
        print("✨ Popover created")
    }
    
    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }
        
        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
    
    // MARK: - Hotkey Setup
    
    func setupHotkeys() {
        // Rephrase hotkey: Option+Command+R
        let rephraseSuccess = HotkeyManager.shared.registerHotkey(
            id: 1,
            keyCode: HotkeyManager.KeyCode.r.rawValue,
            modifiers: HotkeyManager.Modifier.commandOption
        ) { [weak self] in
            print("⌨️ Rephrase hotkey triggered!")
            self?.handleRephraseHotkey()
        }
        
        if rephraseSuccess {
            print("✅ Rephrase hotkey registered: ⌥⌘R")
        } else {
            print("❌ Failed to register rephrase hotkey")
        }
        
        // Voice hotkey: Option+Command+V
        let voiceSuccess = HotkeyManager.shared.registerHotkey(
            id: 2,
            keyCode: HotkeyManager.KeyCode.v.rawValue,
            modifiers: HotkeyManager.Modifier.commandOption
        ) { [weak self] in
            print("⌨️ Voice hotkey triggered!")
            self?.handleVoiceHotkey()
        }
        
        if voiceSuccess {
            print("✅ Voice hotkey registered: ⌥⌘V")
        } else {
            print("❌ Failed to register voice hotkey")
        }
    }
    
    // MARK: - Hotkey Handlers
    
    func handleRephraseHotkey() {
        print("🔄 Rephrase hotkey handler called")
        
        // Check accessibility permission only
        let hasPermission = AXIsProcessTrusted()
        print("🔐 Has accessibility permission: \(hasPermission)")
        
        if !hasPermission {
            showAlert(title: "Permission Required", message: "Please enable Accessibility permission in System Settings → Privacy & Security → Accessibility.\n\nEnable 'Bro' and restart the app.")
            return
        }
        
        // Read focused text
        guard let text = AccessibilityManager.shared.readFocusedText(), !text.isEmpty else {
            showAlert(title: "No Text Found", message: "Please select or focus on some text to rephrase.")
            return
        }
        
        originalText = text
        rephrasedText = ""
        isStreaming = true
        
        // Show overlay
        showOverlay()
        
        // Call FastAPI backend (synchronous HTTP)
        let profile = AppState.shared.selectedProfile
        APIService.shared.rephrase(text: text, profile: profile) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let rephrased):
                self.rephrasedText = rephrased
                self.isStreaming = false
                self.updateOverlay()
            case .failure(let error):
                self.isStreaming = false
                self.updateOverlay()
                self.hideOverlay()
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func handleVoiceHotkey() {
        print("🔄 Voice hotkey handler called")
        
        // Check accessibility permission only
        let hasPermission = AXIsProcessTrusted()
        print("🔐 Has accessibility permission: \(hasPermission)")
        
        if !hasPermission {
            showAlert(title: "Permission Required", message: "Please enable Accessibility permission in System Settings → Privacy & Security → Accessibility.\n\nEnable 'Bro' and restart the app.")
            return
        }
        
        // Read selected or focused text
        guard let text = AccessibilityManager.shared.readSelectedText(), !text.isEmpty else {
            showAlert(title: "No Text Found", message: "Please select some text to generate a voice message.")
            return
        }
        
        // Show generating alert
        let alert = NSAlert()
        alert.messageText = "Generating Voice..."
        alert.informativeText = "Please wait while we generate your voice message."
        alert.alertStyle = .informational
        
        DispatchQueue.main.async {
            alert.runModal()
        }
        
        // Generate TTS
        let voiceId = AppState.shared.voices.first?.id
        
        APIService.shared.generateTTS(text: text, voiceId: voiceId) { [weak self] result in
            DispatchQueue.main.async {
                NSApp.abortModal()
            }
            
            switch result {
            case .success(let audioData):
                // Play audio
                self?.playVoiceMessage(audioData: audioData)
            case .failure(let error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func playVoiceMessage(audioData: Data) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Voice Message Ready"
            alert.informativeText = "Press and hold the voice message button in your chat app, then click Play below."
            alert.addButton(withTitle: "Play")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            
            if response == .alertFirstButtonReturn {
                // Play audio
                AudioManager.shared.playAudio(data: audioData) { success in
                    if !success {
                        self.showAlert(title: "Playback Error", message: "Failed to play audio. Make sure your output is set correctly.")
                    }
                }
            }
        }
    }
    
    // MARK: - Overlay Management
    
    func showOverlay() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Create content view with bindings
            let contentView = OverlayContentView(
                rephrasedText: Binding(
                    get: { self.rephrasedText },
                    set: { self.rephrasedText = $0 }
                ),
                isStreaming: Binding(
                    get: { self.isStreaming },
                    set: { self.isStreaming = $0 }
                ),
                onAccept: { [weak self] in
                    self?.acceptRephrase()
                },
                onEdit: { [weak self] in
                    // Edit is handled within the view
                },
                onCancel: { [weak self] in
                    self?.hideOverlay()
                }
            )
            
            let hostingView = NSHostingView(rootView: contentView)
            
            // Create or reuse overlay window
            if self.overlayWindow == nil {
                self.overlayWindow = OverlayWindow(contentView: hostingView)
            } else {
                self.overlayWindow?.contentView = hostingView
            }
            
            // Position near caret
            let caretPosition = AccessibilityManager.shared.getCaretPosition()
            self.overlayWindow?.positionNearCaret(caretPoint: caretPosition)
            
            // Show window
            self.overlayWindow?.makeKeyAndOrderFront(nil)
        }
    }
    
    func updateOverlay() {
        // Trigger view update by recreating the content
        showOverlay()
    }
    
    func hideOverlay() {
        DispatchQueue.main.async { [weak self] in
            self?.overlayWindow?.orderOut(nil)
            self?.rephrasedText = ""
            self?.isStreaming = false
        }
    }
    
    func acceptRephrase() {
        print("✅ Accept & Paste called")
        print("   Original text: \(originalText)")
        print("   Rephrased text: \(rephrasedText)")
        
        // IMPORTANT: Save the rephrased text BEFORE hiding overlay
        // because hideOverlay() clears rephrasedText!
        let textToReplace = rephrasedText
        print("   Saved text to paste: '\(textToReplace)'")
        print("   Text length: \(textToReplace.count) characters")
        
        // Copy to clipboard FIRST
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        let success = pasteboard.setString(textToReplace, forType: .string)
        
        // Verify clipboard
        let clipboardContent = pasteboard.string(forType: .string) ?? ""
        print("   ✅ Clipboard set success: \(success)")
        print("   ✅ Clipboard contains: '\(clipboardContent)'")
        
        // Hide overlay
        hideOverlay()
        
        // Wait a moment, then paste
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            print("🔄 Attempting to paste...")
            
            // Try to replace the text directly first
            let replaceSuccess = AccessibilityManager.shared.replaceFocusedText(with: textToReplace)
            
            print("   Direct replacement success: \(replaceSuccess)")
            
            if !replaceSuccess {
                print("   ⚠️ Direct replacement failed, clipboard has the text ready to paste with ⌘V")
            }
        }
    }
    
    // MARK: - Permissions
    
    func checkPermissions() {
        print("🔐 Checking accessibility permissions...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // First, try to actually use AX API to trigger macOS to recognize the app
            print("🔐 Attempting to use Accessibility API to register app...")
            _ = AccessibilityManager.shared.readFocusedText()
            
            // Small delay to let macOS register the app
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let hasPermission = AXIsProcessTrusted()
                print("🔐 Accessibility permission status: \(hasPermission)")
                
                if !hasPermission {
                    print("⚠️ Showing permission request dialog...")
                    let alert = NSAlert()
                    alert.messageText = "Accessibility Permission Required"
                    alert.informativeText = "Bro needs Accessibility access to read and modify text.\n\n1. Click 'Open System Settings' below\n2. Find 'Bro' in the list\n3. Enable the checkbox next to it\n4. Restart this app"
                    alert.addButton(withTitle: "Open System Settings")
                    alert.addButton(withTitle: "Later")
                    alert.alertStyle = .warning
                    
                    let response = alert.runModal()
                    print("🔐 User response: \(response == .alertFirstButtonReturn ? "Open Settings" : "Later")")
                    
                    if response == .alertFirstButtonReturn {
                        // Open System Settings to Accessibility pane
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                        
                        // Show a follow-up notification
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            let followUp = NSAlert()
                            followUp.messageText = "Enable Accessibility"
                            followUp.informativeText = "Look for 'Bro' in the list and enable it.\n\nThen restart the app to use it."
                            followUp.alertStyle = .informational
                            followUp.addButton(withTitle: "OK")
                            followUp.runModal()
                        }
                    }
                } else {
                    print("✅ Accessibility permission already granted")
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}

