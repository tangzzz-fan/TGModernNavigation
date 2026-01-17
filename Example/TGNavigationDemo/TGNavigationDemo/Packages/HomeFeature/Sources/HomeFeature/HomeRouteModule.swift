import SwiftUI
import TGModernNavigation
import AppCore
import UIComponents

public struct HomeRouteModule: RouteHandler {
    public init() {}
    public func view(for route: AppRoute) -> AnyView? {
        if case .home = route {
            return AnyView(HomeView())
        }
        return nil
    }
}
