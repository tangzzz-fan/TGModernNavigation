import SwiftUI

// MARK: - Pluggable Routing Infrastructure

/// Route Handler Protocol
///
/// Each feature module implements this protocol to handle routes it is responsible for.
/// This allows splitting a large switch-case into multiple modules.
public protocol RouteHandler {
    associatedtype R: Route
    
    /// Try to build a view for the given route
    /// - Parameter route: The route object
    /// - Returns: A view wrapped in AnyView if this module handles the route; otherwise nil.
    @MainActor
    func view(for route: R) -> AnyView?
}

/// Route Registry
///
/// Responsible for managing all registered route handlers and dispatching route requests.
@MainActor
public final class RouteRegistry<R: Route> {
    
    /// Stored view resolvers
    private var resolvers: [(R) -> AnyView?] = []
    
    public init() {}
    
    /// Register a route handler
    /// - Parameter handler: The route handler from a feature module
    public func register<H: RouteHandler>(_ handler: H) where H.R == R {
        resolvers.append(handler.view)
    }
    
    /// Batch register
    public func register<H: RouteHandler>(_ handlers: [H]) where H.R == R {
        for handler in handlers {
            resolvers.append(handler.view)
        }
    }
    
    /// Resolve view for a route
    /// - Parameter route: Target route
    /// - Returns: The constructed view
    public func view(for route: R) -> some View {
        // Iterate through all handlers to find the first one that can handle the route
        for resolver in resolvers {
            if let view = resolver(route) {
                return view
            }
        }
        
        // Fallback: If no handler is found
        return AnyView(
            ContentUnavailableView(
                "Route Not Found",
                systemImage: "exclamationmark.triangle",
                description: Text("No handler registered for route ID: \(route.id)")
            )
        )
    }
}
