import SwiftUI

// MARK: - NavigationPath Extensions

public extension NavigationPath {
    
    /// Create NavigationPath from an array of routes
    /// - Parameter routes: The array of routes
    /// - Returns: A NavigationPath instance
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
    
    /// Convert to NavigationPath
    var asNavigationPath: NavigationPath {
        NavigationPath.from(self)
    }
}
