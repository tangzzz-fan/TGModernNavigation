import SwiftUI
import TGModernNavigation

// MARK: - App Route

/// 示例应用的路由定义
public enum AppRoute: Route, CaseIterable {
    // 主页
    case home
    
    // 导航示例
    case navigationDemo
    case basicNavigation
    case deepNavigation
    case navigationGuard
    
    // 展示示例
    case presentationDemo
    case sheetDemo
    case fullScreenDemo
    case multiLayerPresentation
    
    // 详情页
    case detail(id: Int)
    case detailSheet(id: Int)
    case profile(userId: String)
    case profileSheet(userId: String)
    case settings
    case settingsSheet
    
    // 登录
    case login
    case loginSheet
    
    public var id: String {
        switch self {
        case .home: return "home"
        case .navigationDemo: return "navigationDemo"
        case .basicNavigation: return "basicNavigation"
        case .deepNavigation: return "deepNavigation"
        case .navigationGuard: return "navigationGuard"
        case .presentationDemo: return "presentationDemo"
        case .sheetDemo: return "sheetDemo"
        case .fullScreenDemo: return "fullScreenDemo"
        case .multiLayerPresentation: return "multiLayerPresentation"
        case .detail(let id): return "detail-\(id)"
        case .detailSheet(let id): return "detail-sheet-\(id)"
        case .profile(let userId): return "profile-\(userId)"
        case .profileSheet(let userId): return "profile-sheet-\(userId)"
        case .settings: return "settings"
        case .settingsSheet: return "settings-sheet"
        case .login: return "login"
        case .loginSheet: return "login-sheet"
        }
    }
    
    @MainActor
    @ViewBuilder
    public var body: some View {
        RouteRegistry<AppRoute>.shared.view(for: self)
    }
}

// MARK: - Registry Extension
extension RouteRegistry where R == AppRoute {
    @MainActor
    public static let shared = RouteRegistry<AppRoute>()
}

extension AppRoute {
    public var title: String {
        switch self {
        case .home: return "Home"
        case .navigationDemo: return "Navigation Demo"
        case .basicNavigation: return "Basic Navigation"
        case .deepNavigation: return "Deep Navigation"
        case .navigationGuard: return "Navigation Guard"
        case .presentationDemo: return "Presentation Demo"
        case .sheetDemo: return "Sheet Demo"
        case .fullScreenDemo: return "Full Screen Demo"
        case .multiLayerPresentation: return "Multi-Layer"
        case .detail(let id): return "Detail #\(id)"
        case .detailSheet(let id): return "Detail #\(id)"
        case .profile(let userId): return "Profile: \(userId)"
        case .profileSheet(let userId): return "Profile: \(userId)"
        case .settings: return "Settings"
        case .settingsSheet: return "Settings"
        case .login: return "Login"
        case .loginSheet: return "Login"
        }
    }
    
    public var icon: String {
        switch self {
        case .home: return "house.fill"
        case .navigationDemo: return "arrow.right.circle.fill"
        case .basicNavigation: return "arrow.right"
        case .deepNavigation: return "arrow.down.right"
        case .navigationGuard: return "shield.fill"
        case .presentationDemo: return "rectangle.portrait.bottomhalf.inset.filled"
        case .sheetDemo: return "rectangle.bottomhalf.inset.filled"
        case .fullScreenDemo: return "rectangle.inset.filled"
        case .multiLayerPresentation: return "square.stack.3d.up.fill"
        case .detail: return "doc.text.fill"
        case .detailSheet: return "doc.text.fill"
        case .profile: return "person.circle.fill"
        case .profileSheet: return "person.circle.fill"
        case .settings: return "gearshape.fill"
        case .settingsSheet: return "gearshape.fill"
        case .login: return "person.badge.key.fill"
        case .loginSheet: return "person.badge.key.fill"
        }
    }
    
    public static var allCases: [AppRoute] {
        [.home, .navigationDemo, .basicNavigation, .deepNavigation, .navigationGuard,
         .presentationDemo, .sheetDemo, .fullScreenDemo, .multiLayerPresentation,
         .detail(id: 0), .detailSheet(id: 0), .profile(userId: ""), .profileSheet(userId: ""),
            .settings, .settingsSheet, .login, .loginSheet]
    }
}
