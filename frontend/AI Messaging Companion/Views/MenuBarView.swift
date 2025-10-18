//
//  MenuBarView.swift
//  Bro
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "wand.and.stars.inverse")
                        .font(.title2)
                    Text("Bro")
                        .font(.headline)
                    Spacer()
                }
                .padding()
                
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Ready")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                Divider()
            }
            
            // Quick actions
            VStack(alignment: .leading, spacing: 4) {
                // Profile menu
                Menu {
                    ForEach(ToneProfile.allCases, id: \.self) { p in
                        Button(action: { appState.selectedProfile = p }) {
                            HStack {
                                Text(p.displayName)
                                if appState.selectedProfile == p {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "text.badge.checkmark")
                        Text("Tone: \(appState.selectedProfile.displayName)")
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption)
                    }
                }
                .menuStyle(.borderlessButton)
                .padding(.horizontal)
                .padding(.vertical, 6)
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "keyboard")
                        Text("Rephrase Text")
                        Spacer()
                        Text("⇧Space")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
                .onHover { isHovered in
                    if isHovered {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "waveform")
                        Text("Voice Message")
                        Spacer()
                        Text("⌥⌘V")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
                .onHover { isHovered in
                    if isHovered {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Tone preset selector (disabled for now - no backend)
                // Will be enabled when backend is connected
            }
            
            // Settings and quit
            VStack(alignment: .leading, spacing: 4) {
                Button(action: {
                    appState.showSettings = true
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings")
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.vertical, 6)
                
                Divider()
                    .padding(.vertical, 4)
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    HStack {
                        Image(systemName: "power")
                        Text("Quit")
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.vertical, 6)
            }
            .padding(.bottom, 8)
        }
        .frame(width: 280)
    }
}

