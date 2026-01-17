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
            return AnyView(DetailView(id: id, isModal: true))
        default:
            return nil
        }
    }
}
