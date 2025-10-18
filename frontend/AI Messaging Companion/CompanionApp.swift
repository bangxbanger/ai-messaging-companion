//
//  CompanionApp.swift
//  Bro
//

import SwiftUI

@main
struct CompanionApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared
    
    var body: some Scene {
        // No main window - menu bar only app
        Settings {
            EmptyView()
        }
    }
}

