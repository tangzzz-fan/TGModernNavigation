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
            return AnyView(ScopedRouterView {
                ProfileView(userId: userId, isModal: true)
            })
        case .login:
            return AnyView(LoginView(isModal: false))
        case .loginSheet:
            return AnyView(ScopedRouterView {
                LoginView(isModal: true)
            })
        default:
            return nil
        }
    }
}

/// A wrapper view that provides a scoped Router for modal presentations
private struct ScopedRouterView<Content: View>: View {
    @State private var router = Router<AppRoute>()
    @ViewBuilder let content: Content
    
    var body: some View {
        RouterNavigationStack(router: router) {
            content
        }
    }
}
