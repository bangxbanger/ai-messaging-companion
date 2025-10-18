//
//  SettingsView.swift
//  Bro
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appState: AppState
    
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Tabs
            Picker("", selection: $selectedTab) {
                Text("General").tag(0)
                Text("Profiles").tag(1)
                Text("Permissions").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            Divider()
            
            // Content
            TabView(selection: $selectedTab) {
                GeneralSettingsView(appState: appState)
                    .tag(0)
                
                ProfilesView(appState: appState)
                    .tag(1)
                
                PermissionsView()
                    .tag(2)
            }
            .tabViewStyle(.automatic)
            
            Divider()
            
            // Footer
            HStack {
                Spacer()
                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
            .padding()
        }
        .frame(width: 600, height: 500)
    }
}

// MARK: - General Settings

struct GeneralSettingsView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        Form {
            Section {
                Toggle("Launch at login", isOn: .constant(false))
                Toggle("Show menu bar icon", isOn: .constant(true))
            } header: {
                Text("General")
            }
            
            Section {
                HStack {
                    Text("Rephrase Hotkey:")
                    Spacer()
                    Text("⌥⌘R")
                        .font(.system(.body, design: .monospaced))
                        .padding(4)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(4)
                }
                
                HStack {
                    Text("Voice Message Hotkey:")
                    Spacer()
                    Text("⌥⌘V")
                        .font(.system(.body, design: .monospaced))
                        .padding(4)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(4)
                }
            } header: {
                Text("Hotkeys")
            }
            
            Section {
                if let device = AudioManager.shared.getCurrentOutputDevice() {
                    HStack {
                        Text("Current Output:")
                        Spacer()
                        Text(device.name)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("For voice messages, set your output to BlackHole or a Multi-Output device that includes BlackHole.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("Open Audio MIDI Setup") {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.sound")!)
                }
            } header: {
                Text("Audio Settings")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Profiles

struct ProfilesView: View {
    @ObservedObject var appState: AppState
    
    private let profileDescriptions: [ToneProfile: String] = [
        .nice_guy: "Kind, thoughtful, polite, calm, and understanding. Empathetic with soft edges.",
        .meme_god: "Pure vibes, funny, dramatic. Lowercase chaos with meme energy.",
        .no_filter: "Direct, confident, efficient. No fluff, no emojis, straight to the point."
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select a tone profile for rephrasing")
                .font(.headline)
                .padding(.top)
                .padding(.horizontal)
            
            List {
                ForEach(ToneProfile.allCases, id: \.self) { profile in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(profile.displayName)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            if profile == appState.selectedProfile {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Text(profileDescriptions[profile] ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        appState.selectedProfile = profile
                    }
                }
            }
            
            HStack {
                Text("\(ToneProfile.allCases.count) profiles available")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Refresh") {
                    appState.loadProfiles()
                }
            }
            .padding()
        }
    }
}

// MARK: - Permissions

struct PermissionsView: View {
    @State private var accessibilityEnabled = AccessibilityManager.shared.checkAccessibilityPermission()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Required Permissions")
                .font(.headline)
                .padding(.top)
            
            // Accessibility
            HStack(spacing: 12) {
                Image(systemName: accessibilityEnabled ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(accessibilityEnabled ? .green : .orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Accessibility")
                        .fontWeight(.semibold)
                    
                    Text("Required to read and modify text in chat applications")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !accessibilityEnabled {
                    Button("Enable") {
                        AccessibilityManager.shared.requestAccessibilityPermission()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            accessibilityEnabled = AccessibilityManager.shared.checkAccessibilityPermission()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)
            
            Divider()
            
            Text("How to enable permissions:")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Open System Settings → Privacy & Security", systemImage: "1.circle.fill")
                Label("Click Accessibility", systemImage: "2.circle.fill")
                Label("Enable Bro", systemImage: "3.circle.fill")
            }
            .font(.caption)
            
            Spacer()
        }
        .padding()
    }
}

