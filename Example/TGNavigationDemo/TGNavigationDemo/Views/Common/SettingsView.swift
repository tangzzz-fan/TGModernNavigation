import SwiftUI
import TGModernNavigation

// MARK: - Settings View

struct SettingsView: View {
    @Environment(Router<AppRoute>.self) private var router
    let isModal: Bool
    
    init(isModal: Bool = false) {
        self.isModal = isModal
    }
    
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var selectedLanguage = "English"
    
    private let languages = ["English", "Chinese", "Japanese", "Korean"]
    
    var body: some View {
        List {
            Section("Preferences") {
                Toggle("Notifications", isOn: $notificationsEnabled)
                Toggle("Dark Mode", isOn: $darkModeEnabled)
                
                Picker("Language", selection: $selectedLanguage) {
                    ForEach(languages, id: \.self) { language in
                        Text(language).tag(language)
                    }
                }
            }
            
            Section("Account") {
                Button {
                    router.sheet(.profileSheet(userId: "current_user"))
                } label: {
                    Label("View Profile", systemImage: "person.circle")
                }
                
                Button {
                    router.sheet(.loginSheet)
                } label: {
                    Label("Switch Account", systemImage: "person.2")
                }
            }
            
            Section("Navigation Demo") {
                Button {
                    router.push(.detail(id: 100))
                } label: {
                    Label("Push Detail (in presented view)", systemImage: "arrow.right")
                }
                
                Button {
                    // Present another sheet on top
                    router.sheet(.profileSheet(userId: "stacked"))
                } label: {
                    Label("Stack Another Sheet", systemImage: "square.stack.3d.up")
                }
            }
            
            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Build", value: "2026.1")
                
                Link(destination: URL(string: "https://github.com")!) {
                    Label("GitHub Repository", systemImage: "link")
                }
            }
            
            if isModal {
                Section("Dismiss") {
                    Button(role: .destructive) {
                        router.dismiss()
                    } label: {
                        Label("Close Settings", systemImage: "xmark.circle.fill")
                    }
                    
                    Button(role: .destructive) {
                        router.dismissAll()
                    } label: {
                        Label("Close All Modals", systemImage: "xmark.circle.fill")
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayModeCompat(.inline)
        .toolbar {
            if isModal {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        router.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(Router<AppRoute>())
}
