import SwiftUI
import TGModernNavigation
import AppCore
import UIComponents

// MARK: - Presentation Demo View

public struct PresentationDemoView: View {
    @Environment(Router<AppRoute>.self) private var router
    
    public init() {}
    
    public var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Presentation Demos")
                        .font(.headline)
                    Text("Explore different modal presentation patterns.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            Section("Examples") {
                DemoRow(
                    title: "Sheet Presentation",
                    subtitle: "Standard sheet styles",
                    icon: "rectangle.bottomhalf.inset.filled",
                    color: .purple
                ) {
                    router.push(.sheetDemo)
                }
                
                DemoRow(
                    title: "Full Screen Cover",
                    subtitle: "Full screen modal",
                    icon: "rectangle.inset.filled",
                    color: .pink
                ) {
                    router.push(.fullScreenDemo)
                }
                
                DemoRow(
                    title: "Multi-Layer Modals",
                    subtitle: "Stacked presentations",
                    icon: "square.stack.3d.up.fill",
                    color: .indigo
                ) {
                    router.push(.multiLayerPresentation)
                }
            }
        }
        .navigationTitle("Presentation")
        .navigationBarTitleDisplayModeCompat(.inline)
    }
}

#Preview {
    NavigationStack {
        PresentationDemoView()
    }
    .environment(Router<AppRoute>())
}
