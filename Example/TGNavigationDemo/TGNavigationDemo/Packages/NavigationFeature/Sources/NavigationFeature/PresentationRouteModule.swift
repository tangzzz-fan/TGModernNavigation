import SwiftUI
import TGModernNavigation
import AppCore

public struct PresentationRouteModule: RouteHandler {
    public init() {}
    public func view(for route: AppRoute) -> AnyView? {
        switch route {
        case .presentationDemo:
            return AnyView(PresentationDemoView())
        case .sheetDemo:
            return AnyView(SheetDemoView())
        case .fullScreenDemo:
            return AnyView(FullScreenDemoView())
        case .multiLayerPresentation:
            return AnyView(MultiLayerPresentationView())
        default:
            return nil
        }
    }
}
