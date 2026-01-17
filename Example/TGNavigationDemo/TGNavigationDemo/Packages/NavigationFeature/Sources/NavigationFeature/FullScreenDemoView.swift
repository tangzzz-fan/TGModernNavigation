import SwiftUI
import TGModernNavigation
import AppCore
import UIComponents

// MARK: - Full Screen Demo View

public struct FullScreenDemoView: View {
    @Environment(Router<AppRoute>.self) private var router
    
    public init() {}
    
    public var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Screen Cover")
                        .font(.headline)
                    Text("Present views in full screen mode, covering the entire screen.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
            Section("Full Screen Presentations") {
                Button {
                    router.fullScreenCover(.profileSheet(userId: "fullscreen_user"))
                } label: {
                    HStack {
                        Label("Profile Full Screen", systemImage: "person.circle.fill")
                        Spacer()
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Button {
                    router.fullScreenCover(.settingsSheet)
                } label: {
                    HStack {
                        Label("Settings Full Screen", systemImage: "gearshape.fill")
                        Spacer()
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Button {
                    router.fullScreenCover(.loginSheet)
                } label: {
                    HStack {
                        Label("Login Full Screen", systemImage: "person.badge.key.fill")
                        Spacer()
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Use Cases") {
                UseCaseRow(
                    title: "Onboarding",
                    description: "Show full screen onboarding flow",
                    icon: "hand.wave.fill"
                )
                
                UseCaseRow(
                    title: "Login/Auth",
                    description: "Authentication screens",
                    icon: "lock.fill"
                )
                
                UseCaseRow(
                    title: "Media Viewer",
                    description: "Full screen photo/video viewer",
                    icon: "photo.fill"
                )
                
                UseCaseRow(
                    title: "Immersive Content",
                    description: "Games, AR experiences",
                    icon: "gamecontroller.fill"
                )
            }
            #else
            Section {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("Full Screen Cover is not available on macOS")
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Alternative on macOS") {
                Button {
                    router.sheet(.profileSheet(userId: "mac_user"))
                } label: {
                    Label("Use Sheet Instead", systemImage: "rectangle.bottomhalf.inset.filled")
                }
            }
            #endif
            
            Section("Code Example") {
                codeExample
            }
        }
        .navigationTitle("Full Screen Cover")
        .navigationBarTitleDisplayModeCompat(.inline)
    }
    
    private var codeExample: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Usage:")
                .font(.caption.bold())
            
            Text("""
            // Present full screen
            router.fullScreenCover(.profileSheet(userId: "123"))
            
            // Or using presentation store
            router.presentation.present(
                .profileSheet(userId: "123"),
                style: .fullScreenCover
            )
            
            // Dismiss from presented view
            router.dismiss()
            """)
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Use Case Row

struct UseCaseRow: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.indigo)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        FullScreenDemoView()
    }
    .environment(Router<AppRoute>())
}
