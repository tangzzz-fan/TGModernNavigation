import SwiftUI

// MARK: - PresentationAction

/// Modal Presentation Action
public enum PresentationAction<R: Route>: Sendable {
    /// Present a route
    case present(R, style: PresentationStyle, configuration: SheetConfiguration, embedInNavigationStack: Bool)
    
    /// Dismiss the topmost modal
    case dismiss
    
    /// Dismiss all modals
    case dismissAll
    
    /// Dismiss to a specific route
    case dismissTo(R)
    
    /// Replace the currently presented route
    case replace(R, style: PresentationStyle, configuration: SheetConfiguration, embedInNavigationStack: Bool)
}

extension PresentationAction: Equatable where R: Equatable {}
