import SwiftUI
import AuthFeature
import TGModernNavigation
import AppCore

public struct UserRouteModule: RouteHandler {
    public init() {}
    public func view(for route: AppRoute) -> AnyView? {
        switch route {
        case .profile(let userId):
            return AnyView(ProfileView(userId: userId, isModal: false))
        case .profileSheet(let userId):
            return AnyView(ScopedRouter<AppRoute> {
                ProfileView(userId: userId, isModal: true)
            })
        case .login:
            return AnyView(LoginView(isModal: false))
        case .loginSheet:
            return AnyView(ScopedRouter<AppRoute> {
                LoginView(isModal: true)
            })
        default:
            return nil
        }
    }
}
