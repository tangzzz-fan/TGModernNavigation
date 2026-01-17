import SwiftUI
import Observation

// MARK: - PresentationStore

/// Independent Modal Presentation Store
///
/// Manages modal presentation state, works in conjunction with NavigationStore.
@Observable
@MainActor
public final class PresentationStore<R: Route> {
    
    /// Current presentation state
    public private(set) var state: PresentationState<R>
    
    /// Create empty presentation store
    public init() {
        self.state = PresentationState()
    }
    
    /// Create presentation store with initial state
    public init(initialState: PresentationState<R>) {
        self.state = initialState
    }
    
    // MARK: - Dispatch
    
    /// Dispatch a presentation action
    public func dispatch(_ action: PresentationAction<R>) {
        state = PresentationReducer.reduce(state: state, action: action)
    }
    
    // MARK: - Convenience Methods
    
    /// Present a route (Sheet style)
    public func present(
        _ route: R,
        style: PresentationStyle = .sheet,
        configuration: SheetConfiguration = .default,
        embedInNavigationStack: Bool = false
    ) {
        dispatch(.present(route, style: style, configuration: configuration, embedInNavigationStack: embedInNavigationStack))
    }
    
    /// Present as Sheet
    public func sheet(_ route: R, configuration: SheetConfiguration = .default, embedInNavigationStack: Bool = false) {
        present(route, style: .sheet, configuration: configuration, embedInNavigationStack: embedInNavigationStack)
    }
    
    /// Present as Full Screen Cover
    public func fullScreenCover(_ route: R, embedInNavigationStack: Bool = false) {
        present(route, style: .fullScreenCover, configuration: .default, embedInNavigationStack: embedInNavigationStack)
    }
    
    /// Dismiss the current modal
    public func dismiss() {
        dispatch(.dismiss)
    }
    
    /// Dismiss all modals
    public func dismissAll() {
        dispatch(.dismissAll)
    }
    
    /// Dismiss to a specific route
    public func dismissTo(_ route: R) {
        dispatch(.dismissTo(route))
    }
    
    /// Replace the currently presented route
    public func replace(
        _ route: R,
        style: PresentationStyle = .sheet,
        configuration: SheetConfiguration = .default,
        embedInNavigationStack: Bool = false
    ) {
        dispatch(.replace(route, style: style, configuration: configuration, embedInNavigationStack: embedInNavigationStack))
    }
    
    // MARK: - Computed Properties
    
    /// Whether a modal is currently presented
    public var isPresenting: Bool {
        state.isPresenting
    }
    
    /// The currently presented route
    public var currentRoute: R? {
        state.currentRoute
    }
    
    /// Full information of the currently presented item
    public var current: PresentedRoute<R>? {
        state.current
    }
    
    /// Depth of the presentation stack
    public var count: Int {
        state.count
    }
    
    // MARK: - Bindings
    
    /// Sheet Binding
    public var sheetBinding: Binding<PresentedRoute<R>?> {
        Binding(
            get: {
                guard let current = self.state.current,
                      current.style == .sheet else {
                    return nil
                }
                return current
            },
            set: { newValue in
                if newValue == nil && self.state.current?.style == .sheet {
                    self.dismiss()
                }
            }
        )
    }
    
    /// FullScreenCover Binding
    public var fullScreenCoverBinding: Binding<PresentedRoute<R>?> {
        Binding(
            get: {
                guard let current = self.state.current,
                      current.style == .fullScreenCover else {
                    return nil
                }
                return current
            },
            set: { newValue in
                if newValue == nil && self.state.current?.style == .fullScreenCover {
                    self.dismiss()
                }
            }
        )
    }
}

extension PresentationStore: @unchecked Sendable {}
