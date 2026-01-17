import SwiftUI

// MARK: - Presentation View Modifier

/// Modal Presentation View Modifier
public struct PresentationModifier<R: Route>: ViewModifier {
    
    @Bindable var store: PresentationStore<R>
    
    public init(store: PresentationStore<R>) {
        self.store = store
    }
    
    public func body(content: Content) -> some View {
        content
            .sheet(item: store.sheetBinding) { presented in
                presented.route.body
                    .presentationDetents(presented.configuration.detents)
                    .presentationDragIndicator(presented.configuration.dragIndicatorVisibility)
                    .interactiveDismissDisabled(presented.configuration.interactiveDismissDisabled)
                    .environment(store)
            }
            #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
            .fullScreenCover(item: store.fullScreenCoverBinding) { presented in
                presented.route.body
                    .environment(store)
            }
            #endif
    }
}

// MARK: - View Extension

public extension View {
    
    /// Enable modal presentation support
    /// - Parameter store: Presentation store
    /// - Returns: Modified view
    @MainActor
    func presentation<R: Route>(store: PresentationStore<R>) -> some View {
        self.modifier(PresentationModifier(store: store))
    }
}
