# TGModernNavigation

基于 Redux 思想的 SwiftUI Modern Navigation 状态管理库。

## 设计理念

### 为什么选择 Redux 模式？

SwiftUI 的 `NavigationStack` 提供了强大的声明式导航能力，但在复杂应用中存在以下挑战：

1. **状态分散**：导航状态容易分散在各个视图中
2. **难以追踪**：导航变化难以调试和追踪
3. **测试困难**：UI 和导航逻辑耦合
4. **Deep Linking**：复杂的深度链接场景处理困难

Redux 模式通过以下方式解决这些问题：

- **单一数据源 (Single Source of Truth)**：所有导航状态集中在 `NavigationStore`
- **状态不可变**：通过 `Action` 描述变化意图，由 `Reducer` 计算新状态
- **纯函数**：`Reducer` 是纯函数，便于测试
- **可预测**：相同的 `Action` 序列总是产生相同的状态

## 核心组件

### 1. Route 协议

定义可导航的路由类型：

```swift
public protocol Route: Hashable, Identifiable, Sendable {
    associatedtype Body: View
    @ViewBuilder var body: Body { get }
}
```

### 2. NavigationState

存储导航状态的不可变结构：

```swift
public struct NavigationState<R: Route>: Equatable {
    public var path: [R]
    public var navigationPath: NavigationPath
    
    public var isEmpty: Bool
    public var count: Int
    public var currentRoute: R?
}
```

### 3. NavigationAction

描述导航意图的枚举：

```swift
public enum NavigationAction<R: Route> {
    case push(R)                    // 压入新路由
    case pop                        // 弹出当前路由
    case popTo(R)                   // 弹出到指定路由
    case popToRoot                  // 返回根视图
    case replace([R])               // 替换整个路径
    case insert(R, at: Int)         // 在指定位置插入
    case remove(at: Int)            // 移除指定位置的路由
}
```

### 4. NavigationReducer

纯函数，根据 Action 计算新状态：

```swift
public struct NavigationReducer<R: Route> {
    public static func reduce(
        state: NavigationState<R>,
        action: NavigationAction<R>
    ) -> NavigationState<R>
}
```

### 5. NavigationStore

ObservableObject，管理导航状态：

```swift
@Observable
public final class NavigationStore<R: Route> {
    public private(set) var state: NavigationState<R>
    
    public func dispatch(_ action: NavigationAction<R>)
    
    // 便捷方法
    public func push(_ route: R)
    public func pop()
    public func popToRoot()
    public func replace(_ routes: [R])
}
```

### 6. ModernNavigationStack

包装 NavigationStack 的视图：

```swift
public struct ModernNavigationStack<R: Route, Root: View>: View {
    @Bindable var store: NavigationStore<R>
    let root: () -> Root
}
```

## 使用示例

### 1. 定义路由

```swift
enum AppRoute: Route {
    case home
    // Push 路由 (不包含 NavigationStack)
    case profile(userId: String)
    case settings
    case detail(itemId: Int)
    
    // Sheet/Modal 路由 (包含 NavigationStack)
    case profileSheet(userId: String)
    case settingsSheet
    case loginSheet
    
    var id: Self { self }
    
    @ViewBuilder
    var body: some View {
        switch self {
        case .home:
            HomeView()
        case .profile(let userId):
            ProfileView(userId: userId, isModal: false)
        case .settings:
            SettingsView(isModal: false)
        case .detail(let itemId):
            DetailView(itemId: itemId)
            
        // Modal 路由需要包裹 NavigationStack
        case .profileSheet(let userId):
            NavigationStack {
                ProfileView(userId: userId, isModal: true)
            }
        case .settingsSheet:
            NavigationStack {
                SettingsView(isModal: true)
            }
        case .loginSheet:
            NavigationStack {
                LoginView(isModal: true)
            }
        }
    }
}
```

### 2. 初始化 Router

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(Router(root: .home))
        }
    }
}
```

## 最佳实践：Push vs Sheet 导航

在 SwiftUI 中处理导航时，需要特别注意 `NavigationStack` 的嵌套问题。

### 问题背景
如果一个视图（如 `SettingsView`）内部包含了 `NavigationStack`，当它被 Push 到现有的导航栈中时，会产生嵌套的 `NavigationStack`。这会导致：
1. Path 绑定丢失
2. 应用可能意外重置回根视图 (popToRoot)
3. 后续导航失效

### 解决方案
采用 **分离路由** 策略：
1. **Push 路由**：直接返回视图内容，**不包裹** `NavigationStack`。
2. **Sheet/Modal 路由**：使用 `NavigationStack` 包裹视图，确保模态视图有自己的导航上下文。

### 代码范式

```swift
enum AppRoute: Route {
    // 1. 定义两套路由 case
    case settings       // 用于 Push
    case settingsSheet  // 用于 Sheet/Modal

    @ViewBuilder
    var body: some View {
        switch self {
        case .settings:
            // Push 场景：直接返回视图，复用父级 NavigationStack
            SettingsView(isModal: false)
            
        case .settingsSheet:
            // Sheet 场景：包裹新的 NavigationStack
            NavigationStack {
                SettingsView(isModal: true)
            }
        }
    }
}
```

在视图中，可以通过 `isModal` 属性来动态调整 UI（例如显示 "返回" 还是 "关闭" 按钮）。

### 2. 创建 Store

```swift
@main
struct MyApp: App {
    @State private var navigationStore = NavigationStore<AppRoute>()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(navigationStore)
        }
    }
}
```

### 3. 使用 ModernNavigationStack

```swift
struct ContentView: View {
    @Environment(NavigationStore<AppRoute>.self) var navigation
    
    var body: some View {
        ModernNavigationStack(store: navigation) {
            HomeView()
        }
    }
}
```

### 4. 在视图中导航

```swift
struct HomeView: View {
    @Environment(NavigationStore<AppRoute>.self) var navigation
    
    var body: some View {
        List {
            Button("Go to Profile") {
                navigation.push(.profile(userId: "123"))
            }
            
            Button("Go to Settings") {
                navigation.push(.settings)
            }
            
            Button("Go to Detail") {
                navigation.push(.detail(itemId: 1))
            }
        }
    }
}
```

### 5. 简易用法分析：@Environment 注入

在视图中通过 `@Environment` 获取 Store 是最常用的模式。

```swift
@Environment(NavigationStore<AppRoute>.self) private var store
```

**✅ 优势 (Pros):**
- **解耦视图层级**: 无需从父视图通过构造函数层层传递 `store` 或 `binding`。
- **声明式**: 任意深度的子视图都可以直接获取导航能力。
- **响应式**: 当 Store 状态变化时，依赖它的视图会自动更新（得益于 `@Observable`）。

**⚠️ 注意 (Cons):**
- **隐式依赖**: 这是一个隐式依赖。如果忘记在根视图调用 `.environment(store)`，应用会在运行时 Crash。
- **泛型耦合**: 视图与具体的 `AppRoute` 类型绑定。如果需要编写通用的 UI 组件，建议传入闭包 `() -> Void` 而不是直接依赖 Store。

### 6. Deep Linking

```swift
// 设置完整的导航路径
navigation.replace([.home, .profile(userId: "123"), .settings])

// 或者使用 Action
navigation.dispatch(.replace([.home, .profile(userId: "123")]))
```

## 模态展示 (Present)

除了 push/pop 导航，还支持模态展示（Sheet、FullScreenCover）。

### 使用方式一：独立的 PresentationStore

```swift
@main
struct MyApp: App {
    @State private var navigation = NavigationStore<AppRoute>()
    @State private var presentation = PresentationStore<AppRoute>()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(navigation)
                .environment(presentation)
        }
    }
}

struct ContentView: View {
    @Environment(NavigationStore<AppRoute>.self) var navigation
    @Environment(PresentationStore<AppRoute>.self) var presentation
    
    var body: some View {
        ModernNavigationStack(store: navigation) {
            HomeView()
        }
        .presentation(store: presentation)  // 启用模态展示
    }
}

struct HomeView: View {
    @Environment(PresentationStore<AppRoute>.self) var presentation
    
    var body: some View {
        VStack {
            Button("Show Settings Sheet") {
                presentation.sheet(.settings)
            }
            
            Button("Show Profile Full Screen") {
                presentation.fullScreenCover(.profile(userId: "123"))
            }
            
            Button("Show Half Sheet") {
                presentation.present(.detail(itemId: 1), configuration: .medium)
            }
        }
    }
}
```

### 使用方式二：组合 Router（推荐）

```swift
@main
struct MyApp: App {
    @State private var router = Router<AppRoute>()
    
    var body: some Scene {
        WindowGroup {
            RouterNavigationStack(router: router) {
                HomeView()
            }
        }
    }
}

struct HomeView: View {
    @Environment(Router<AppRoute>.self) var router
    
    var body: some View {
        VStack {
            // 导航
            Button("Push Detail") {
                router.push(.detail(itemId: 1))
            }
            
            // 模态展示
            Button("Show Settings Sheet") {
                router.sheet(.settingsSheet)
            }
            
            Button("Show Full Screen") {
                router.fullScreenCover(.profile(userId: "123"))
            }
        }
    }
}
```

### Sheet 配置

支持自定义 Sheet 的展示配置：

```swift
// 半屏 Sheet
presentation.present(.settings, configuration: .medium)

// 全屏 Sheet
presentation.present(.settings, configuration: .large)

// 可调节高度的 Sheet
presentation.present(.settings, configuration: .flexible)

// 完全自定义
presentation.present(.settings, configuration: SheetConfiguration(
    detents: [.medium, .large],
    dragIndicatorVisibility: .visible,
    interactiveDismissDisabled: true  // 禁止下拉关闭
))
```

### 在模态视图中关闭

```swift
struct SettingsView: View {
    @Environment(PresentationStore<AppRoute>.self) var presentation
    // 或者
    @Environment(Router<AppRoute>.self) var router
    let isModal: Bool
    
    var body: some View {
        List { ... }
            .toolbar {
                if isModal {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            presentation.dismiss()
                            // 或者 router.dismiss()
                        }
                    }
                }
            }
    }
}
```

### 多层模态

支持在模态上面再展示模态：

```swift
// 第一层模态
presentation.sheet(.settings)

// 在 SettingsView 中展示第二层
presentation.sheet(.profile(userId: "123"))

// 关闭当前层
presentation.dismiss()

// 关闭所有模态
presentation.dismissAll()
```

## 高级功能

### Middleware 支持

支持添加中间件处理副作用：

```swift
public protocol NavigationMiddleware {
    associatedtype R: Route
    func process(
        action: NavigationAction<R>,
        state: NavigationState<R>,
        dispatch: @escaping (NavigationAction<R>) -> Void
    ) -> NavigationAction<R>?
}

// 示例：日志中间件
struct LoggingMiddleware<R: Route>: NavigationMiddleware {
    func process(
        action: NavigationAction<R>,
        state: NavigationState<R>,
        dispatch: @escaping (NavigationAction<R>) -> Void
    ) -> NavigationAction<R>? {
        print("📍 Navigation: \(action)")
        print("   Path count: \(state.count) -> \(state.count + (action.isAdditive ? 1 : -1))")
        return action
    }
}
```

### 导航守卫

支持在导航前进行拦截：

```swift
navigationStore.addGuard { action, state in
    // 检查是否需要登录
    if case .profile = action, !isLoggedIn {
        return .replace([.login])
    }
    return action
}
```

### 状态持久化

支持保存和恢复导航状态（需要 Route 实现 Codable）：

```swift
// 保存状态
let data = try navigationStore.encode()

// 恢复状态
try navigationStore.restore(from: data)
```

## API 参考

### NavigationStore

| 方法 | 描述 |
|------|------|
| `dispatch(_:)` | 分发一个导航 Action |
| `push(_:)` | 压入新路由 |
| `pop()` | 弹出当前路由 |
| `popToRoot()` | 返回根视图 |
| `replace(_:)` | 替换整个导航路径 |
| `canPop` | 是否可以返回 |
| `currentRoute` | 当前路由 |
| `path` | 当前路径数组 |

### NavigationAction

| Case | 描述 |
|------|------|
| `.push(Route)` | 压入新路由到栈顶 |
| `.pop` | 弹出栈顶路由 |
| `.popTo(Route)` | 弹出到指定路由 |
| `.popToRoot` | 清空栈返回根视图 |
| `.replace([Route])` | 替换整个路径 |
| `.insert(Route, at: Int)` | 在指定位置插入路由 |
| `.remove(at: Int)` | 移除指定位置的路由 |

### PresentationStore

| 方法 | 描述 |
|------|------|
| `present(_:style:configuration:)` | 展示一个路由 |
| `sheet(_:configuration:)` | 以 Sheet 样式展示 |
| `fullScreenCover(_:)` | 以全屏样式展示 |
| `dismiss()` | 关闭当前模态 |
| `dismissAll()` | 关闭所有模态 |
| `replace(_:style:configuration:)` | 替换当前模态 |
| `isPresenting` | 是否正在展示模态 |
| `currentRoute` | 当前展示的路由 |

### Router（组合路由器）

| 方法 | 描述 |
|------|------|
| `push(_:)` | 压入新路由 |
| `pop()` | 弹出当前路由 |
| `popToRoot()` | 返回根视图 |
| `sheet(_:configuration:)` | 展示 Sheet |
| `fullScreenCover(_:)` | 展示全屏模态 |
| `dismiss()` | 关闭当前模态 |
| `dismissAll()` | 关闭所有模态 |

### SheetConfiguration 预设

| 预设 | 描述 |
|------|------|
| `.default` | 默认配置（大尺寸） |
| `.medium` | 半屏 Sheet |
| `.large` | 全屏 Sheet |
| `.flexible` | 可调节高度（中/大） |

## 系统要求

- iOS 17.0+ / macOS 14.0+ / tvOS 17.0+ / watchOS 10.0+ / visionOS 1.0+
- Swift 6.0+
- Xcode 16.0+

## 安装

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/tangzzz-fan/TGModernNavigation.git", from: "0.0.1")
]
```

## License

MIT License
