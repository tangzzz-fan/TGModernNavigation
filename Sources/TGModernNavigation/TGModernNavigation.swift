// TGModernNavigation
// A Redux-inspired Modern Navigation library for SwiftUI
//
// Copyright (c) 2026 TG Libraries
// Licensed under MIT License

/// TGModernNavigation is a modern navigation library for SwiftUI based on Redux principles.
///
/// ## Core Concepts
/// - **Route**: Defines navigable route types
/// - **NavigationState**: Immutable navigation state
/// - **NavigationAction**: Actions describing navigation intent
/// - **NavigationReducer**: Pure function calculating new state
/// - **NavigationStore**: Single source of truth managing state
///
/// ## Quick Start
///
/// 1. Define Routes:
/// ```swift
/// enum AppRoute: Route {
///     case home
///     case profile(userId: String)
///     case settings
///
///     var id: Self { self }
///
///     @ViewBuilder
///     var body: some View {
///         switch self {
///         case .home:
///             HomeView()
///         case .profile(let userId):
///             ProfileView(userId: userId)
///         case .settings:
///             SettingsView()
///         }
///     }
/// }
/// ```
///
/// 2. Create Navigation Store:
/// ```swift
/// @State private var navigation = NavigationStore<AppRoute>()
/// ```
///
/// 3. Use ModernNavigationStack:
/// ```swift
/// ModernNavigationStack(store: navigation) {
///     HomeView()
/// }
/// .environment(navigation)
/// ```
///
/// 4. Navigate in Views:
/// ```swift
/// @Environment(NavigationStore<AppRoute>.self) var navigation
///
/// Button("Go to Profile") {
///     navigation.push(.profile(userId: "123"))
/// }
/// ```

// Re-export all public types
@_exported import SwiftUI

// Version information
public enum TGModernNavigationVersion {
    public static let major = 0
    public static let minor = 0
    public static let patch = 1
    public static let string = "\(major).\(minor).\(patch)"
}
