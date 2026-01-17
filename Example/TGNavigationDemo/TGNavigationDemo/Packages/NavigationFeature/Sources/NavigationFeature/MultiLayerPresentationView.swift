import SwiftUI
import TGModernNavigation
import AppCore

// MARK: - Multi Layer Presentation View

struct MultiLayerPresentationView: View {
    @Environment(Router<AppRoute>.self) private var router
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Multi-Layer Presentation")
                        .font(.headline)
                    Text("Present sheets on top of other sheets, creating a stack of modals.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            Section("Stacked Modals") {
                Button {
                    router.sheet(.settingsSheet)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Start Modal Stack", systemImage: "square.stack.3d.up.fill")
                        Text("Opens Settings → Profile → Detail")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Current Presentation State") {
                LabeledContent("Is Presenting", value: router.presentation.isPresenting ? "Yes" : "No")
                LabeledContent("Stack Depth", value: "\(router.presentation.count)")
                
                if let current = router.presentation.currentRoute {
                    LabeledContent("Current Modal", value: current.title)
                }
            }
            
            Section("Stack Operations") {
                Button {
                    router.dismiss()
                } label: {
                    Label("Dismiss Top", systemImage: "xmark.circle")
                }
                .disabled(!router.presentation.isPresenting)
                
                Button(role: .destructive) {
                    router.dismissAll()
                } label: {
                    Label("Dismiss All", systemImage: "xmark.circle.fill")
                }
                .disabled(!router.presentation.isPresenting)
            }
            
            Section("How It Works") {
                VStack(alignment: .leading, spacing: 12) {
                    StackDiagram()
                }
                .padding(.vertical, 8)
            }
            
            Section("Code Example") {
                codeExample
            }
        }
        .navigationTitle("Multi-Layer")
        .navigationBarTitleDisplayModeCompat(.inline)
    }
    
    private var codeExample: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Usage:")
                .font(.caption.bold())
            
            Text("""
            // Present first sheet
            router.sheet(.settings)
            
            // In SettingsView, present another
            router.sheet(.profile(userId: "123"))
            
            // In ProfileView, present yet another
            router.sheet(.detail(id: 1))
            
            // Dismiss operations
            router.dismiss()     // Dismiss top only
            router.dismissAll()  // Dismiss entire stack
            """)
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Stack Diagram

private struct StackDiagram: View {
    var body: some View {
        VStack(spacing: 8) {
            StackLayer(name: "Detail Sheet", level: 3, color: .purple)
            StackLayer(name: "Profile Sheet", level: 2, color: .indigo)
            StackLayer(name: "Settings Sheet", level: 1, color: .blue)
            StackLayer(name: "Main View", level: 0, color: .gray, isBase: true)
        }
    }
}

struct StackLayer: View {
    let name: String
    let level: Int
    let color: Color
    var isBase: Bool = false
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(color, lineWidth: 1)
                )
                .frame(height: 36)
                .overlay(
                    HStack {
                        Text(name)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(color)
                        
                        Spacer()
                        
                        if !isBase {
                            Text("Level \(level)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 12)
                )
                .offset(x: CGFloat(level) * 8)
        }
    }
}


#Preview {
    NavigationStack {
        MultiLayerPresentationView()
    }
    .environment(Router<AppRoute>())
}
