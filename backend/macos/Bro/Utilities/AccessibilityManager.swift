//
//  AccessibilityManager.swift
//  Bro
//

import Cocoa
import ApplicationServices

class AccessibilityManager {
    static let shared = AccessibilityManager()
    
    private init() {}
    
    // MARK: - Permission Checking
    
    func checkAccessibilityPermission() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let isTrusted = AXIsProcessTrustedWithOptions(options)
        print("🔍 AccessibilityManager: checkAccessibilityPermission() returned \(isTrusted)")
        return isTrusted
    }
    
    func requestAccessibilityPermission() {
        print("🔍 AccessibilityManager: Requesting accessibility permission...")
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let result = AXIsProcessTrustedWithOptions(options)
        print("🔍 AccessibilityManager: requestAccessibilityPermission() result: \(result)")
    }
    
    // MARK: - Text Reading
    
    func readFocusedText() -> String? {
        guard let systemWide = AXUIElementCreateSystemWide() as AXUIElement? else {
            return nil
        }
        
        var focusedElement: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            systemWide,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )
        
        guard result == .success, let element = focusedElement as! AXUIElement? else {
            return fallbackReadViaClipboard()
        }
        
        // Try to get the value
        var value: CFTypeRef?
        let valueResult = AXUIElementCopyAttributeValue(
            element,
            kAXValueAttribute as CFString,
            &value
        )
        
        if valueResult == .success, let text = value as? String {
            return text
        }
        
        // Try to get selected text
        var selectedText: CFTypeRef?
        let selectedResult = AXUIElementCopyAttributeValue(
            element,
            kAXSelectedTextAttribute as CFString,
            &selectedText
        )
        
        if selectedResult == .success, let text = selectedText as? String {
            return text
        }
        
        // Fallback to clipboard method
        return fallbackReadViaClipboard()
    }
    
    func readSelectedText() -> String? {
        guard let systemWide = AXUIElementCreateSystemWide() as AXUIElement? else {
            return nil
        }
        
        var focusedElement: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            systemWide,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )
        
        guard result == .success, let element = focusedElement as! AXUIElement? else {
            return fallbackReadViaClipboard()
        }
        
        var selectedText: CFTypeRef?
        let selectedResult = AXUIElementCopyAttributeValue(
            element,
            kAXSelectedTextAttribute as CFString,
            &selectedText
        )
        
        if selectedResult == .success, let text = selectedText as? String, !text.isEmpty {
            return text
        }
        
        // If no selection, read whole field
        return readFocusedText()
    }
    
    // MARK: - Text Writing
    
    func replaceFocusedText(with newText: String) -> Bool {
        print("📝 replaceFocusedText called with: '\(newText)'")
        print("   Length: \(newText.count) characters")
        
        guard let systemWide = AXUIElementCreateSystemWide() as AXUIElement? else {
            print("   ❌ Failed to create system-wide AX element")
            return false
        }
        
        var focusedElement: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            systemWide,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )
        
        guard result == .success, let element = focusedElement as! AXUIElement? else {
            print("   ⚠️ No focused element, using clipboard fallback")
            return fallbackWriteViaClipboard(text: newText)
        }
        
        print("   ✅ Found focused element")
        
        // First, check if there's selected text
        var selectedText: CFTypeRef?
        let selectedResult = AXUIElementCopyAttributeValue(
            element,
            kAXSelectedTextAttribute as CFString,
            &selectedText
        )
        
        // If there's selected text, we need to replace it
        if selectedResult == .success, let text = selectedText as? String, !text.isEmpty {
            print("   📋 Found selected text: '\(text)' (length: \(text.count))")
            
            // Get the selected range
            var selectedRange: CFTypeRef?
            let rangeResult = AXUIElementCopyAttributeValue(
                element,
                kAXSelectedTextRangeAttribute as CFString,
                &selectedRange
            )
            
            if rangeResult == .success, let range = selectedRange {
                print("   🎯 Attempting to replace selected text...")
                // Try to replace the selected text by setting the value for that range
                let setSelectedText = AXUIElementSetAttributeValue(
                    element,
                    kAXSelectedTextAttribute as CFString,
                    newText as CFTypeRef
                )
                
                if setSelectedText == .success {
                    print("   ✅ Successfully replaced selected text!")
                    return true
                } else {
                    print("   ❌ Failed to replace selected text (error code: \(setSelectedText.rawValue))")
                }
            } else {
                print("   ❌ Failed to get selected range (error code: \(rangeResult.rawValue))")
            }
        } else {
            print("   ℹ️ No selected text found")
        }
        
        // If no selection or direct replacement failed, try to set the entire value
        print("   🎯 Attempting to set entire field value...")
        let setValue = AXUIElementSetAttributeValue(
            element,
            kAXValueAttribute as CFString,
            newText as CFTypeRef
        )
        
        if setValue == .success {
            print("   ✅ Successfully set field value!")
            return true
        } else {
            print("   ❌ Failed to set field value (error code: \(setValue.rawValue))")
        }
        
        // Final fallback to clipboard + paste method
        print("   ⚠️ Using clipboard paste fallback...")
        return fallbackWriteViaClipboard(text: newText)
    }
    
    func insertText(_ text: String) -> Bool {
        return replaceFocusedText(with: text)
    }
    
    // MARK: - Caret Position
    
    func getCaretPosition() -> CGPoint? {
        guard let systemWide = AXUIElementCreateSystemWide() as AXUIElement? else {
            return nil
        }
        
        var focusedElement: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            systemWide,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )
        
        guard result == .success, let element = focusedElement as! AXUIElement? else {
            return nil
        }
        
        // Get selected text range
        var selectedRange: CFTypeRef?
        let rangeResult = AXUIElementCopyAttributeValue(
            element,
            kAXSelectedTextRangeAttribute as CFString,
            &selectedRange
        )
        
        guard rangeResult == .success, let range = selectedRange else {
            return getElementPosition(element)
        }
        
        // Get bounds for the range
        var bounds: CFTypeRef?
        let boundsResult = AXUIElementCopyParameterizedAttributeValue(
            element,
            kAXBoundsForRangeParameterizedAttribute as CFString,
            range,
            &bounds
        )
        
        if boundsResult == .success, let value = bounds {
            var rect = CGRect.zero
            if AXValueGetValue(value as! AXValue, .cgRect, &rect) {
                return CGPoint(x: rect.midX, y: rect.minY)
            }
        }
        
        // Fallback to element position
        return getElementPosition(element)
    }
    
    private func getElementPosition(_ element: AXUIElement) -> CGPoint? {
        var position: CFTypeRef?
        let posResult = AXUIElementCopyAttributeValue(
            element,
            kAXPositionAttribute as CFString,
            &position
        )
        
        if posResult == .success, let value = position {
            var point = CGPoint.zero
            if AXValueGetValue(value as! AXValue, .cgPoint, &point) {
                return point
            }
        }
        
        return nil
    }
    
    // MARK: - Fallback Methods (Clipboard)
    
    private func fallbackReadViaClipboard() -> String? {
        // Save current clipboard
        let pasteboard = NSPasteboard.general
        let savedContents = pasteboard.string(forType: .string)
        
        // Clear clipboard
        pasteboard.clearContents()
        
        // Simulate Cmd+C
        let source = CGEventSource(stateID: .hidSystemState)
        
        // Key down
        let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true) // C key
        keyDownEvent?.flags = .maskCommand
        keyDownEvent?.post(tap: .cghidEventTap)
        
        // Key up
        let keyUpEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
        keyUpEvent?.flags = .maskCommand
        keyUpEvent?.post(tap: .cghidEventTap)
        
        // Wait a bit for clipboard to update
        usleep(100000) // 100ms
        
        // Read clipboard
        let copiedText = pasteboard.string(forType: .string)
        
        // Restore clipboard
        if let saved = savedContents {
            pasteboard.clearContents()
            pasteboard.setString(saved, forType: .string)
        }
        
        return copiedText
    }
    
    private func fallbackWriteViaClipboard(text: String) -> Bool {
        print("   🔄 fallbackWriteViaClipboard called")
        print("      Text to paste: '\(text)'")
        print("      Text length: \(text.count)")
        
        // Save current clipboard
        let pasteboard = NSPasteboard.general
        let savedContents = pasteboard.string(forType: .string)
        print("      Saved clipboard: '\(savedContents ?? "nil")'")
        
        // Set new text to clipboard
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        // Verify it was set
        let verifyClipboard = pasteboard.string(forType: .string)
        print("      Clipboard now has: '\(verifyClipboard ?? "nil")'")
        
        // Simulate Cmd+V
        let source = CGEventSource(stateID: .hidSystemState)
        
        print("      🎹 Simulating Cmd+V...")
        
        // Key down
        let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true) // V key
        keyDownEvent?.flags = .maskCommand
        keyDownEvent?.post(tap: .cghidEventTap)
        
        // Key up
        let keyUpEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyUpEvent?.flags = .maskCommand
        keyUpEvent?.post(tap: .cghidEventTap)
        
        print("      ✅ Cmd+V simulated")
        
        // Wait a bit
        usleep(100000) // 100ms
        
        // Restore clipboard after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("      🔄 Restoring original clipboard...")
            if let saved = savedContents {
                pasteboard.clearContents()
                pasteboard.setString(saved, forType: .string)
                print("      ✅ Clipboard restored")
            }
        }
        
        return true
    }
    
    // MARK: - App Detection
    
    func getFrontmostApplication() -> (name: String, bundleId: String?)? {
        guard let app = NSWorkspace.shared.frontmostApplication else {
            return nil
        }
        
        return (app.localizedName ?? "Unknown", app.bundleIdentifier)
    }
    
    func isMessagingApp() -> Bool {
        guard let (_, bundleId) = getFrontmostApplication() else {
            return false
        }
        
        let messagingApps = [
            "com.tdesktop.Telegram",
            "telegram.desktop",
            "net.whatsapp.WhatsApp",
            "com.apple.iChat",
            "com.apple.MobileSMS",
            "com.tinyspeck.slackmacgap",
            "com.microsoft.teams",
            "us.zoom.xos",
            "com.discord.Discord"
        ]
        
        return messagingApps.contains(bundleId ?? "")
    }
}

