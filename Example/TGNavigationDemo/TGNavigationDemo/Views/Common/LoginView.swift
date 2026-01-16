import SwiftUI
import TGModernNavigation

// MARK: - Login View

struct LoginView: View {
    @Environment(Router<AppRoute>.self) private var router
    var isModal: Bool = false
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
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
            
            // Links
            VStack(spacing: 12) {
                Button("Forgot Password?") {
                    // Handle forgot password
                }
                .font(.subheadline)
                
                HStack {
                    Text("Don't have an account?")
                        .foregroundStyle(.secondary)
                    Button("Sign Up") {
                        // Handle sign up
                    }
                }
                .font(.subheadline)
            }
            
            Spacer()
            
            // Demo Note
            GroupBox {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                    Text("This is a demo login screen. Tap Sign In to dismiss.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationBarTitleDisplayModeCompat(.inline)
        .toolbar {
            if isModal {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        router.dismiss()
                    }
                }
            }
        }
    }
    
    private func login() {
        isLoading = true
        
        // Simulate login delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            if isModal {
                router.dismiss()
            } else {
                router.pop()
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
    .environment(Router<AppRoute>())
}
