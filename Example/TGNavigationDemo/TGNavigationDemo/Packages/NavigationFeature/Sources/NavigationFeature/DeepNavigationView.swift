import SwiftUI
import TGModernNavigation
import AppCore
import UIComponents

// MARK: - Deep Navigation View

public struct DeepNavigationView: View {
    @Environment(Router<AppRoute>.self) private var router
    @State private var selectedDepth = 3
    
    public init() {}
    
    public var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Deep Navigation")
                        .font(.headline)
                    Text("Navigate multiple levels at once, useful for deep linking scenarios.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            Section("Navigate Multiple Levels") {
                Stepper("Depth: \(selectedDepth)", value: $selectedDepth, in: 1...10)
                
                Button {
                    navigateDeep(depth: selectedDepth)
                } label: {
                    Label("Navigate \(selectedDepth) levels deep", systemImage: "arrow.down.right")
                }
            }
            
            Section("Preset Deep Links") {
                Button {
                    // Simulate deep link: Home -> Settings -> Profile
                    router.navigation.replace([
                        .settings,
                        .profile(userId: "user_123")
                    ])
                } label: {
                    Label("Settings → Profile", systemImage: "link")
                }
                
                Button {
                    // Simulate deep link: Home -> Detail chain
                    router.navigation.replace([
                        .detail(id: 1),
                        .detail(id: 2),
                        .detail(id: 3)
                    ])
                } label: {
                    Label("Detail #1 → #2 → #3", systemImage: "link")
                }
            }
            
            Section("Current Navigation Stack") {
                if router.navigation.isEmpty {
                    Text("Stack is empty (at root)")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(router.navigation.path.enumerated()), id: \.offset) { index, route in
                        HStack {
                            Text("\(index + 1).")
                                .foregroundStyle(.secondary)
                                .frame(width: 24)
                            
                            Image(systemName: route.icon)
                                .foregroundStyle(.indigo)
                            
                            Text(route.title)
                            
                            Spacer()
                            
                            if index == router.navigation.path.count - 1 {
                                Text("Current")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(.indigo, in: Capsule())
                            }
                        }
                    }
                }
            }
            
            Section("Stack Operations") {
                Button {
                    router.navigation.pop(count: 2)
                } label: {
                    Label("Pop 2 levels", systemImage: "arrow.left.to.line")
                }
                .disabled(router.navigation.count < 2)
                
                Button(role: .destructive) {
                    router.popToRoot()
                } label: {
                    Label("Clear Stack", systemImage: "trash")
                }
                .disabled(!router.navigation.canPop)
            }
        }
        .navigationTitle("Deep Navigation")
        .navigationBarTitleDisplayModeCompat(.inline)
    }
    
    private func navigateDeep(depth: Int) {
        let routes = (1...depth).map { AppRoute.detail(id: $0) }
        router.navigation.replace(routes)
    }
}

#Preview {
    NavigationStack {
        DeepNavigationView()
    }
    .environment(Router<AppRoute>())
}
