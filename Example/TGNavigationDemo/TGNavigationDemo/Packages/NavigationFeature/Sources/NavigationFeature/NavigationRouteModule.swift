import SwiftUI
import TGModernNavigation
import AppCore

public struct NavigationRouteModule: RouteHandler {
    public init() {}
    public func view(for route: AppRoute) -> AnyView? {
        switch route {
        case .navigationDemo:
            return AnyView(NavigationDemoView())
        case .basicNavigation:
            return AnyView(BasicNavigationView())
        case .deepNavigation:
            return AnyView(DeepNavigationView())
        case .navigationGuard:
            return AnyView(NavigationGuardView())
        default:
            return nil
        }
    }
}
