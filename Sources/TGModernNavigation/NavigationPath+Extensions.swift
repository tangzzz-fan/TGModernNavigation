import SwiftUI

// MARK: - NavigationPath Extensions

public extension NavigationPath {
    
    /// 从路由数组创建 NavigationPath
    /// - Parameter routes: 路由数组
    /// - Returns: NavigationPath 实例
    static func from<R: Route>(_ routes: [R]) -> NavigationPath {
        var path = NavigationPath()
        for route in routes {
            path.append(route)
        }
        return path
    }
}

// MARK: - Array Extensions for Routes

public extension Array where Element: Route {
    
    /// 转换为 NavigationPath
    var asNavigationPath: NavigationPath {
        NavigationPath.from(self)
    }
}
