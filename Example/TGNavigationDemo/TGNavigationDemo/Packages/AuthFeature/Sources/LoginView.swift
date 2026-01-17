import SwiftUI
import TGModernNavigation
import AppCore

// MARK: - Login View

public struct LoginView: View {
    @Environment(Router<AppRoute>.self) private var router
    @Environment(\.dismiss) private var dismiss
    
    let isModal: Bool
    
    public init(isModal: Bool = false) {
        self.isModal = isModal
    }
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let authService = AuthService.shared
    
    public var body: some View {
        VStack(spacing: 32) {
            if isModal {
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    Spacer()
                }
                .padding()
            } else {
                Spacer()
                    .frame(height: 16)
            }
            
            // Logo
            VStack(spacing: 16) {
                Image(systemName: "person.badge.key.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.indigo, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Welcome Back")
                    .font(.title.bold())
                
                Text("Sign in to continue")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Form
            VStack(spacing: 16) {
                if let error = errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalizationCompat(.never)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                
                Button {
                    login()
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(email.isEmpty || password.isEmpty || isLoading)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Demo Note
            GroupBox {
                HStack {
                    Image(systemName: "info.circle.fill")
                    .foregroundStyle(.blue)
                    Text("This is a demo login screen. Any password works.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func login() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.login(email: email, password: password)
                if isModal {
                    dismiss()
                } else {
                    router.pop()
                }
            } catch {
                errorMessage = "Login failed. Please try again."
            }
            isLoading = false
        }
    }
}
