// TGModernNavigation
// A Redux-inspired Modern Navigation library for SwiftUI
//
// Copyright (c) 2026 TG Libraries
// Licensed under MIT License

/// TGModernNavigation 是一个基于 Redux 思想的 SwiftUI 现代导航库。
///
/// ## 核心概念
/// - **Route**: 定义可导航的路由类型
/// - **NavigationState**: 不可变的导航状态
/// - **NavigationAction**: 描述导航意图的动作
/// - **NavigationReducer**: 纯函数，计算新状态
/// - **NavigationStore**: 单一数据源，管理状态
///
/// ## 快速开始
///
/// 1. 定义路由：
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
/// 2. 创建导航存储：
/// ```swift
/// @State private var navigation = NavigationStore<AppRoute>()
/// ```
///
/// 3. 使用 ModernNavigationStack：
/// ```swift
/// ModernNavigationStack(store: navigation) {
///     HomeView()
/// }
/// .environment(navigation)
/// ```
///
/// 4. 在视图中导航：
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
