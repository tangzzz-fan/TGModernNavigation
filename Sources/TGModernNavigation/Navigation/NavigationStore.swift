import SwiftUI
import Observation

// MARK: - NavigationStore

/// Navigation State Storage
///
/// Acts as the single source of truth for the navigation system, managing navigation state and action dispatching.
/// Uses Swift's @Observable macro for reactive updates.
///
/// ## Example
/// ```swift
/// @State private var navigation = NavigationStore<AppRoute>()
///
/// var body: some View {
///     ModernNavigationStack(store: navigation) {
///         HomeView()
///     }
/// }
/// ```
@Observable
@MainActor
public final class NavigationStore<R: Route> {
    
    // MARK: - Properties
    
    /// Navigation Path - Directly exposed for NavigationStack binding
    /// Use this property instead of state.path to ensure binding stability
    public var navigationPath: [R] = []
    
    /// Current Navigation State (Read-only)
    public var state: NavigationState<R> {
        NavigationState(path: navigationPath)
    }
    
    /// List of Middlewares
    private var middlewares: [AnyNavigationMiddleware<R>] = []
    
    /// State Change Observers
    private var stateObservers: [(NavigationState<R>, NavigationState<R>) -> Void] = []
    
    /// Flag to indicate internal updates to prevent cycles
    private var isUpdatingInternally = false
    
    // MARK: - Initialization
    
    /// Creates an empty navigation store
    public init() {
        self.navigationPath = []
    }
    
    /// Creates a navigation store with an initial state
    /// - Parameter initialState: The initial navigation state
    public init(initialState: NavigationState<R>) {
        self.navigationPath = initialState.path
    }
    
    /// Creates a navigation store with an initial path
    /// - Parameter initialPath: The initial navigation path
    public init(initialPath: [R]) {
        self.navigationPath = initialPath
    }
    
    // MARK: - Dispatch
    
    /// Dispatches a navigation action
    /// - Parameter action: The action to dispatch
    public func dispatch(_ action: NavigationAction<R>) {
        // Prevent cyclic updates
        guard !isUpdatingInternally else { return }
        
        // Process through middlewares
        let processedAction = processMiddlewares(action: action)
        
        guard let finalAction = processedAction else {
            // Action was intercepted
            return
        }
        
        // Save old state for callbacks
        let oldState = state
        
        // Calculate new state using Reducer
        let newState = NavigationReducer.reduce(state: oldState, action: finalAction)
        
        // Update path
        isUpdatingInternally = true
        navigationPath = newState.path
        isUpdatingInternally = false
        
        // Notify observers
        notifyObservers(oldState: oldState, newState: newState)
    }
    
    // MARK: - Convenience Methods
    
    /// Pushes a new route
    /// - Parameter route: The route to push
    public func push(_ route: R) {
        dispatch(.push(route))
    }
    
    /// Pops the current route
    public func pop() {
        dispatch(.pop)
    }
    
    /// Pops a specified number of routes
    /// - Parameter count: The number of routes to pop
    public func pop(count: Int) {
        dispatch(.popCount(count))
    }
    
    /// Pops to a specific route
    /// - Parameter route: The target route
    public func popTo(_ route: R) {
        dispatch(.popTo(route))
    }
    
    /// Pops to the root view
    public func popToRoot() {
        dispatch(.popToRoot)
    }
    
    /// Replaces the entire navigation path
    /// - Parameter routes: The new path
    public func replace(_ routes: [R]) {
        dispatch(.replace(routes))
    }
    
    /// Inserts a route at a specific index
    /// - Parameters:
    ///   - route: The route to insert
    ///   - index: The insertion index
    public func insert(_ route: R, at index: Int) {
        dispatch(.insert(route, at: index))
    }
    
    /// Removes a route at a specific index
    /// - Parameter index: The index to remove
    public func remove(at index: Int) {
        dispatch(.remove(at: index))
    }
    
    // MARK: - Computed Properties
    
    /// Current navigation path
    public var path: [R] {
        navigationPath
    }
    
    /// Whether it is possible to pop (go back)
    public var canPop: Bool {
        !navigationPath.isEmpty
    }
    
    /// Current route (top of stack)
    public var currentRoute: R? {
        navigationPath.last
    }
    
    /// Navigation stack depth
    public var count: Int {
        navigationPath.count
    }
    
    /// Whether the navigation stack is empty
    public var isEmpty: Bool {
        navigationPath.isEmpty
    }
    
    // MARK: - Binding
    
    /// Gets the path Binding for use with NavigationStack
    /// Note: This binding synchronizes system navigation operations (e.g., swipe back)
    public var pathBinding: Binding<[R]> {
        Binding(
            get: { self.navigationPath },
            set: { [weak self] newPath in
                guard let self = self else { return }
                // Check if it's a system-triggered change (e.g., swipe back)
                guard !self.isUpdatingInternally else { return }
                
                // Update path directly, bypassing dispatch
                // This avoids conflicts with system navigation
                let oldState = self.state
                self.navigationPath = newPath
                let newState = self.state
                self.notifyObservers(oldState: oldState, newState: newState)
            }
        )
    }
    
    // MARK: - Middleware
    
    /// Adds a middleware
    /// - Parameter middleware: The middleware to add
    public func addMiddleware<M: NavigationMiddleware>(_ middleware: M) where M.RouteType == R {
        middlewares.append(AnyNavigationMiddleware(middleware))
    }
    
    /// Enables logging middleware
    /// - Parameter logger: The logger closure
    public func enableLogging(logger: @escaping @Sendable (String) -> Void = { print($0) }) {
        addMiddleware(LoggingMiddleware(logger: logger))
    }
    
    /// Adds a navigation guard
    /// - Parameter handler: The guard handler
    public func addGuard(_ handler: @escaping GuardMiddleware<R>.GuardHandler) {
        addMiddleware(GuardMiddleware(handler: handler))
    }
    
    // MARK: - Observers
    
    /// Adds a state change observer
    /// - Parameter observer: The observer closure, receiving old and new states
    public func observe(_ observer: @escaping (NavigationState<R>, NavigationState<R>) -> Void) {
        stateObservers.append(observer)
    }
    
    // MARK: - Private Methods
    
    private func processMiddlewares(action: NavigationAction<R>) -> NavigationAction<R>? {
        var currentAction: NavigationAction<R>? = action
        
        for middleware in middlewares {
            guard let actionToProcess = currentAction else {
                return nil
            }
            
            currentAction = middleware.process(
                action: actionToProcess,
                state: state,
                next: { [weak self] newAction in
                    self?.dispatch(newAction)
                }
            )
        }
        
        return currentAction
    }
    
    private func notifyObservers(oldState: NavigationState<R>, newState: NavigationState<R>) {
        for observer in stateObservers {
            observer(oldState, newState)
        }
    }
}

// MARK: - Sendable

extension NavigationStore: @unchecked Sendable {}

// MARK: - CustomStringConvertible

extension NavigationStore: CustomStringConvertible {
    nonisolated public var description: String {
        "NavigationStore<\(R.self)>"
    }
}
