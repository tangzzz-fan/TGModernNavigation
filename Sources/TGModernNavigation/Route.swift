import SwiftUI

// MARK: - Route Protocol

/// 定义可导航的路由协议
///
/// 实现此协议的类型可以作为导航目标，每个路由需要提供对应的视图。
///
/// ## 示例
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
public protocol Route: Hashable, Identifiable, Sendable {
    associatedtype Body: View
    
    /// 路由对应的视图
    @MainActor @ViewBuilder var body: Body { get }
}

// MARK: - Default Implementation

public extension Route where Self: Hashable {
    /// 默认使用自身的哈希值作为标识符
    var id: Int {
        hashValue
    }
}

// MARK: - AnyRoute (Type Erasure)

/// 类型擦除的路由包装器
///
/// 用于在需要存储不同类型路由的场景中使用。
@MainActor
public struct AnyRoute: Identifiable, Hashable {
    public let id: Int
    private let _body: () -> AnyView
    private let _hashValue: Int
    
    public init<R: Route>(_ route: R) {
        self.id = route.hashValue
        self._body = { AnyView(route.body) }
        self._hashValue = route.hashValue
    }
    
    public var body: AnyView {
        _body()
    }
    
    nonisolated public static func == (lhs: AnyRoute, rhs: AnyRoute) -> Bool {
        lhs._hashValue == rhs._hashValue
    }
    
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(_hashValue)
    }
}
