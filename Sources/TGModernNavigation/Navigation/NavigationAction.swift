import Foundation

// MARK: - NavigationAction

/// Navigation Action Enumeration
///
/// Defines all possible navigation operations, following the Redux Action pattern.
/// Each Action describes a navigation intent, which is processed by a Reducer to produce a new state.
public enum NavigationAction<R: Route>: Sendable {
    
    /// Push a new route to the top of the stack
    case push(R)
    
    /// Pop the top route (pop one)
    case pop
    
    /// Pop a specified number of routes
    case popCount(Int)
    
    /// Pop to a specific route
    case popTo(R)
    
    /// Pop to the root view (clear navigation stack)
    case popToRoot
    
    /// Replace the entire navigation path
    case replace([R])
    
    /// Insert a route at a specific position
    case insert(R, at: Int)
    
    /// Remove a route at a specific position
    case remove(at: Int)
}

// MARK: - Equatable

extension NavigationAction: Equatable where R: Equatable {}

// MARK: - Hashable

extension NavigationAction: Hashable where R: Hashable {}

// MARK: - Computed Properties

public extension NavigationAction {
    
    /// Whether the action increases the stack depth
    var isAdditive: Bool {
        switch self {
        case .push, .insert:
            return true
        case .pop, .popTo, .popToRoot, .replace, .remove:
            return false
        case .popCount(let count):
            return count < 0 // Negative numbers don't actually execute
        }
    }
    
    /// Whether the action decreases the stack depth
    var isSubtractive: Bool {
        switch self {
        case .pop, .popTo, .popToRoot, .remove:
            return true
        case .popCount(let count):
            return count > 0
        case .push, .insert, .replace:
            return false
        }
    }
    
    /// Name of the action (for logging)
    var name: String {
        switch self {
        case .push:
            return "push"
        case .pop:
            return "pop"
        case .popCount(let count):
            return "popCount(\(count))"
        case .popTo:
            return "popTo"
        case .popToRoot:
            return "popToRoot"
        case .replace:
            return "replace"
        case .insert:
            return "insert"
        case .remove:
            return "remove"
        }
    }
}

// MARK: - CustomStringConvertible

extension NavigationAction: CustomStringConvertible {
    public var description: String {
        switch self {
        case .push(let route):
            return "push(\(route))"
        case .pop:
            return "pop"
        case .popCount(let count):
            return "popCount(\(count))"
        case .popTo(let route):
            return "popTo(\(route))"
        case .popToRoot:
            return "popToRoot"
        case .replace(let routes):
            return "replace(\(routes))"
        case .insert(let route, let index):
            return "insert(\(route), at: \(index))"
        case .remove(let index):
            return "remove(at: \(index))"
        }
    }
}
