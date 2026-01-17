import SwiftUI

// MARK: - Route Protocol

/// Protocol defining navigable routes
///
/// Types conforming to this protocol can be used as navigation destinations.
/// Each route must provide a corresponding view.
///
/// ## Example
/// ```swift
/// enum AppRoute: Route {
///     case home
///     case profile(userId: String)
///     case settings
///
///     var id: Self { self }
///
///     @ViewBuilder
///     var body: some View {
///         switch self {
///         case .home:
///             HomeView()
///         case .profile(let userId):
///             ProfileView(userId: userId)
///         case .settings:
///             SettingsView()
///         }
///     }
/// }
/// ```
public protocol Route: Hashable, Identifiable, Sendable {
    associatedtype Body: View
    
    /// The view corresponding to the route
    @MainActor @ViewBuilder var body: Body { get }
}

// MARK: - Default Implementation

public extension Route where Self: Hashable {
    /// Default implementation uses hashValue as the identifier
    var id: Int {
        hashValue
    }
}

// MARK: - AnyRoute (Type Erasure)

/// Type-erased route wrapper
///
/// Used when needing to store different types of routes.
@MainActor
public struct AnyRoute: Identifiable, Hashable {
    public let id: Int
    private let _body: () -> AnyView
    private let _hashValue: Int
    
    public init<R: Route>(_ route: R) {
        self.id = route.hashValue
        self._body = { AnyView(route.body) }
        self._hashValue = route.hashValue
    }
    
    public var body: AnyView {
        _body()
    }
    
    nonisolated public static func == (lhs: AnyRoute, rhs: AnyRoute) -> Bool {
        lhs._hashValue == rhs._hashValue
    }
    
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(_hashValue)
    }
}
