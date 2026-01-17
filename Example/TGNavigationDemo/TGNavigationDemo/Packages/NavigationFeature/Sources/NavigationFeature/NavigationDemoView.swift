import SwiftUI
import TGModernNavigation
import AppCore
import UIComponents

// MARK: - Navigation Demo View

public struct NavigationDemoView: View {
    @Environment(Router<AppRoute>.self) private var router
    
    public init() {}
    
    public var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Navigation Demos")
                        .font(.headline)
                    Text("Explore different navigation patterns and features.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            Section("Examples") {
                DemoRow(
                    title: "Basic Navigation",
                    subtitle: "Push, pop, and replace",
                    icon: "arrow.right.circle.fill",
                    color: .blue
                ) {
                    router.push(.basicNavigation)
                }
                
                DemoRow(
                    title: "Deep Navigation",
                    subtitle: "Navigate multiple levels",
                    icon: "arrow.down.right.circle.fill",
                    color: .green
                ) {
                    router.push(.deepNavigation)
                }
                
                DemoRow(
                    title: "Navigation Guard",
                    subtitle: "Intercept and redirect",
                    icon: "shield.fill",
                    color: .orange
                ) {
                    router.push(.navigationGuard)
                }
            }
        }
        .navigationTitle("Navigation")
        .navigationBarTitleDisplayModeCompat(.inline)
    }
}

#Preview {
    NavigationStack {
        NavigationDemoView()
    }
    .environment(Router<AppRoute>())
}
