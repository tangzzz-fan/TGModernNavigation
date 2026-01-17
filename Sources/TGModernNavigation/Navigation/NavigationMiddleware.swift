import Foundation

// MARK: - NavigationMiddleware

/// Navigation Middleware Protocol
///
/// Middleware intercepts and processes actions before they reach the Reducer,
/// suitable for logging, analytics, permission checks, etc.
public protocol NavigationMiddleware<RouteType>: Sendable {
    associatedtype RouteType: Route
    
    /// Process a navigation action
    /// - Parameters:
    ///   - action: The action to process
    ///   - state: The current state
    ///   - next: The closure to pass to the next middleware or Reducer
    /// - Returns: The processed action, or nil to drop the action
    @MainActor
    func process(
        action: NavigationAction<RouteType>,
        state: NavigationState<RouteType>,
        next: @escaping (NavigationAction<RouteType>) -> Void
    ) -> NavigationAction<RouteType>?
}

// MARK: - Logging Middleware

/// Logging Middleware
///
/// Logs all navigation actions and state changes.
public struct LoggingMiddleware<R: Route>: NavigationMiddleware {
    public typealias RouteType = R
    
    private let logger: @Sendable (String) -> Void
    
    public init(logger: @escaping @Sendable (String) -> Void = { print($0) }) {
        self.logger = logger
    }
    
    @MainActor
    public func process(
        action: NavigationAction<R>,
        state: NavigationState<R>,
        next: @escaping (NavigationAction<R>) -> Void
    ) -> NavigationAction<R>? {
        logger("  [Navigation] Action: \(action.name)")
        logger("  Current path count: \(state.count)")
        if let current = state.currentRoute {
            logger("  Current route: \(current)")
        }
        return action
    }
}

// MARK: - Analytics Middleware

/// Analytics Middleware
///
/// Used to send navigation events to an analytics system.
public struct AnalyticsMiddleware<R: Route>: NavigationMiddleware {
    public typealias RouteType = R
    
    public typealias EventHandler = @Sendable (NavigationEvent<R>) -> Void
    
    private let eventHandler: EventHandler
    
    public init(eventHandler: @escaping EventHandler) {
        self.eventHandler = eventHandler
    }
    
    @MainActor
    public func process(
        action: NavigationAction<R>,
        state: NavigationState<R>,
        next: @escaping (NavigationAction<R>) -> Void
    ) -> NavigationAction<R>? {
        let event = NavigationEvent(
            action: action,
            fromRoute: state.currentRoute,
            timestamp: Date()
        )
        eventHandler(event)
        return action
    }
}

/// Navigation Event
public struct NavigationEvent<R: Route>: Sendable {
    public let action: NavigationAction<R>
    public let fromRoute: R?
    public let timestamp: Date
}

// MARK: - Guard Middleware

/// Navigation Guard Middleware
///
/// Used for permission checks or conditional logic before navigation.
public struct GuardMiddleware<R: Route>: NavigationMiddleware {
    public typealias RouteType = R
    
    public typealias GuardHandler = @MainActor @Sendable (
        NavigationAction<R>,
        NavigationState<R>
    ) -> NavigationAction<R>?
    
    private let handler: GuardHandler
    
    public init(handler: @escaping GuardHandler) {
        self.handler = handler
    }
    
    @MainActor
    public func process(
        action: NavigationAction<R>,
        state: NavigationState<R>,
        next: @escaping (NavigationAction<R>) -> Void
    ) -> NavigationAction<R>? {
        handler(action, state)
    }
}

// MARK: - AnyMiddleware (Type Erasure)

/// Type-erased Middleware Wrapper
public struct AnyNavigationMiddleware<R: Route>: NavigationMiddleware, @unchecked Sendable {
    public typealias RouteType = R
    
    private let _process: @MainActor (
        NavigationAction<R>,
        NavigationState<R>,
        @escaping (NavigationAction<R>) -> Void
    ) -> NavigationAction<R>?
    
    public init<M: NavigationMiddleware>(_ middleware: M) where M.RouteType == R {
        self._process = { action, state, next in
            middleware.process(action: action, state: state, next: next)
        }
    }
    
    @MainActor
    public func process(
        action: NavigationAction<R>,
        state: NavigationState<R>,
        next: @escaping (NavigationAction<R>) -> Void
    ) -> NavigationAction<R>? {
        _process(action, state, next)
    }
}
