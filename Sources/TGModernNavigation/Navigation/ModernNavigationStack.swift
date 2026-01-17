import SwiftUI

// MARK: - ModernNavigationStack

/// Modern Navigation Stack View
///
/// Encapsulates SwiftUI's NavigationStack, integrates with NavigationStore,
/// and provides a declarative navigation experience based on Redux principles.
///
/// ## Example
/// ```swift
/// struct ContentView: View {
///     @State private var navigation = NavigationStore<AppRoute>()
///
///     var body: some View {
///         ModernNavigationStack(store: navigation) {
///             HomeView()
///         }
///     }
/// }
/// ```
public struct ModernNavigationStack<R: Route, Root: View>: View {
    
    @Bindable private var store: NavigationStore<R>
    private let root: () -> Root
    
    /// Creates a modern navigation stack
    /// - Parameters:
    ///   - store: Navigation state storage
    ///   - root: Root view builder
    public init(
        store: NavigationStore<R>,
        @ViewBuilder root: @escaping () -> Root
    ) {
        self.store = store
        self.root = root
    }
    
    public var body: some View {
        NavigationStack(path: $store.navigationPath) {
            root()
                .navigationDestination(for: R.self) { route in
                    route.body
                }
        }
    }
}

// MARK: - ModernNavigationLink

/// Modern Navigation Link
///
/// Provides a declarative way to trigger navigation, automatically integrating with NavigationStore.
public struct ModernNavigationLink<R: Route, Label: View>: View {
    
    @Environment(NavigationStore<R>.self) private var store
    
    private let route: R
    private let label: () -> Label
    
    /// Creates a navigation link
    /// - Parameters:
    ///   - route: Target route
    ///   - label: Label view builder
    public init(
        to route: R,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.route = route
        self.label = label
    }
    
    public var body: some View {
        Button {
            store.push(route)
        } label: {
            label()
        }
    }
}

// MARK: - Convenience Initializers

public extension ModernNavigationLink where Label == Text {
    
    /// Creates a navigation link with a text label
    /// - Parameters:
    ///   - title: Title
    ///   - route: Target route
    init(_ title: String, to route: R) {
        self.route = route
        self.label = { Text(title) }
    }
    
    /// Creates a navigation link with a localized text label
    /// - Parameters:
    ///   - titleKey: Localized title key
    ///   - route: Target route
    init(_ titleKey: LocalizedStringKey, to route: R) {
        self.route = route
        self.label = { Text(titleKey) }
    }
}

// MARK: - Navigation Modifiers

public extension View {
    
    /// Adds a navigation back button
    /// - Parameters:
    ///   - store: Navigation store
    ///   - isPresented: Whether to show
    /// - Returns: Modified view
    @MainActor
    func navigationBackButton<R: Route>(
        store: NavigationStore<R>,
        isPresented: Bool = true
    ) -> some View {
        self.toolbar {
            if isPresented && store.canPop {
                ToolbarItem(placement: .navigation) {
                    Button {
                        store.pop()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
    }
    
    /// Observes route changes
    /// - Parameters:
    ///   - store: Navigation store
    ///   - action: Callback when changed
    /// - Returns: Modified view
    @MainActor
    func onNavigationChange<R: Route>(
        store: NavigationStore<R>,
        perform action: @escaping ([R]) -> Void
    ) -> some View {
        self.onChange(of: store.path) { _, newPath in
            action(newPath)
        }
    }
}

// MARK: - Pop Gesture Modifier

/// Modifier to support swipe back gesture
public struct PopGestureModifier<R: Route>: ViewModifier {
    
    @Bindable var store: NavigationStore<R>
    let isEnabled: Bool
    
    public func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if isEnabled &&
                            store.canPop &&
                            value.translation.width > 100 &&
                            abs(value.translation.height) < 50 {
                            store.pop()
                        }
                    }
            )
    }
}

public extension View {
    
    /// Enables swipe back gesture
    /// - Parameters:
    ///   - store: Navigation store
    ///   - isEnabled: Whether enabled
    /// - Returns: Modified view
    @MainActor
    func popGestureEnabled<R: Route>(
        store: NavigationStore<R>,
        isEnabled: Bool = true
    ) -> some View {
        self.modifier(PopGestureModifier(store: store, isEnabled: isEnabled))
    }
}

// MARK: - Router View

/// Router View Wrapper
///
/// Automatically renders the view corresponding to the current route.
public struct RouterView<R: Route>: View {
    
    @Environment(NavigationStore<R>.self) private var store
    private let fallback: AnyView
    
    /// Creates a router view
    /// - Parameter fallback: View to show when there is no current route
    public init<Fallback: View>(@ViewBuilder fallback: () -> Fallback) {
        self.fallback = AnyView(fallback())
    }
    
    public var body: some View {
        if let route = store.currentRoute {
            route.body
        } else {
            fallback
        }
    }
}
