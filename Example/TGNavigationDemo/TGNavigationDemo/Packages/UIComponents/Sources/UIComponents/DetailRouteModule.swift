import SwiftUI
import TGModernNavigation
import AppCore

public struct DetailRouteModule: RouteHandler {
    public init() {}
    public func view(for route: AppRoute) -> AnyView? {
        switch route {
        case .detail(let id):
            return AnyView(DetailView(id: id, isModal: false))
        case .detailSheet(let id):
            return AnyView(ScopedRouterView {
                DetailView(id: id, isModal: true)
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
