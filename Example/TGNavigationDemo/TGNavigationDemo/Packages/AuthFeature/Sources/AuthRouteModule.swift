import SwiftUI
import TGModernNavigation
import AppCore

public struct AuthRouteModule: RouteHandler {
    public init() {}
    public func view(for route: AppRoute) -> AnyView? {
        switch route {
        case .login:
            return AnyView(LoginView(isModal: false))
        case .loginSheet:
            return AnyView(NavigationStack {
                LoginView(isModal: true)
            })
        default:
            return nil
        }
    }
}
