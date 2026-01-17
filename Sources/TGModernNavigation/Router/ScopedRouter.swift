import SwiftUI

// MARK: - Scoped Router

/// A wrapper view that provides a scoped (independent) Router for modal presentations.
///
/// Use this view when presenting a sheet or fullScreenCover that requires its own
/// independent navigation stack. This ensures that navigation actions within the
/// modal do not affect the parent's navigation stack.
///
/// ## Example
/// ```swift
/// // In your RouteHandler or View
/// .sheet(item: $activeSheet) { route in
///     ScopedRouter(AppRoute.self) {
///         DetailView()
///     }
/// }
/// ```
public struct ScopedRouter<R: Route, Content: View>: View {
    
    /// The independent router instance for this scope
    @State private var router = Router<R>()
    
    /// The content view builder
    private let content: () -> Content
    
    /// Creates a scoped router
    /// - Parameter content: The root view of the new navigation stack
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    /// Creates a scoped router with explicit route type
    /// - Parameters:
    ///   - routeType: The type of the route (for inference)
    ///   - content: The root view
    public init(_ routeType: R.Type, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        RouterNavigationStack(router: router) {
            content()
        }
    }
}
