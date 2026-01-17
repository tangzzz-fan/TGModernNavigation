import Foundation

// MARK: - DeepLinkHandler

/// Deep Link Handler Protocol
///
/// Implement this protocol to support parsing navigation routes from URLs.
public protocol DeepLinkHandler<RouteType> {
    associatedtype RouteType: Route
    
    /// Parse URL into route path
    /// - Parameter url: The URL to parse
    /// - Returns: An array of routes if parsing succeeds, otherwise nil
    func parse(url: URL) -> [RouteType]?
    
    /// Generate URL from route path
    /// - Parameter routes: The route path
    /// - Returns: The generated URL, or nil if generation is not supported
    func url(for routes: [RouteType]) -> URL?
}

// MARK: - Default Implementation

public extension DeepLinkHandler {
    func url(for routes: [RouteType]) -> URL? {
        // Default does not support URL generation
        nil
    }
}

// MARK: - DeepLinkNavigator

/// Deep Link Navigator
///
/// Encapsulates Deep Link handling logic and integrates with NavigationStore.
@MainActor
public struct DeepLinkNavigator<R: Route, Handler: DeepLinkHandler> where Handler.RouteType == R {
    
    private let store: NavigationStore<R>
    private let handler: Handler
    
    /// Create Deep Link Navigator
    /// - Parameters:
    ///   - store: Navigation store
    ///   - handler: Deep Link handler
    public init(store: NavigationStore<R>, handler: Handler) {
        self.store = store
        self.handler = handler
    }
    
    /// Handle Deep Link URL
    /// - Parameter url: The URL to handle
    /// - Returns: Whether handling was successful
    @discardableResult
    public func handle(url: URL) -> Bool {
        guard let routes = handler.parse(url: url) else {
            return false
        }
        
        store.replace(routes)
        return true
    }
    
    /// Handle Deep Link URL with animation
    /// - Parameters:
    ///   - url: The URL to handle
    ///   - animation: Animation to use
    /// - Returns: Whether handling was successful
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
    
    /// Generate URL for current path
    /// - Returns: URL corresponding to the current path
    public func currentURL() -> URL? {
        handler.url(for: store.path)
    }
}

// MARK: - URL Scheme Handler

/// URL Scheme based Deep Link Handler
///
/// Supports URLs like `myapp://path/to/route`.
public struct URLSchemeHandler<R: Route>: DeepLinkHandler {
    public typealias RouteType = R
    
    private let scheme: String
    private let parser: (URL) -> [R]?
    private let urlBuilder: (([R]) -> URL?)?
    
    /// Create URL Scheme Handler
    /// - Parameters:
    ///   - scheme: URL scheme (e.g., "myapp")
    ///   - parser: URL parser
    ///   - urlBuilder: URL builder (optional)
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

/// Universal Link Handler
///
/// Supports URLs like `https://example.com/path/to/route`.
public struct UniversalLinkHandler<R: Route>: DeepLinkHandler {
    public typealias RouteType = R
    
    private let host: String
    private let parser: (URL) -> [R]?
    private let urlBuilder: (([R]) -> URL?)?
    
    /// Create Universal Link Handler
    /// - Parameters:
    ///   - host: Hostname (e.g., "example.com")
    ///   - parser: URL parser
    ///   - urlBuilder: URL builder (optional)
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
