import SwiftUI
import TGModernNavigation

// MARK: - Basic Navigation View

struct BasicNavigationView: View {
    @Environment(Router<AppRoute>.self) private var router
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Basic Navigation")
                        .font(.headline)
                    Text("Demonstrates push, pop, and replace operations using NavigationStore.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            Section("Push Operations") {
                Button {
                    router.push(.detail(id: 1))
                } label: {
                    Label("Push Detail #1", systemImage: "arrow.right")
                }
                
                Button {
                    router.push(.detail(id: 2))
                } label: {
                    Label("Push Detail #2", systemImage: "arrow.right")
                }
                
                Button {
                    router.push(.settings)
                } label: {
                    Label("Push Settings", systemImage: "gearshape")
                }
            }
            
            Section("Pop Operations") {
                Button {
                    router.pop()
                } label: {
                    Label("Pop (Go Back)", systemImage: "arrow.left")
                }
                .disabled(!router.navigation.canPop)
                
                Button {
                    router.popToRoot()
                } label: {
                    Label("Pop to Root", systemImage: "arrow.uturn.left")
                }
                .disabled(!router.navigation.canPop)
            }
            
            Section("Replace Operations") {
                Button {
                    router.navigation.replace([.settings, .detail(id: 99)])
                } label: {
                    Label("Replace Path", systemImage: "arrow.triangle.2.circlepath")
                }
            }
            
            Section("Current State") {
                LabeledContent("Path Count", value: "\(router.navigation.count)")
                LabeledContent("Can Pop", value: router.navigation.canPop ? "Yes" : "No")
                if let current = router.navigation.currentRoute {
                    LabeledContent("Current Route", value: current.title)
                }
            }
            
            Section("Code Example") {
                codeExample
            }
        }
        .navigationTitle("Basic Navigation")
        .navigationBarTitleDisplayModeCompat(.inline)
    }
    
    private var codeExample: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Usage:")
                .font(.caption.bold())
            
            Text("""
            // Push
            router.push(.detail(id: 1))
            
            // Pop
            router.pop()
            router.popToRoot()
            
            // Replace entire path
            router.navigation.replace([.home, .settings])
            """)
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        BasicNavigationView()
    }
    .environment(Router<AppRoute>())
}
