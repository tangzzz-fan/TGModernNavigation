import SwiftUI
import TGModernNavigation
import AppCore
import UIComponents

// MARK: - Home View

public struct HomeView: View {
    @Environment(Router<AppRoute>.self) private var router
    
    public init() {}
    
    public var body: some View {
        List {
            // Header
            Section {
                headerView
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            
            // Navigation Examples
            Section("Navigation") {
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
            
            // Presentation Examples
            Section("Modal Presentation") {
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
            
            // Quick Actions
            Section("Quick Actions") {
                DemoRow(
                    title: "Show Settings Sheet",
                    subtitle: "Present settings modal",
                    icon: "gearshape.fill",
                    color: .gray
                ) {
                    router.sheet(.settingsSheet)
                }
                
                DemoRow(
                    title: "Show Profile",
                    subtitle: "Present profile full screen",
                    icon: "person.circle.fill",
                    color: .teal
                ) {
                    router.fullScreenCover(.profileSheet(userId: "demo_user"))
                }
            }
        }
        .navigationTitle("TGModernNavigation")
        .navigationBarTitleDisplayModeCompat(.large)
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.indigo, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("TGModernNavigation")
                .font(.title.bold())
            
            Text("Redux-inspired Navigation for SwiftUI")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 24) {
                StatBadge(value: "Push/Pop", label: "Navigation")
                StatBadge(value: "Sheet", label: "Present")
                StatBadge(value: "Guard", label: "Middleware")
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

#Preview {
    RouterNavigationStack(router: Router<AppRoute>()) {
        HomeView()
    }
}
