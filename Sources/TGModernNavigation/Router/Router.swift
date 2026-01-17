import SwiftUI
import Observation

// MARK: - Combined Router

/// Combined Router (Navigation Coordinator)
///
/// The `Router` acts as the **Agent** (Service) that manages navigation.
/// It wraps both `NavigationStore` (Stack) and `PresentationStore` (Modal) into a single unified API.
///
/// - Note: Do not confuse `Router` (The Manager) with `Route` (The Destination Data).
@Observable
@MainActor
public final class Router<R: Route> {
    
    /// Navigation store
    public let navigation: NavigationStore<R>
    
    /// Presentation store
    public let presentation: PresentationStore<R>
    
    /// Create combined router
    public init() {
        self.navigation = NavigationStore()
        self.presentation = PresentationStore()
    }
    
    /// Create combined router with existing stores
    public init(
        navigation: NavigationStore<R>,
        presentation: PresentationStore<R>
    ) {
        self.navigation = navigation
        self.presentation = presentation
    }
    
    // MARK: - Navigation Shortcuts
    
    /// Push a new route
    public func push(_ route: R) {
        navigation.push(route)
    }
    
    /// Pop the current route
    public func pop() {
        navigation.pop()
    }
    
    /// Pop to root view
    public func popToRoot() {
        navigation.popToRoot()
    }
    
    /// Pop to a specific route
    public func popTo(_ route: R) {
        navigation.dispatch(.popTo(route))
    }
    
    // MARK: - Presentation Shortcuts
    
    /// Present as Sheet
    public func sheet(_ route: R, configuration: SheetConfiguration = .default, embedInNavigationStack: Bool = false) {
        presentation.sheet(route, configuration: configuration, embedInNavigationStack: embedInNavigationStack)
    }
    
    /// Present as Full Screen Cover
    public func fullScreenCover(_ route: R, embedInNavigationStack: Bool = false) {
        presentation.fullScreenCover(route, embedInNavigationStack: embedInNavigationStack)
    }
    
    /// Dismiss the current modal
    public func dismiss() {
        presentation.dismiss()
    }
    
    /// Dismiss all modals
    public func dismissAll() {
        presentation.dismissAll()
    }
}

extension Router: @unchecked Sendable {}

// MARK: - Router Navigation Stack

/// Full navigation stack supporting both navigation and presentation
public struct RouterNavigationStack<R: Route, Root: View>: View {
    
    @Bindable private var router: Router<R>
    @Bindable private var navigationStore: NavigationStore<R>
    private let root: () -> Root
    
    public init(
        router: Router<R>,
        @ViewBuilder root: @escaping () -> Root
    ) {
        self.router = router
        self.navigationStore = router.navigation
        self.root = root
    }
    
    public var body: some View {
        NavigationStack(path: $navigationStore.navigationPath) {
            root()
            .navigationDestination(for: R.self) { route in
                route.body
            }
        }
        .presentation(store: router.presentation)
        .environment(router)
    }
}
