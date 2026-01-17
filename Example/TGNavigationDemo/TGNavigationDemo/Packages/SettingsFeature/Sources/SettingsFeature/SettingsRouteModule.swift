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
            return AnyView(ScopedRouter<AppRoute> {
                SettingsView(isModal: true)
            })
        default:
            return nil
        }
    }
}
