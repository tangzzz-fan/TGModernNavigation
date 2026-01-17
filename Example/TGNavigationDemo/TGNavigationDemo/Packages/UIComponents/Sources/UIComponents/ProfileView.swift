import SwiftUI
import TGModernNavigation
import AppCore

// MARK: - Profile View

public struct ProfileView: View {
    @Environment(Router<AppRoute>.self) private var router
    @Environment(\.dismiss) private var dismiss
    let userId: String
    let isModal: Bool
    
    public init(userId: String, isModal: Bool = false) {
        self.userId = userId
        self.isModal = isModal
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Avatar
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.indigo, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text(String(userId.prefix(1)).uppercased())
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                    )
                
                // Name
                VStack(spacing: 4) {
                    Text("User: \(userId)")
                        .font(.title2.bold())
                    
                    Text("@\(userId)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Stats
                HStack(spacing: 40) {
                    ProfileStat(value: "128", label: "Posts")
                    ProfileStat(value: "1.2K", label: "Followers")
                    ProfileStat(value: "256", label: "Following")
                }
                .padding(.vertical)
                
                // Actions
                VStack(spacing: 12) {
                    Button {
                        router.push(.settings)
                    } label: {
                        Label("Edit Profile", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        router.sheet(.detailSheet(id: Int.random(in: 1...100)))
                    } label: {
                        Label("View Recent Activity", systemImage: "clock")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                
                // Info Section
                GroupBox("About") {
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(icon: "mappin.circle.fill", label: "Location", value: "San Francisco, CA")
                        InfoRow(icon: "calendar", label: "Joined", value: "January 2024")
                        InfoRow(icon: "link", label: "Website", value: "example.com")
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayModeCompat(.inline)
        .toolbar {
            if isModal {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            router.sheet(.settingsSheet)
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                        
                        Button(role: .destructive) {
                        router.dismissAll()
                    } label: {
                        Label("Close All", systemImage: "xmark.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

// MARK: - Profile Stat

struct ProfileStat: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.indigo)
                .frame(width: 24)
            
            Text(label)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
        }
        .font(.subheadline)
    }
}

#Preview {
    NavigationStack {
        ProfileView(userId: "demo_user")
    }
    .environment(Router<AppRoute>())
}
