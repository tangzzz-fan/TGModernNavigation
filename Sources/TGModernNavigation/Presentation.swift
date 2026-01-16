import SwiftUI

// MARK: - PresentationStyle

/// 模态展示样式
public enum PresentationStyle: Sendable, Equatable, Hashable {
    /// Sheet 样式（iOS 默认的半屏/可下拉关闭）
    case sheet
    
    /// 全屏覆盖样式（仅 iOS/tvOS/watchOS/visionOS）
    case fullScreenCover
}

// MARK: - SheetConfiguration

/// Sheet 展示的高度配置
public struct SheetConfiguration: Sendable, Equatable {
    public var detents: Set<PresentationDetent>
    public var dragIndicatorVisibility: Visibility
    public var interactiveDismissDisabled: Bool
    
    public init(
        detents: Set<PresentationDetent> = [.large],
        dragIndicatorVisibility: Visibility = .automatic,
        interactiveDismissDisabled: Bool = false
    ) {
        self.detents = detents
        self.dragIndicatorVisibility = dragIndicatorVisibility
        self.interactiveDismissDisabled = interactiveDismissDisabled
    }
    
    public static let `default` = SheetConfiguration()
    
    /// 半屏 Sheet
    public static let medium = SheetConfiguration(detents: [.medium])
    
    /// 全屏 Sheet
    public static let large = SheetConfiguration(detents: [.large])
    
    /// 可调节高度的 Sheet
    public static let flexible = SheetConfiguration(detents: [.medium, .large])
}

// MARK: - PresentedRoute

/// 展示的路由包装
public struct PresentedRoute<R: Route>: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let route: R
    public let style: PresentationStyle
    public let configuration: SheetConfiguration
    
    public init(
        route: R,
        style: PresentationStyle = .sheet,
        configuration: SheetConfiguration = .default
    ) {
        self.id = UUID()
        self.route = route
        self.style = style
        self.configuration = configuration
    }
    
    public static func == (lhs: PresentedRoute<R>, rhs: PresentedRoute<R>) -> Bool {
        lhs.id == rhs.id && lhs.route == rhs.route && lhs.style == rhs.style
    }
}

// MARK: - PresentationState

/// 模态展示状态
///
/// 支持多层模态展示（sheet 上面再展示 sheet）
public struct PresentationState<R: Route>: Equatable, Sendable {
    
    /// 当前展示的路由栈（支持多层模态）
    public private(set) var stack: [PresentedRoute<R>]
    
    /// 创建空的展示状态
    public init() {
        self.stack = []
    }
    
    /// 使用初始展示栈创建状态
    public init(stack: [PresentedRoute<R>]) {
        self.stack = stack
    }
    
    // MARK: - Computed Properties
    
    /// 是否有模态正在展示
    public var isPresenting: Bool {
        !stack.isEmpty
    }
    
    /// 当前展示的路由（最顶层）
    public var current: PresentedRoute<R>? {
        stack.last
    }
    
    /// 当前展示的路由值
    public var currentRoute: R? {
        stack.last?.route
    }
    
    /// 展示栈深度
    public var count: Int {
        stack.count
    }
    
    // MARK: - Internal Mutations
    
    /// 展示新路由
    mutating func present(_ presented: PresentedRoute<R>) {
        stack.append(presented)
    }
    
    /// 关闭最顶层模态
    @discardableResult
    mutating func dismiss() -> PresentedRoute<R>? {
        guard !stack.isEmpty else { return nil }
        return stack.removeLast()
    }
    
    /// 关闭所有模态
    mutating func dismissAll() {
        stack.removeAll()
    }
    
    /// 关闭到指定路由
    @discardableResult
    mutating func dismissTo(_ route: R) -> Bool {
        guard let index = stack.lastIndex(where: { $0.route == route }) else {
            return false
        }
        stack = Array(stack.prefix(through: index))
        return true
    }
    
    /// 替换当前展示的路由
    mutating func replace(with presented: PresentedRoute<R>) {
        if stack.isEmpty {
            stack.append(presented)
        } else {
            stack[stack.count - 1] = presented
        }
    }
}

// MARK: - PresentationAction

/// 模态展示动作
public enum PresentationAction<R: Route>: Sendable {
    /// 展示一个路由
    case present(R, style: PresentationStyle, configuration: SheetConfiguration)
    
    /// 关闭最顶层模态
    case dismiss
    
    /// 关闭所有模态
    case dismissAll
    
    /// 关闭到指定路由
    case dismissTo(R)
    
    /// 替换当前展示的路由
    case replace(R, style: PresentationStyle, configuration: SheetConfiguration)
}

extension PresentationAction: Equatable where R: Equatable {}

// MARK: - PresentationReducer

/// 模态展示的 Reducer
public enum PresentationReducer<R: Route> {
    
    public static func reduce(
        state: PresentationState<R>,
        action: PresentationAction<R>
    ) -> PresentationState<R> {
        var newState = state
        
        switch action {
        case .present(let route, let style, let configuration):
            let presented = PresentedRoute(route: route, style: style, configuration: configuration)
            newState.present(presented)
            
        case .dismiss:
            newState.dismiss()
            
        case .dismissAll:
            newState.dismissAll()
            
        case .dismissTo(let route):
            newState.dismissTo(route)
            
        case .replace(let route, let style, let configuration):
            let presented = PresentedRoute(route: route, style: style, configuration: configuration)
            newState.replace(with: presented)
        }
        
        return newState
    }
}

// MARK: - PresentationStore

/// 独立的模态展示存储
///
/// 管理模态展示状态，与 NavigationStore 配合使用。
@Observable
@MainActor
public final class PresentationStore<R: Route> {
    
    /// 当前展示状态
    public private(set) var state: PresentationState<R>
    
    /// 创建空的展示存储
    public init() {
        self.state = PresentationState()
    }
    
    /// 使用初始状态创建展示存储
    public init(initialState: PresentationState<R>) {
        self.state = initialState
    }
    
    // MARK: - Dispatch
    
    /// 分发展示动作
    public func dispatch(_ action: PresentationAction<R>) {
        state = PresentationReducer.reduce(state: state, action: action)
    }
    
    // MARK: - Convenience Methods
    
    /// 展示一个路由（Sheet 样式）
    public func present(
        _ route: R,
        style: PresentationStyle = .sheet,
        configuration: SheetConfiguration = .default
    ) {
        dispatch(.present(route, style: style, configuration: configuration))
    }
    
    /// 以 Sheet 样式展示
    public func sheet(_ route: R, configuration: SheetConfiguration = .default) {
        present(route, style: .sheet, configuration: configuration)
    }
    
    /// 以全屏样式展示
    public func fullScreenCover(_ route: R) {
        present(route, style: .fullScreenCover, configuration: .default)
    }
    
    /// 关闭当前模态
    public func dismiss() {
        dispatch(.dismiss)
    }
    
    /// 关闭所有模态
    public func dismissAll() {
        dispatch(.dismissAll)
    }
    
    /// 关闭到指定路由
    public func dismissTo(_ route: R) {
        dispatch(.dismissTo(route))
    }
    
    /// 替换当前展示的路由
    public func replace(
        _ route: R,
        style: PresentationStyle = .sheet,
        configuration: SheetConfiguration = .default
    ) {
        dispatch(.replace(route, style: style, configuration: configuration))
    }
    
    // MARK: - Computed Properties
    
    /// 是否正在展示模态
    public var isPresenting: Bool {
        state.isPresenting
    }
    
    /// 当前展示的路由
    public var currentRoute: R? {
        state.currentRoute
    }
    
    /// 当前展示的完整信息
    public var current: PresentedRoute<R>? {
        state.current
    }
    
    /// 展示栈深度
    public var count: Int {
        state.count
    }
    
    // MARK: - Bindings
    
    /// Sheet 绑定
    public var sheetBinding: Binding<PresentedRoute<R>?> {
        Binding(
            get: {
                guard let current = self.state.current,
                      current.style == .sheet else {
                    return nil
                }
                return current
            },
            set: { newValue in
                if newValue == nil && self.state.current?.style == .sheet {
                    self.dismiss()
                }
            }
        )
    }
    
    /// FullScreenCover 绑定
    public var fullScreenCoverBinding: Binding<PresentedRoute<R>?> {
        Binding(
            get: {
                guard let current = self.state.current,
                      current.style == .fullScreenCover else {
                    return nil
                }
                return current
            },
            set: { newValue in
                if newValue == nil && self.state.current?.style == .fullScreenCover {
                    self.dismiss()
                }
            }
        )
    }
}

extension PresentationStore: @unchecked Sendable {}

// MARK: - Presentation View Modifier

/// 模态展示视图修饰器
public struct PresentationModifier<R: Route>: ViewModifier {
    
    @Bindable var store: PresentationStore<R>
    
    public init(store: PresentationStore<R>) {
        self.store = store
    }
    
    public func body(content: Content) -> some View {
        content
            .sheet(item: store.sheetBinding) { presented in
                presented.route.body
                    .presentationDetents(presented.configuration.detents)
                    .presentationDragIndicator(presented.configuration.dragIndicatorVisibility)
                    .interactiveDismissDisabled(presented.configuration.interactiveDismissDisabled)
                    .environment(store)
            }
            #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
            .fullScreenCover(item: store.fullScreenCoverBinding) { presented in
                presented.route.body
                    .environment(store)
            }
            #endif
    }
}

// MARK: - View Extension

public extension View {
    
    /// 启用模态展示支持
    /// - Parameter store: 展示存储
    /// - Returns: 修改后的视图
    @MainActor
    func presentation<R: Route>(store: PresentationStore<R>) -> some View {
        self.modifier(PresentationModifier(store: store))
    }
}

// MARK: - Combined Router

/// 组合路由器
///
/// 同时管理导航和模态展示，提供统一的 API。
@Observable
@MainActor
public final class Router<R: Route> {
    
    /// 导航存储
    public let navigation: NavigationStore<R>
    
    /// 展示存储
    public let presentation: PresentationStore<R>
    
    /// 创建组合路由器
    public init() {
        self.navigation = NavigationStore()
        self.presentation = PresentationStore()
    }
    
    /// 使用现有存储创建组合路由器
    public init(
        navigation: NavigationStore<R>,
        presentation: PresentationStore<R>
    ) {
        self.navigation = navigation
        self.presentation = presentation
    }
    
    // MARK: - Navigation Shortcuts
    
    /// 压入新路由
    public func push(_ route: R) {
        navigation.push(route)
    }
    
    /// 弹出当前路由
    public func pop() {
        navigation.pop()
    }
    
    /// 返回根视图
    public func popToRoot() {
        navigation.popToRoot()
    }
    
    // MARK: - Presentation Shortcuts
    
    /// 展示 Sheet
    public func sheet(_ route: R, configuration: SheetConfiguration = .default) {
        presentation.sheet(route, configuration: configuration)
    }
    
    /// 展示全屏覆盖
    public func fullScreenCover(_ route: R) {
        presentation.fullScreenCover(route)
    }
    
    /// 关闭模态
    public func dismiss() {
        presentation.dismiss()
    }
    
    /// 关闭所有模态
    public func dismissAll() {
        presentation.dismissAll()
    }
}

extension Router: @unchecked Sendable {}

// MARK: - Router Navigation Stack

/// 支持导航和展示的完整路由栈
public struct RouterNavigationStack<R: Route, Root: View>: View {
    
    @Bindable private var router: Router<R>
    @Bindable private var navigationStore: NavigationStore<R>
    private let root: () -> Root
    
    public init(
        router: Router<R>,
        @ViewBuilder root: @escaping () -> Root
    ) {
        self.router = router
        self.navigationStore = router.navigation
        self.root = root
    }
    
    public var body: some View {
        NavigationStack(path: $navigationStore.navigationPath) {
            root()
                .navigationDestination(for: R.self) { route in
                    route.body
                }
        }
        .presentation(store: router.presentation)
        .environment(router)
        .environment(router.navigation)
        .environment(router.presentation)
    }
}
