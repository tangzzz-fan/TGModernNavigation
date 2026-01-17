import SwiftUI
import Observation

public struct User: Identifiable, Codable {
    public let id: String
    public let name: String
    public let email: String
    
    public init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}

@Observable
public class AuthService {
    public static let shared = AuthService()
    
    public var isLoggedIn: Bool = false
    public var currentUser: User?
    
    private init() {}
    
    public func login(email: String, password: String) async throws {
        // Mock delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Mock validation
        if password.isEmpty {
            throw AuthError.invalidPassword
        }
        
        await MainActor.run {
            self.isLoggedIn = true
            self.currentUser = User(id: "1", name: "Demo User", email: email)
        }
    }
    
    public func logout() {
        isLoggedIn = false
        currentUser = nil
    }
}

public enum AuthError: Error {
    case invalidPassword
    case networkError
}
