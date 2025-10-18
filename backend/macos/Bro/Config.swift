//
//  Config.swift
//  Bro
//

import Foundation

struct Config {
    // FastAPI Backend
    static let backendURL = "http://127.0.0.1:8080"
    
    // Hotkey defaults
    static let rephraseHotkey = (keyCode: UInt32(15), modifiers: UInt32(768)) // Opt+Cmd+R
    static let voiceHotkey = (keyCode: UInt32(9), modifiers: UInt32(768))     // Opt+Cmd+V
    
    // UI settings
    static let overlayCornerRadius: CGFloat = 12
    static let overlayPadding: CGFloat = 16
    static let overlayMaxWidth: CGFloat = 400
    
    // Timeouts
    static let requestTimeout: TimeInterval = 30
    static let streamTimeout: TimeInterval = 60
}

