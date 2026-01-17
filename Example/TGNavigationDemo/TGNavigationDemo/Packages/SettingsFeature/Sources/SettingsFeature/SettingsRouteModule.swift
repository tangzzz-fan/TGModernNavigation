import SwiftUI
import TGModernNavigation
import AppCore

public struct SettingsRouteModule: RouteHandler {
    public init() {}
    public func view(for route: AppRoute) -> AnyView? {
        switch route {
        case .settings:
            return AnyView(SettingsView(isModal: false))
        case .settingsSheet:
            return AnyView(ScopedRouterView {
                SettingsView(isModal: true)
            })
        default:
            return nil
        }
    }
}

private struct ScopedRouterView<Content: View>: View {
    @State private var router = Router<AppRoute>()
    @ViewBuilder let content: Content
    
    var body: some View {
        RouterNavigationStack(router: router) {
            content
        }
    }
}
