import Foundation

// MARK: - DeepLinkHandler

/// Deep Link 处理协议
///
/// 实现此协议以支持从 URL 解析导航路由。
public protocol DeepLinkHandler<RouteType> {
    associatedtype RouteType: Route
    
    /// 解析 URL 为路由路径
    /// - Parameter url: 要解析的 URL
    /// - Returns: 解析出的路由数组，如果无法解析则返回 nil
    func parse(url: URL) -> [RouteType]?
    
    /// 从路由路径生成 URL
    /// - Parameter routes: 路由路径
    /// - Returns: 生成的 URL，如果无法生成则返回 nil
    func url(for routes: [RouteType]) -> URL?
}

// MARK: - Default Implementation

public extension DeepLinkHandler {
    func url(for routes: [RouteType]) -> URL? {
        // 默认不支持生成 URL
        nil
    }
}

// MARK: - DeepLinkNavigator

/// Deep Link 导航器
///
/// 封装 Deep Link 处理逻辑，与 NavigationStore 集成。
@MainActor
public struct DeepLinkNavigator<R: Route, Handler: DeepLinkHandler> where Handler.RouteType == R {
    
    private let store: NavigationStore<R>
    private let handler: Handler
    
    /// 创建 Deep Link 导航器
    /// - Parameters:
    ///   - store: 导航存储
    ///   - handler: Deep Link 处理器
    public init(store: NavigationStore<R>, handler: Handler) {
        self.store = store
        self.handler = handler
    }
    
    /// 处理 Deep Link URL
    /// - Parameter url: 要处理的 URL
    /// - Returns: 是否成功处理
    @discardableResult
    public func handle(url: URL) -> Bool {
        guard let routes = handler.parse(url: url) else {
            return false
        }
        
        store.replace(routes)
        return true
    }
    
    /// 处理 Deep Link URL，并使用动画
    /// - Parameters:
    ///   - url: 要处理的 URL
    ///   - animation: 动画
    /// - Returns: 是否成功处理
    @discardableResult
    public func handle(url: URL, animation: Animation?) -> Bool {
        guard let routes = handler.parse(url: url) else {
            return false
        }
        
        if let animation {
            withAnimation(animation) {
                store.replace(routes)
            }
        } else {
            store.replace(routes)
        }
        
        return true
    }
    
    /// 生成当前路径的 URL
    /// - Returns: 当前路径对应的 URL
    public func currentURL() -> URL? {
        handler.url(for: store.path)
    }
}

// MARK: - URL Scheme Handler

/// 基于 URL Scheme 的 Deep Link 处理器
///
/// 支持形如 `myapp://path/to/route` 的 URL。
public struct URLSchemeHandler<R: Route>: DeepLinkHandler {
    public typealias RouteType = R
    
    private let scheme: String
    private let parser: (URL) -> [R]?
    private let urlBuilder: (([R]) -> URL?)?
    
    /// 创建 URL Scheme 处理器
    /// - Parameters:
    ///   - scheme: URL scheme (例如 "myapp")
    ///   - parser: URL 解析器
    ///   - urlBuilder: URL 构建器（可选）
    public init(
        scheme: String,
        parser: @escaping (URL) -> [R]?,
        urlBuilder: (([R]) -> URL?)? = nil
    ) {
        self.scheme = scheme
        self.parser = parser
        self.urlBuilder = urlBuilder
    }
    
    public func parse(url: URL) -> [R]? {
        guard url.scheme == scheme else {
            return nil
        }
        return parser(url)
    }
    
    public func url(for routes: [R]) -> URL? {
        urlBuilder?(routes)
    }
}

// MARK: - Universal Link Handler

/// 通用链接处理器
///
/// 支持形如 `https://example.com/path/to/route` 的 URL。
public struct UniversalLinkHandler<R: Route>: DeepLinkHandler {
    public typealias RouteType = R
    
    private let host: String
    private let parser: (URL) -> [R]?
    private let urlBuilder: (([R]) -> URL?)?
    
    /// 创建通用链接处理器
    /// - Parameters:
    ///   - host: 主机名 (例如 "example.com")
    ///   - parser: URL 解析器
    ///   - urlBuilder: URL 构建器（可选）
    public init(
        host: String,
        parser: @escaping (URL) -> [R]?,
        urlBuilder: (([R]) -> URL?)? = nil
    ) {
        self.host = host
        self.parser = parser
        self.urlBuilder = urlBuilder
    }
    
    public func parse(url: URL) -> [R]? {
        guard url.host == host else {
            return nil
        }
        return parser(url)
    }
    
    public func url(for routes: [R]) -> URL? {
        urlBuilder?(routes)
    }
}
