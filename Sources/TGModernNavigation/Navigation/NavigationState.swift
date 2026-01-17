import SwiftUI

// MARK: - NavigationState

/// Navigation State Structure
///
/// Stores the current navigation path. It is an immutable value type.
/// Follows the Single Source of Truth principle of Redux.
public struct NavigationState<R: Route>: Equatable, Sendable {
    
    /// The current navigation path
    public private(set) var path: [R]
    
    /// Creates an empty navigation state
    public init() {
        self.path = []
    }
    
    /// Creates a navigation state with an initial path
    /// - Parameter path: The initial navigation path
    public init(path: [R]) {
        self.path = path
    }
    
    // MARK: - Computed Properties
    
    /// Whether the navigation stack is empty
    public var isEmpty: Bool {
        path.isEmpty
    }
    
    /// Number of routes in the navigation stack
    public var count: Int {
        path.count
    }
    
    /// Current route (top of stack)
    public var currentRoute: R? {
        path.last
    }
    
    /// Whether it is possible to go back
    public var canPop: Bool {
        !path.isEmpty
    }
    
    /// Gets the route at a specific index
    /// - Parameter index: The index
    /// - Returns: The corresponding route, or nil if the index is invalid
    public subscript(index: Int) -> R? {
        guard index >= 0 && index < path.count else { return nil }
        return path[index]
    }
    
    // MARK: - Internal Mutations
    
    /// Pushes a new route (internal use)
    mutating func push(_ route: R) {
        path.append(route)
    }
    
    /// Pops the top route (internal use)
    @discardableResult
    mutating func pop() -> R? {
        guard !path.isEmpty else { return nil }
        return path.removeLast()
    }
    
    /// Pops to a specific route (internal use)
    /// - Parameter route: The target route
    /// - Returns: Whether the target route was found and popped to
    @discardableResult
    mutating func popTo(_ route: R) -> Bool {
        guard let index = path.lastIndex(of: route) else { return false }
        path = Array(path.prefix(through: index))
        return true
    }
    
    /// Pops to the root view (internal use)
    mutating func popToRoot() {
        path.removeAll()
    }
    
    /// Pops a specified number of routes (internal use)
    /// - Parameter count: The number of routes to pop
    mutating func pop(count: Int) {
        let removeCount = min(count, path.count)
        path.removeLast(removeCount)
    }
    
    /// Replaces the entire path (internal use)
    mutating func replace(with newPath: [R]) {
        path = newPath
    }
    
    /// Inserts a route at a specific index (internal use)
    mutating func insert(_ route: R, at index: Int) {
        let safeIndex = max(0, min(index, path.count))
        path.insert(route, at: safeIndex)
    }
    
    /// Removes a route at a specific index (internal use)
    @discardableResult
    mutating func remove(at index: Int) -> R? {
        guard index >= 0 && index < path.count else { return nil }
        return path.remove(at: index)
    }
}

// MARK: - CustomStringConvertible

extension NavigationState: CustomStringConvertible {
    public var description: String {
        "NavigationState(count: \(count), path: \(path))"
    }
}

// MARK: - CustomDebugStringConvertible

extension NavigationState: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        NavigationState {
            count: \(count)
            isEmpty: \(isEmpty)
            canPop: \(canPop)
            currentRoute: \(String(describing: currentRoute))
            path: \(path)
        }
        """
    }
}
