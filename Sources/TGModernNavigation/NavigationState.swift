import SwiftUI

// MARK: - NavigationState

/// 导航状态结构
///
/// 存储当前的导航路径，是不可变的值类型。
/// 遵循 Redux 的单一数据源原则。
public struct NavigationState<R: Route>: Equatable, Sendable {
    
    /// 当前的导航路径
    public private(set) var path: [R]
    
    /// 创建空的导航状态
    public init() {
        self.path = []
    }
    
    /// 使用初始路径创建导航状态
    /// - Parameter path: 初始导航路径
    public init(path: [R]) {
        self.path = path
    }
    
    // MARK: - Computed Properties
    
    /// 导航栈是否为空
    public var isEmpty: Bool {
        path.isEmpty
    }
    
    /// 导航栈中的路由数量
    public var count: Int {
        path.count
    }
    
    /// 当前路由（栈顶）
    public var currentRoute: R? {
        path.last
    }
    
    /// 是否可以返回上一页
    public var canPop: Bool {
        !path.isEmpty
    }
    
    /// 获取指定索引的路由
    /// - Parameter index: 索引
    /// - Returns: 对应的路由，如果索引无效则返回 nil
    public subscript(index: Int) -> R? {
        guard index >= 0 && index < path.count else { return nil }
        return path[index]
    }
    
    // MARK: - Internal Mutations
    
    /// 压入新路由（内部使用）
    mutating func push(_ route: R) {
        path.append(route)
    }
    
    /// 弹出栈顶路由（内部使用）
    @discardableResult
    mutating func pop() -> R? {
        guard !path.isEmpty else { return nil }
        return path.removeLast()
    }
    
    /// 弹出到指定路由（内部使用）
    /// - Parameter route: 目标路由
    /// - Returns: 是否成功找到并弹出到目标路由
    @discardableResult
    mutating func popTo(_ route: R) -> Bool {
        guard let index = path.lastIndex(of: route) else { return false }
        path = Array(path.prefix(through: index))
        return true
    }
    
    /// 弹出到根视图（内部使用）
    mutating func popToRoot() {
        path.removeAll()
    }
    
    /// 弹出指定数量的路由（内部使用）
    /// - Parameter count: 要弹出的数量
    mutating func pop(count: Int) {
        let removeCount = min(count, path.count)
        path.removeLast(removeCount)
    }
    
    /// 替换整个路径（内部使用）
    mutating func replace(with newPath: [R]) {
        path = newPath
    }
    
    /// 在指定位置插入路由（内部使用）
    mutating func insert(_ route: R, at index: Int) {
        let safeIndex = max(0, min(index, path.count))
        path.insert(route, at: safeIndex)
    }
    
    /// 移除指定位置的路由（内部使用）
    @discardableResult
    mutating func remove(at index: Int) -> R? {
        guard index >= 0 && index < path.count else { return nil }
        return path.remove(at: index)
    }
}

// MARK: - CustomStringConvertible

extension NavigationState: CustomStringConvertible {
    public var description: String {
        "NavigationState(count: \(count), path: \(path))"
    }
}

// MARK: - CustomDebugStringConvertible

extension NavigationState: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        NavigationState {
            count: \(count)
            isEmpty: \(isEmpty)
            canPop: \(canPop)
            currentRoute: \(String(describing: currentRoute))
            path: \(path)
        }
        """
    }
}
