import SwiftUI

// MARK: - PresentationState

/// Modal Presentation State
///
/// Supports nested modal presentations (sheet on top of sheet).
public struct PresentationState<R: Route>: Equatable, Sendable {
    
    /// Current presentation stack (supports nested modals)
    public private(set) var stack: [PresentedRoute<R>]
    
    /// Create empty presentation state
    public init() {
        self.stack = []
    }
    
    /// Create state with initial stack
    public init(stack: [PresentedRoute<R>]) {
        self.stack = stack
    }
    
    // MARK: - Computed Properties
    
    /// Whether any modal is currently presented
    public var isPresenting: Bool {
        !stack.isEmpty
    }
    
    /// The currently presented route (topmost)
    public var current: PresentedRoute<R>? {
        stack.last
    }
    
    /// The currently presented route value
    public var currentRoute: R? {
        stack.last?.route
    }
    
    /// Depth of the presentation stack
    public var count: Int {
        stack.count
    }
    
    // MARK: - Internal Mutations
    
    /// Present a new route
    mutating func present(_ presented: PresentedRoute<R>) {
        stack.append(presented)
    }
    
    /// Dismiss the topmost modal
    @discardableResult
    mutating func dismiss() -> PresentedRoute<R>? {
        guard !stack.isEmpty else { return nil }
        return stack.removeLast()
    }
    
    /// Dismiss all modals
    mutating func dismissAll() {
        stack.removeAll()
    }
    
    /// Dismiss until a specific route is found
    @discardableResult
    mutating func dismissTo(_ route: R) -> Bool {
        guard let index = stack.lastIndex(where: { $0.route == route }) else {
            return false
        }
        stack = Array(stack.prefix(through: index))
        return true
    }
    
    /// Replace the currently presented route
    mutating func replace(with presented: PresentedRoute<R>) {
        if stack.isEmpty {
            stack.append(presented)
        } else {
            stack[stack.count - 1] = presented
        }
    }
}
