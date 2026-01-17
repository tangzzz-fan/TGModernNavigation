import SwiftUI
import TGModernNavigation
import AppCore
import UIComponents
import HomeFeature
import NavigationFeature
import SettingsFeature

// MARK: - Main Tab View

/// 主界面 Tab 架构
///
/// 展示了如何在大型项目中通过多 Tab + 独立 NavigationStack 实现模块解耦。
/// 每个 Tab 拥有自己独立的 `Router` 实例，互不干扰。
///
/// **解耦分析：**
/// 1. **状态解耦**：每个 Tab 持有独立的 `Router` 和 `NavigationPath`。在 Tab A 进行 Push/Pop 操作不会影响 Tab B 的状态。
/// 2. **路由解耦**：(进阶) 在真实的大型项目中，可以将 `AppRoute` 拆分为 `HomeRoute`, `SettingsRoute` 等独立的枚举，
///    每个 Tab 只关注自己的路由集合。这里为了演示方便，统一使用了 `AppRoute`，但原理相同。
struct MainTabView: View {
    
    // MARK: - Independent Routers
    
    // 为每个 Tab 创建独立的 Router 实例
    // 这样每个 Tab 都有独立的导航栈状态
    @State private var homeRouter = Router<AppRoute>()
    @State private var featuresRouter = Router<AppRoute>()
    @State private var settingsRouter = Router<AppRoute>()
    
    var body: some View {
        TabView {
            // Tab 1: Home
            // 首页模块，包含基础导航入口
            RouterNavigationStack(router: homeRouter) {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            
            // Tab 2: Features
            // 功能演示模块，展示各种导航和 Presentation 能力
            RouterNavigationStack(router: featuresRouter) {
                // 这里我们将 PresentationDemoView 作为这个 Tab 的根视图
                PresentationDemoView()
            }
            .tabItem {
                Label("Demos", systemImage: "sparkles.rectangle.stack.fill")
            }
            
            // Tab 3: Settings
            // 设置模块
            RouterNavigationStack(router: settingsRouter) {
                SettingsView(isModal: false)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(.indigo)
    }
}

#Preview {
    MainTabView()
}
