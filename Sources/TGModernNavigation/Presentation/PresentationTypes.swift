import SwiftUI

// MARK: - PresentationStyle

/// Modal Presentation Style
public enum PresentationStyle: Sendable, Equatable, Hashable {
    /// Sheet style (iOS default half-screen/pull-to-dismiss)
    case sheet
    
    /// Full screen cover style (iOS/tvOS/watchOS/visionOS only)
    case fullScreenCover
}

// MARK: - SheetConfiguration

/// Sheet Presentation Configuration
public struct SheetConfiguration: Sendable, Equatable {
    public var detents: Set<PresentationDetent>
    public var dragIndicatorVisibility: Visibility
    public var interactiveDismissDisabled: Bool
    
    public init(
        detents: Set<PresentationDetent> = [.large],
        dragIndicatorVisibility: Visibility = .automatic,
        interactiveDismissDisabled: Bool = false
    ) {
        self.detents = detents
        self.dragIndicatorVisibility = dragIndicatorVisibility
        self.interactiveDismissDisabled = interactiveDismissDisabled
    }
    
    public static let `default` = SheetConfiguration()
    
    /// Medium height sheet
    public static let medium = SheetConfiguration(detents: [.medium])
    
    /// Large height sheet
    public static let large = SheetConfiguration(detents: [.large])
    
    /// Flexible height sheet
    public static let flexible = SheetConfiguration(detents: [.medium, .large])
}

// MARK: - PresentedRoute

/// Wrapper for presented routes
public struct PresentedRoute<R: Route>: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let route: R
    public let style: PresentationStyle
    public let configuration: SheetConfiguration
    public let embedInNavigationStack: Bool
    
    public init(
        route: R,
        style: PresentationStyle = .sheet,
        configuration: SheetConfiguration = .default,
        embedInNavigationStack: Bool = true
    ) {
        self.id = UUID()
        self.route = route
        self.style = style
        self.configuration = configuration
        self.embedInNavigationStack = embedInNavigationStack
    }
    
    public static func == (lhs: PresentedRoute<R>, rhs: PresentedRoute<R>) -> Bool {
        lhs.id == rhs.id && 
        lhs.route == rhs.route && 
        lhs.style == rhs.style &&
        lhs.embedInNavigationStack == rhs.embedInNavigationStack
    }
}
