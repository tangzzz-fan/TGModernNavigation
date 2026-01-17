import Foundation

// MARK: - NavigationReducer

/// Navigation State Reducer
///
/// Following the Redux pattern, the Reducer is a pure function
/// that calculates the new state based on the current state and an action.
public enum NavigationReducer<R: Route> {
    
    /// Processes a navigation action and returns the new state
    /// - Parameters:
    ///   - state: Current state
    ///   - action: Action to process
    /// - Returns: New state
    public static func reduce(
        state: NavigationState<R>,
        action: NavigationAction<R>
    ) -> NavigationState<R> {
        var newState = state
        
        switch action {
        case .push(let route):
            newState.push(route)
            
        case .pop:
            newState.pop()
            
        case .popCount(let count):
            newState.pop(count: count)
            
        case .popTo(let route):
            newState.popTo(route)
            
        case .popToRoot:
            newState.popToRoot()
            
        case .replace(let routes):
            newState.replace(with: routes)
            
        case .insert(let route, let index):
            newState.insert(route, at: index)
            
        case .remove(let index):
            newState.remove(at: index)
        }
        
        return newState
    }
}

// MARK: - Reducer Protocol

/// Reducer Protocol
///
/// Allows custom Reducer implementations to extend navigation logic.
public protocol NavigationReducerProtocol<RouteType> {
    associatedtype RouteType: Route
    
    func reduce(
        state: NavigationState<RouteType>,
        action: NavigationAction<RouteType>
    ) -> NavigationState<RouteType>
}

// MARK: - Default Reducer

/// Default Reducer Implementation
public struct DefaultNavigationReducer<R: Route>: NavigationReducerProtocol {
    public typealias RouteType = R
    
    public init() {}
    
    public func reduce(
        state: NavigationState<R>,
        action: NavigationAction<R>
    ) -> NavigationState<R> {
        NavigationReducer.reduce(state: state, action: action)
    }
}

// MARK: - Combined Reducer

/// Combines multiple Reducers
///
/// Executes multiple Reducers in sequence, with the output of each Reducer serving as the input for the next.
public struct CombinedNavigationReducer<R: Route>: NavigationReducerProtocol {
    public typealias RouteType = R
    
    private let reducers: [(NavigationState<R>, NavigationAction<R>) -> NavigationState<R>]
    
    public init(
        _ reducers: [(NavigationState<R>, NavigationAction<R>) -> NavigationState<R>]
    ) {
        self.reducers = reducers
    }
    
    public func reduce(
        state: NavigationState<R>,
        action: NavigationAction<R>
    ) -> NavigationState<R> {
        reducers.reduce(state) { currentState, reducer in
            reducer(currentState, action)
        }
    }
}
