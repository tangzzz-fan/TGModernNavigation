import SwiftUI
import TGModernNavigation

// MARK: - Sheet Demo View

struct SheetDemoView: View {
    @Environment(Router<AppRoute>.self) private var router
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sheet Presentation")
                        .font(.headline)
                    Text("Present views as sheets with different configurations.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            Section("Sheet Sizes") {
                Button {
                    router.presentation.present(
                        .settingsSheet,
                        style: .sheet,
                        configuration: .large
                    )
                } label: {
                    HStack {
                        Label("Large Sheet", systemImage: "rectangle.inset.filled")
                        Spacer()
                        Text("Default")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Button {
                    router.presentation.present(
                        .settingsSheet,
                        style: .sheet,
                        configuration: .medium
                    )
                } label: {
                    Label("Medium Sheet", systemImage: "rectangle.bottomhalf.inset.filled")
                }
                
                Button {
                    router.presentation.present(
                        .settingsSheet,
                        style: .sheet,
                        configuration: .flexible
                    )
                } label: {
                    HStack {
                        Label("Flexible Sheet", systemImage: "arrow.up.and.down")
                        Spacer()
                        Text("Resizable")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Sheet Options") {
                Button {
                    router.presentation.present(
                        .settingsSheet,
                        style: .sheet,
                        configuration: SheetConfiguration(
                            detents: [.medium, .large],
                            dragIndicatorVisibility: .visible,
                            interactiveDismissDisabled: false
                        )
                    )
                } label: {
                    Label("With Drag Indicator", systemImage: "minus")
                }
                
                Button {
                    router.presentation.present(
                        .settingsSheet,
                        style: .sheet,
                        configuration: SheetConfiguration(
                            detents: [.large],
                            dragIndicatorVisibility: .hidden,
                            interactiveDismissDisabled: true
                        )
                    )
                } label: {
                    HStack {
                        Label("Non-Dismissible", systemImage: "lock.fill")
                        Spacer()
                        Text("Must close via button")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            
            Section("Present Different Routes") {
                Button {
                    router.sheet(.profileSheet(userId: "sheet_user"))
                } label: {
                    Label("Profile Sheet", systemImage: "person.circle")
                }
                
                Button {
                    router.sheet(.detail(id: 42))
                } label: {
                    Label("Detail Sheet", systemImage: "doc.text")
                }
            }
            
            Section("Code Example") {
                codeExample
            }
        }
        .navigationTitle("Sheet Demo")
        .navigationBarTitleDisplayModeCompat(.inline)
    }
    
    private var codeExample: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Usage:")
                .font(.caption.bold())
            
            Text("""
            // Default sheet
            router.sheet(.settingsSheet)
            
            // With configuration
            router.presentation.present(
                .settingsSheet,
                style: .sheet,
                configuration: SheetConfiguration(
                    detents: [.medium, .large],
                    dragIndicatorVisibility: .visible,
                    interactiveDismissDisabled: false
                )
            )
            
            // Presets
            configuration: .medium   // Half screen
            configuration: .large    // Full height
            configuration: .flexible // Resizable
            """)
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        SheetDemoView()
    }
    .environment(Router<AppRoute>())
}
