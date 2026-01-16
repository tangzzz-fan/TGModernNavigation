import Foundation

// MARK: - NavigationReducer

/// 导航状态的 Reducer
///
/// 遵循 Redux 模式，Reducer 是一个纯函数，
/// 根据当前状态和动作计算出新的状态。
public enum NavigationReducer<R: Route> {
    
    /// 处理导航动作，返回新的状态
    /// - Parameters:
    ///   - state: 当前状态
    ///   - action: 要处理的动作
    /// - Returns: 新的状态
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

/// Reducer 协议
///
/// 允许自定义 Reducer 实现，用于扩展导航逻辑。
public protocol NavigationReducerProtocol<RouteType> {
    associatedtype RouteType: Route
    
    func reduce(
        state: NavigationState<RouteType>,
        action: NavigationAction<RouteType>
    ) -> NavigationState<RouteType>
}

// MARK: - Default Reducer

/// 默认的 Reducer 实现
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

/// 组合多个 Reducer
///
/// 按顺序执行多个 Reducer，每个 Reducer 的输出作为下一个的输入。
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
