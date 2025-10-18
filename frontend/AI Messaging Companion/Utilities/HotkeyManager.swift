//
//  HotkeyManager.swift
//  Bro
//

import Cocoa
import Carbon

class HotkeyManager {
    static let shared = HotkeyManager()
    
    private var hotkeys: [UInt32: EventHotKeyRef?] = [:]
    private var handlers: [UInt32: () -> Void] = [:]
    
    private var eventHandler: EventHandlerRef?
    
    private init() {
        setupEventHandler()
    }
    
    deinit {
        if let handler = eventHandler {
            RemoveEventHandler(handler)
        }
    }
    
    // MARK: - Setup
    
    private func setupEventHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                       eventKind: UInt32(kEventHotKeyPressed))
        
        let callback: EventHandlerUPP = { (nextHandler, theEvent, userData) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            let error = GetEventParameter(theEvent,
                                         UInt32(kEventParamDirectObject),
                                         UInt32(typeEventHotKeyID),
                                         nil,
                                         MemoryLayout<EventHotKeyID>.size,
                                         nil,
                                         &hotKeyID)
            
            if error == noErr {
                if let manager = userData?.assumingMemoryBound(to: HotkeyManager.self).pointee {
                    manager.handlers[hotKeyID.id]?()
                }
            }
            
            return noErr
        }
        
        var selfPtr = UnsafeMutablePointer<HotkeyManager>.allocate(capacity: 1)
        selfPtr.initialize(to: self)
        
        InstallEventHandler(GetApplicationEventTarget(),
                           callback,
                           1,
                           &eventType,
                           selfPtr,
                           &eventHandler)
    }
    
    // MARK: - Registration
    
    func registerHotkey(id: UInt32,
                       keyCode: UInt32,
                       modifiers: UInt32,
                       handler: @escaping () -> Void) -> Bool {
        let hotkeyID = EventHotKeyID(signature: OSType(0x4D534743), // 'MSGC'
                                     id: id)
        
        var hotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(keyCode,
                                        modifiers,
                                        hotkeyID,
                                        GetApplicationEventTarget(),
                                        0,
                                        &hotKeyRef)
        
        if status == noErr {
            hotkeys[id] = hotKeyRef
            handlers[id] = handler
            return true
        }
        
        return false
    }
    
    func unregisterHotkey(id: UInt32) {
        if let hotKeyRef = hotkeys[id] {
            if let ref = hotKeyRef {
                UnregisterEventHotKey(ref)
            }
            hotkeys.removeValue(forKey: id)
            handlers.removeValue(forKey: id)
        }
    }
    
    func unregisterAll() {
        for (_, hotKeyRef) in hotkeys {
            if let ref = hotKeyRef {
                UnregisterEventHotKey(ref)
            }
        }
        hotkeys.removeAll()
        handlers.removeAll()
    }
}

// MARK: - Key Code Constants
extension HotkeyManager {
    enum KeyCode: UInt32 {
        case r = 15
        case v = 9
        case escape = 53
        case `return` = 36
    }
    
    enum Modifier: UInt32 {
        case command = 256      // cmdKey
        case shift = 512        // shiftKey
        case option = 2048      // optionKey
        case control = 4096     // controlKey
        
        static var commandOption: UInt32 {
            return command.rawValue | option.rawValue
        }
    }
}

