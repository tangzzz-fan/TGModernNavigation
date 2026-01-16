import SwiftUI

// MARK: - ModernNavigationStack

/// 现代导航栈视图
///
/// 封装 SwiftUI 的 NavigationStack，与 NavigationStore 集成，
/// 提供基于 Redux 思想的声明式导航体验。
///
/// ## 示例
/// ```swift
/// struct ContentView: View {
///     @State private var navigation = NavigationStore<AppRoute>()
///
///     var body: some View {
///         ModernNavigationStack(store: navigation) {
///             HomeView()
///         }
///     }
/// }
/// ```
public struct ModernNavigationStack<R: Route, Root: View>: View {
    
    @Bindable private var store: NavigationStore<R>
    private let root: () -> Root
    
    /// 创建现代导航栈
    /// - Parameters:
    ///   - store: 导航状态存储
    ///   - root: 根视图构建器
    public init(
        store: NavigationStore<R>,
        @ViewBuilder root: @escaping () -> Root
    ) {
        self.store = store
        self.root = root
    }
    
    public var body: some View {
        NavigationStack(path: $store.navigationPath) {
            root()
                .navigationDestination(for: R.self) { route in
                    route.body
                }
        }
    }
}

// MARK: - ModernNavigationLink

/// 现代导航链接
///
/// 提供声明式的导航触发方式，自动与 NavigationStore 集成。
public struct ModernNavigationLink<R: Route, Label: View>: View {
    
    @Environment(NavigationStore<R>.self) private var store
    
    private let route: R
    private let label: () -> Label
    
    /// 创建导航链接
    /// - Parameters:
    ///   - route: 目标路由
    ///   - label: 标签视图构建器
    public init(
        to route: R,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.route = route
        self.label = label
    }
    
    public var body: some View {
        Button {
            store.push(route)
        } label: {
            label()
        }
    }
}

// MARK: - Convenience Initializers

public extension ModernNavigationLink where Label == Text {
    
    /// 创建文本标签的导航链接
    /// - Parameters:
    ///   - title: 标题
    ///   - route: 目标路由
    init(_ title: String, to route: R) {
        self.route = route
        self.label = { Text(title) }
    }
    
    /// 创建本地化文本标签的导航链接
    /// - Parameters:
    ///   - titleKey: 本地化标题键
    ///   - route: 目标路由
    init(_ titleKey: LocalizedStringKey, to route: R) {
        self.route = route
        self.label = { Text(titleKey) }
    }
}

// MARK: - Navigation Modifiers

public extension View {
    
    /// 添加导航返回按钮
    /// - Parameters:
    ///   - store: 导航存储
    ///   - isPresented: 是否显示
    /// - Returns: 修改后的视图
    @MainActor
    func navigationBackButton<R: Route>(
        store: NavigationStore<R>,
        isPresented: Bool = true
    ) -> some View {
        self.toolbar {
            if isPresented && store.canPop {
                ToolbarItem(placement: .navigation) {
                    Button {
                        store.pop()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
    }
    
    /// 监听路由变化
    /// - Parameters:
    ///   - store: 导航存储
    ///   - action: 变化时的回调
    /// - Returns: 修改后的视图
    @MainActor
    func onNavigationChange<R: Route>(
        store: NavigationStore<R>,
        perform action: @escaping ([R]) -> Void
    ) -> some View {
        self.onChange(of: store.path) { _, newPath in
            action(newPath)
        }
    }
}

// MARK: - Pop Gesture Modifier

/// 支持滑动返回的修饰器
public struct PopGestureModifier<R: Route>: ViewModifier {
    
    @Bindable var store: NavigationStore<R>
    let isEnabled: Bool
    
    public func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if isEnabled &&
                            store.canPop &&
                            value.translation.width > 100 &&
                            abs(value.translation.height) < 50 {
                            store.pop()
                        }
                    }
            )
    }
}

public extension View {
    
    /// 启用滑动返回手势
    /// - Parameters:
    ///   - store: 导航存储
    ///   - isEnabled: 是否启用
    /// - Returns: 修改后的视图
    @MainActor
    func popGestureEnabled<R: Route>(
        store: NavigationStore<R>,
        isEnabled: Bool = true
    ) -> some View {
        self.modifier(PopGestureModifier(store: store, isEnabled: isEnabled))
    }
}

// MARK: - Router View

/// 路由视图包装器
///
/// 自动渲染当前路由对应的视图。
public struct RouterView<R: Route>: View {
    
    @Environment(NavigationStore<R>.self) private var store
    private let fallback: AnyView
    
    /// 创建路由视图
    /// - Parameter fallback: 当没有当前路由时显示的视图
    public init<Fallback: View>(@ViewBuilder fallback: () -> Fallback) {
        self.fallback = AnyView(fallback())
    }
    
    public var body: some View {
        if let route = store.currentRoute {
            route.body
        } else {
            fallback
        }
    }
}
