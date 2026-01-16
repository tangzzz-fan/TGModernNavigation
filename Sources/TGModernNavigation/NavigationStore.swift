import SwiftUI
import Observation

// MARK: - NavigationStore

/// 导航状态存储
///
/// 作为导航系统的单一数据源，管理导航状态和动作分发。
/// 使用 Swift 的 @Observable 宏实现响应式更新。
///
/// ## 示例
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
    
    /// 导航路径 - 直接暴露给 NavigationStack 绑定
    /// 使用此属性而非 state.path 来确保绑定稳定性
    public var navigationPath: [R] = []
    
    /// 当前导航状态（只读）
    public var state: NavigationState<R> {
        NavigationState(path: navigationPath)
    }
    
    /// 中间件列表
    private var middlewares: [AnyNavigationMiddleware<R>] = []
    
    /// 状态变化回调
    private var stateObservers: [(NavigationState<R>, NavigationState<R>) -> Void] = []
    
    /// 标记是否正在处理内部更新，防止循环
    private var isUpdatingInternally = false
    
    // MARK: - Initialization
    
    /// 创建空的导航存储
    public init() {
        self.navigationPath = []
    }
    
    /// 使用初始状态创建导航存储
    /// - Parameter initialState: 初始导航状态
    public init(initialState: NavigationState<R>) {
        self.navigationPath = initialState.path
    }
    
    /// 使用初始路径创建导航存储
    /// - Parameter initialPath: 初始导航路径
    public init(initialPath: [R]) {
        self.navigationPath = initialPath
    }
    
    // MARK: - Dispatch
    
    /// 分发导航动作
    /// - Parameter action: 要分发的动作
    public func dispatch(_ action: NavigationAction<R>) {
        // 防止循环更新
        guard !isUpdatingInternally else { return }
        
        // 通过中间件处理
        let processedAction = processMiddlewares(action: action)
        
        guard let finalAction = processedAction else {
            // 动作被拦截
            return
        }
        
        // 保存旧状态用于回调
        let oldState = state
        
        // 使用 Reducer 计算新状态
        let newState = NavigationReducer.reduce(state: oldState, action: finalAction)
        
        // 更新路径
        isUpdatingInternally = true
        navigationPath = newState.path
        isUpdatingInternally = false
        
        // 通知观察者
        notifyObservers(oldState: oldState, newState: newState)
    }
    
    // MARK: - Convenience Methods
    
    /// 压入新路由
    /// - Parameter route: 要压入的路由
    public func push(_ route: R) {
        dispatch(.push(route))
    }
    
    /// 弹出当前路由
    public func pop() {
        dispatch(.pop)
    }
    
    /// 弹出指定数量的路由
    /// - Parameter count: 要弹出的数量
    public func pop(count: Int) {
        dispatch(.popCount(count))
    }
    
    /// 弹出到指定路由
    /// - Parameter route: 目标路由
    public func popTo(_ route: R) {
        dispatch(.popTo(route))
    }
    
    /// 弹出到根视图
    public func popToRoot() {
        dispatch(.popToRoot)
    }
    
    /// 替换整个导航路径
    /// - Parameter routes: 新的路径
    public func replace(_ routes: [R]) {
        dispatch(.replace(routes))
    }
    
    /// 在指定位置插入路由
    /// - Parameters:
    ///   - route: 要插入的路由
    ///   - index: 插入位置
    public func insert(_ route: R, at index: Int) {
        dispatch(.insert(route, at: index))
    }
    
    /// 移除指定位置的路由
    /// - Parameter index: 要移除的位置
    public func remove(at index: Int) {
        dispatch(.remove(at: index))
    }
    
    // MARK: - Computed Properties
    
    /// 当前导航路径
    public var path: [R] {
        navigationPath
    }
    
    /// 是否可以返回
    public var canPop: Bool {
        !navigationPath.isEmpty
    }
    
    /// 当前路由
    public var currentRoute: R? {
        navigationPath.last
    }
    
    /// 导航栈深度
    public var count: Int {
        navigationPath.count
    }
    
    /// 导航栈是否为空
    public var isEmpty: Bool {
        navigationPath.isEmpty
    }
    
    // MARK: - Binding
    
    /// 获取路径的 Binding，用于与 NavigationStack 绑定
    /// 注意：此绑定会同步系统导航操作（如滑动返回）
    public var pathBinding: Binding<[R]> {
        Binding(
            get: { self.navigationPath },
            set: { [weak self] newPath in
                guard let self = self else { return }
                // 检查是否是系统触发的变化（如滑动返回）
                guard !self.isUpdatingInternally else { return }
                
                // 直接更新路径，不通过 dispatch
                // 这样可以避免与系统导航产生冲突
                let oldState = self.state
                self.navigationPath = newPath
                let newState = self.state
                self.notifyObservers(oldState: oldState, newState: newState)
            }
        )
    }
    
    // MARK: - Middleware
    
    /// 添加中间件
    /// - Parameter middleware: 要添加的中间件
    public func addMiddleware<M: NavigationMiddleware>(_ middleware: M) where M.RouteType == R {
        middlewares.append(AnyNavigationMiddleware(middleware))
    }
    
    /// 添加日志中间件
    /// - Parameter logger: 日志处理器
    public func enableLogging(logger: @escaping @Sendable (String) -> Void = { print($0) }) {
        addMiddleware(LoggingMiddleware(logger: logger))
    }
    
    /// 添加导航守卫
    /// - Parameter handler: 守卫处理器
    public func addGuard(_ handler: @escaping GuardMiddleware<R>.GuardHandler) {
        addMiddleware(GuardMiddleware(handler: handler))
    }
    
    // MARK: - Observers
    
    /// 添加状态变化观察者
    /// - Parameter observer: 观察者闭包，接收旧状态和新状态
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
