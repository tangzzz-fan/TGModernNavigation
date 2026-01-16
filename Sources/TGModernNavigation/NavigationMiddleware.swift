import Foundation

// MARK: - NavigationMiddleware

/// 导航中间件协议
///
/// 中间件用于在动作到达 Reducer 之前进行拦截和处理，
/// 可以用于日志记录、分析、权限检查等场景。
public protocol NavigationMiddleware<RouteType>: Sendable {
    associatedtype RouteType: Route
    
    /// 处理导航动作
    /// - Parameters:
    ///   - action: 要处理的动作
    ///   - state: 当前状态
    ///   - next: 传递给下一个中间件或 Reducer 的闭包
    /// - Returns: 处理后的动作，返回 nil 表示拦截该动作
    @MainActor
    func process(
        action: NavigationAction<RouteType>,
        state: NavigationState<RouteType>,
        next: @escaping (NavigationAction<RouteType>) -> Void
    ) -> NavigationAction<RouteType>?
}

// MARK: - Logging Middleware

/// 日志中间件
///
/// 记录所有导航动作和状态变化。
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

/// 分析中间件
///
/// 用于发送导航事件到分析系统。
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

/// 导航事件
public struct NavigationEvent<R: Route>: Sendable {
    public let action: NavigationAction<R>
    public let fromRoute: R?
    public let timestamp: Date
}

// MARK: - Guard Middleware

/// 导航守卫中间件
///
/// 用于在导航前进行权限检查或条件判断。
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

/// 类型擦除的中间件包装器
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
