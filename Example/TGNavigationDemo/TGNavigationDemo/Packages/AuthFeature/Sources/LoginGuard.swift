import SwiftUI

public struct LoginGuard<Content: View>: View {
    @State private var authService = AuthService.shared
    @Binding var isPresented: Bool
    let content: Content
    
    public init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }
    
    public var body: some View {
        content
            .sheet(isPresented: $isPresented) {
                LoginView(isModal: true)
            }
            .onChange(of: authService.isLoggedIn) { _, newValue in
                if newValue {
                    isPresented = false
                }
            }
    }
}

public extension View {
    func loginGuard(isPresented: Binding<Bool>) -> some View {
        LoginGuard(isPresented: isPresented) {
            self
        }
    }
}
