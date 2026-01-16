import SwiftUI
import TGModernNavigation

// MARK: - Navigation Guard View

struct NavigationGuardView: View {
    @Environment(Router<AppRoute>.self) private var router
    @State private var isLoggedIn = false
    @State private var guardEnabled = true
    @State private var lastBlockedRoute: String?
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Navigation Guard")
                        .font(.headline)
                    Text("Intercept navigation actions and redirect based on conditions (e.g., authentication).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            Section("Guard Configuration") {
                Toggle("Guard Enabled", isOn: $guardEnabled)
                
                Toggle("User Logged In", isOn: $isLoggedIn)
                    .tint(.green)
                
                if let blocked = lastBlockedRoute {
                    HStack {
                        Image(systemName: "exclamationmark.shield.fill")
                            .foregroundStyle(.orange)
                        Text("Last blocked: \(blocked)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Protected Routes") {
                Button {
                    tryNavigate(to: .profile(userId: "protected_user"))
                } label: {
                    HStack {
                        Label("Profile (Protected)", systemImage: "person.circle.fill")
                        Spacer()
                        Image(systemName: isLoggedIn ? "lock.open.fill" : "lock.fill")
                            .foregroundStyle(isLoggedIn ? .green : .red)
                    }
                }
                
                Button {
                    tryNavigate(to: .settings)
                } label: {
                    HStack {
                        Label("Settings (Protected)", systemImage: "gearshape.fill")
                        Spacer()
                        Image(systemName: isLoggedIn ? "lock.open.fill" : "lock.fill")
                            .foregroundStyle(isLoggedIn ? .green : .red)
                    }
                }
            }
            
            Section("Public Routes") {
                Button {
                    router.push(.detail(id: 1))
                } label: {
                    HStack {
                        Label("Detail (Public)", systemImage: "doc.text.fill")
                        Spacer()
                        Image(systemName: "globe")
                            .foregroundStyle(.blue)
                    }
                }
            }
            
            Section("How It Works") {
                VStack(alignment: .leading, spacing: 12) {
                    GuardExplanation(
                        step: 1,
                        title: "User triggers navigation",
                        description: "router.push(.profile(...))"
                    )
                    
                    GuardExplanation(
                        step: 2,
                        title: "Guard intercepts",
                        description: "Check if user is authenticated"
                    )
                    
                    GuardExplanation(
                        step: 3,
                        title: "Decision",
                        description: "Allow → Continue\nDeny → Redirect to login"
                    )
                }
                .padding(.vertical, 8)
            }
            
            Section("Code Example") {
                codeExample
            }
        }
        .navigationTitle("Navigation Guard")
        .navigationBarTitleDisplayModeCompat(.inline)
        .onAppear {
            setupGuard()
        }
    }
    
    private func setupGuard() {
        router.navigation.addGuard { [self] action, state in
            guard guardEnabled else { return action }
            
            // Check if navigating to protected routes
            if case .push(let route) = action {
                switch route {
                case .profile, .settings:
                    if !isLoggedIn {
                        // Store blocked route for display
                        Task { @MainActor in
                            lastBlockedRoute = route.title
                        }
                        // Redirect to login
                        return .push(.login)
                    }
                default:
                    break
                }
            }
            return action
        }
    }
    
    private func tryNavigate(to route: AppRoute) {
        if guardEnabled && !isLoggedIn {
            lastBlockedRoute = route.title
            router.push(.login)
        } else {
            router.push(route)
        }
    }
    
    private var codeExample: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Setup Guard:")
                .font(.caption.bold())
            
            Text("""
            router.navigation.addGuard { action, state in
                if case .push(let route) = action {
                    switch route {
                    case .profile, .settings:
                        if !isLoggedIn {
                            return .push(.login)
                        }
                    default: break
                    }
                }
                return action
            }
            """)
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Guard Explanation

struct GuardExplanation: View {
    let step: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(step)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(.indigo, in: Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.bold())
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NavigationGuardView()
    }
    .environment(Router<AppRoute>())
}
