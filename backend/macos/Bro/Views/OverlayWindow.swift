//
//  OverlayWindow.swift
//  Bro
//

import Cocoa
import SwiftUI

class OverlayWindow: NSPanel {
    
    init(contentView: NSView) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.isFloatingPanel = true
        self.level = .statusBar
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        self.isMovableByWindowBackground = false
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = true
        self.contentView = contentView
        self.ignoresMouseEvents = false
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return false
    }
    
    func positionNearCaret(caretPoint: CGPoint?) {
        guard let screen = NSScreen.main else { return }
        
        let windowSize = self.frame.size
        var origin: CGPoint
        
        if let caret = caretPoint {
            // Position below the caret
            origin = CGPoint(
                x: caret.x - windowSize.width / 2,
                y: caret.y - windowSize.height - 10
            )
        } else {
            // Center on screen
            origin = CGPoint(
                x: (screen.frame.width - windowSize.width) / 2,
                y: (screen.frame.height - windowSize.height) / 2
            )
        }
        
        // Ensure window stays on screen
        origin.x = max(10, min(origin.x, screen.frame.width - windowSize.width - 10))
        origin.y = max(10, min(origin.y, screen.frame.height - windowSize.height - 10))
        
        self.setFrameOrigin(origin)
    }
}

// MARK: - Overlay Content View

struct OverlayContentView: View {
    @Binding var rephrasedText: String
    @Binding var isStreaming: Bool
    
    let onAccept: () -> Void
    let onEdit: () -> Void
    let onCancel: () -> Void
    
    @State private var isEditing = false
    @State private var editedText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "wand.and.stars")
                    .foregroundColor(.blue)
                Text("AI Rephrased")
                    .font(.headline)
                
                Spacer()
                
                if isStreaming {
                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(width: 16, height: 16)
                }
                
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            Divider()
            
            // Content
            if isEditing {
                TextEditor(text: $editedText)
                    .font(.body)
                    .frame(minHeight: 80, maxHeight: 200)
                    .padding(4)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(6)
            } else {
                ScrollView {
                    Text(rephrasedText.isEmpty ? "Generating..." : rephrasedText)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(minHeight: 80, maxHeight: 200)
            }
            
            // Actions
            HStack {
                if isEditing {
                    Button("Cancel Edit") {
                        isEditing = false
                        editedText = rephrasedText
                    }
                    .keyboardShortcut(.escape, modifiers: [])
                    
                    Spacer()
                    
                    Button("Save & Copy") {
                        rephrasedText = editedText
                        isEditing = false
                        onAccept()
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                    .buttonStyle(.borderedProminent)
                } else {
                    Button(action: {
                        editedText = rephrasedText
                        isEditing = true
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    .disabled(isStreaming || rephrasedText.isEmpty)
                    
                    Spacer()
                    
                    Button(action: onAccept) {
                        Label("Accept & Paste", systemImage: "checkmark.circle.fill")
                    }
                    .keyboardShortcut(.return, modifiers: [])
                    .buttonStyle(.borderedProminent)
                    .disabled(isStreaming || rephrasedText.isEmpty)
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .frame(width: Config.overlayMaxWidth)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
        )
        .cornerRadius(Config.overlayCornerRadius)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Visual Effect View (Blur)

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

