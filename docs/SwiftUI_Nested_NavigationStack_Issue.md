# SwiftUI 嵌套 NavigationStack 问题分析与解决方案

## 问题背景

在 SwiftUI 中，`NavigationStack` 是管理导航状态的核心组件。然而，当我们在一个已经是 `NavigationStack` 的子视图中再次包裹一个 `NavigationStack` 时，会产生**嵌套 NavigationStack (Nested NavigationStack)** 问题。

### 典型场景

在我们的 `TGNavigationDemo` 项目中，最初的路由设计如下：

```swift
enum AppRoute: Route {
    case settings
    
    var body: some View {
        switch self {
        case .settings:
            NavigationStack {  // 错误：这里包裹了 NavigationStack
                SettingsView()
            }
        }
    }
}
```

当我们在主页（已经在根 `NavigationStack` 中）调用 `router.push(.settings)` 时，导航栈结构变成了：

```
Root NavigationStack
  └── HomeView
      └── NavigationStack (Nested)
          └── SettingsView
```

### 症状

1.  **Path 绑定丢失**：外层 `NavigationStack` 的 `path` 绑定可能无法正确感知内层栈的变化。
2.  **意外的 PopToRoot**：在某些情况下（如内层视图尝试再次 Push），会导致整个导航栈重置，直接跳回根视图。
3.  **导航栏双重显示或错乱**：可能会看到两个 Navigation Bar，或者标题显示异常。
4.  **手势失效**：侧滑返回手势可能与内层栈冲突。

## 根本原因

SwiftUI 的 `NavigationStack` 设计意图是**管理一整条导航路径**。当嵌套使用时，SwiftUI 无法确定当前的导航操作（Push/Pop）应该由哪一个栈来处理，导致状态管理混乱。

特别是在结合 `TGModernNavigation` 这样的路由库时，我们通常希望通过单一的 `Router` 对象和单一的 `Path` 来管理全局导航。嵌套的 `NavigationStack` 会破坏这种单一事实来源（Single Source of Truth）。

## 解决方案：分离 Push 和 Sheet 逻辑

为了解决这个问题，我们需要遵循一个核心原则：**Push 页面不应包含 NavigationStack，只有模态（Sheet/FullScreenCover）弹出的页面才需要包裹在新的 NavigationStack 中。**

### 1. 视图层改造

首先，移除各个视图（如 `SettingsView`, `ProfileView`, `LoginView`）内部或 Preview 之外的 `NavigationStack`。让视图本身保持纯净，只关心内容。

同时，为了适配不同的导航模式（Push vs Sheet），我们引入 `isModal` 状态：

```swift
struct SettingsView: View {
    var isModal: Bool = false // 默认为 false (Push 模式)
    
    var body: some View {
        List { ... }
        .toolbar {
            // 只有在模态弹出时才显示关闭按钮
            if isModal {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { router.dismiss() }
                }
            }
        }
    }
}
```

### 2. 路由层改造 (AppRoute)

我们在 `AppRoute` 中明确区分 **Push 路由** 和 **Sheet 路由**。

-   **Push 路由**：直接返回视图，**不**包裹 `NavigationStack`。
-   **Sheet 路由**：包裹 `NavigationStack`，并设置 `isModal: true`。

```swift
enum AppRoute: Route {
    // 原始路由（用于 Push）
    case settings
    case profile(userId: String)
    case login
    
    // Sheet 专用路由
    case settingsSheet
    case profileSheet(userId: String)
    case loginSheet
    
    var body: some View {
        switch self {
        case .settings:
            // Push 模式：无 NavigationStack，isModal = false
            SettingsView(isModal: false)
            
        case .settingsSheet:
            // Sheet 模式：包裹 NavigationStack，isModal = true
            NavigationStack {
                SettingsView(isModal: true)
            }
            
        case .profile(let userId):
            ProfileView(userId: userId, isModal: false)
            
        case .profileSheet(let userId):
            NavigationStack {
                ProfileView(userId: userId, isModal: true)
            }
            
        case .login:
            LoginView(isModal: false)
            
        case .loginSheet:
            NavigationStack {
                LoginView(isModal: true)
            }
        }
    }
}
```

### 3. 调用方改造

在调用导航时，根据意图选择正确的路由：

-   **Push 跳转**：
    ```swift
    router.push(.settings)
    ```
    
-   **模态弹出**：
    ```swift
    router.sheet(.settingsSheet)
    ```

### 5. Navigation Guard 适配

在拦截器中，我们也需要根据上下文返回正确的路由。例如，拦截 Push 请求并跳转到登录页时，应该使用 Push 路由，以保持导航体验的一致性（用户可以使用 Back 按钮返回）。

```swift
// NavigationGuardView.swift
if !isLoggedIn {
    // Redirect to login (Push 模式)
    return .push(.login)
}
```

此时，`LoginView(isModal: false)` 被推入栈中，左上角不会显示 "Cancel" 按钮，而是显示系统的 "< Back"，逻辑自然且流畅。

### 6. 关于 Dismiss 的重要说明 (Critical)

引入 `ScopedRouter` 后，模态窗口拥有了独立的 Router 实例。这意味着：

1.  **`router.dismiss()` 的作用域改变**：
    在 `ScopedRouter` 内部调用 `router.dismiss()`，它只会尝试关闭**由这个新 Router** 弹出的子模态窗口。如果当前 Sheet 没有再弹出其他 Sheet，调用它没有任何效果。

2.  **如何关闭当前 Sheet**：
    必须使用 SwiftUI 原生的 `@Environment(\.dismiss)`。

```swift
struct SettingsView: View {
    // 获取环境中的 dismiss 动作
    @Environment(\.dismiss) private var dismiss
    @Environment(Router<AppRoute>.self) private var router
    
    var body: some View {
        Button("Close") {
            // ✅ 正确：关闭当前 Sheet
            dismiss()
        }
        
        Button("Dismiss Child") {
            // ✅ 正确：关闭由 SettingsView 弹出的下一层 Sheet
            router.dismiss()
        }
    }
}
```

## 总结

通过区分 **Push 路由** 和 **Sheet 路由**，我们成功解决了嵌套 `NavigationStack` 带来的问题：

1.  **消除嵌套**：导航栈结构清晰，永远只有一层（Push）或分离的层（Sheet）。
2.  **交互一致**：Push 页面使用 Back 按钮，Sheet 页面使用 Close/Cancel 按钮。
3.  **代码复用**：核心视图逻辑复用，仅通过 `isModal` 控制差异化 UI。
4.  **状态安全**：Path 绑定不再丢失，导航行为可预测。
