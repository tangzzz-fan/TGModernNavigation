import SwiftUI
import TGModernNavigation
import AppCore

// MARK: - Detail View

public struct DetailView: View {
    @Environment(Router<AppRoute>.self) private var router
    @Environment(\.dismiss) private var dismiss
    var id: Int
    var isModal: Bool
    
    public init(id: Int, isModal: Bool = false) {
        self.id = id
        self.isModal = isModal
    }
    
    public var body: some View {
        List {
            Section {
                VStack(spacing: 20) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.indigo)
                    
                    Text("Detail #\(id)")
                        .font(.title2.bold())
                    
                    Text("This is a detail view that can be reached via push navigation or modal presentation.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            .listRowBackground(Color.clear)
            
            Section("Navigation Actions") {
                Button {
                    router.push(.detail(id: id + 1))
                } label: {
                    Label("Push Next Detail (#\(id + 1))", systemImage: "arrow.right")
                }
                
                Button {
                    router.pop()
                } label: {
                    Label("Go Back", systemImage: "arrow.left")
                }
                .disabled(!router.navigation.canPop)
                
                Button {
                    router.popToRoot()
                } label: {
                    Label("Go to Root", systemImage: "arrow.uturn.left")
                }
            }
            
            Section("Presentation Actions") {
                Button {
                    router.sheet(.settingsSheet)
                } label: {
                    Label("Show Settings Sheet", systemImage: "gearshape")
                }
                
                Button {
                    dismiss()
                } label: {
                    Label("Dismiss (if presented)", systemImage: "xmark.circle")
                }
                .disabled(!router.presentation.isPresenting)
            }
            
            Section("Item Info") {
                LabeledContent("ID", value: "\(id)")
                LabeledContent("Created", value: Date.now.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("Type", value: "Document")
            }
        }
        .navigationTitle("Detail #\(id)")
        .navigationBarTitleDisplayModeCompat(.inline)
        .toolbar {
            if isModal {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DetailView(id: 1)
    }
    .environment(Router<AppRoute>())
}
