import Foundation

// MARK: - NavigationAction

/// 导航动作枚举
///
/// 定义所有可能的导航操作，遵循 Redux 的 Action 模式。
/// 每个 Action 描述一个导航意图，由 Reducer 处理并产生新的状态。
public enum NavigationAction<R: Route>: Sendable {
    
    /// 压入新路由到栈顶
    case push(R)
    
    /// 弹出栈顶路由（弹出一个）
    case pop
    
    /// 弹出指定数量的路由
    case popCount(Int)
    
    /// 弹出到指定路由
    case popTo(R)
    
    /// 弹出到根视图（清空导航栈）
    case popToRoot
    
    /// 替换整个导航路径
    case replace([R])
    
    /// 在指定位置插入路由
    case insert(R, at: Int)
    
    /// 移除指定位置的路由
    case remove(at: Int)
}

// MARK: - Equatable

extension NavigationAction: Equatable where R: Equatable {}

// MARK: - Hashable

extension NavigationAction: Hashable where R: Hashable {}

// MARK: - Computed Properties

public extension NavigationAction {
    
    /// 动作是否会增加栈的深度
    var isAdditive: Bool {
        switch self {
        case .push, .insert:
            return true
        case .pop, .popTo, .popToRoot, .replace, .remove:
            return false
        case .popCount(let count):
            return count < 0 // 负数不会真正执行
        }
    }
    
    /// 动作是否会减少栈的深度
    var isSubtractive: Bool {
        switch self {
        case .pop, .popTo, .popToRoot, .remove:
            return true
        case .popCount(let count):
            return count > 0
        case .push, .insert, .replace:
            return false
        }
    }
    
    /// 动作的名称（用于日志）
    var name: String {
        switch self {
        case .push:
            return "push"
        case .pop:
            return "pop"
        case .popCount(let count):
            return "popCount(\(count))"
        case .popTo:
            return "popTo"
        case .popToRoot:
            return "popToRoot"
        case .replace:
            return "replace"
        case .insert:
            return "insert"
        case .remove:
            return "remove"
        }
    }
}

// MARK: - CustomStringConvertible

extension NavigationAction: CustomStringConvertible {
    public var description: String {
        switch self {
        case .push(let route):
            return "push(\(route))"
        case .pop:
            return "pop"
        case .popCount(let count):
            return "popCount(\(count))"
        case .popTo(let route):
            return "popTo(\(route))"
        case .popToRoot:
            return "popToRoot"
        case .replace(let routes):
            return "replace(\(routes))"
        case .insert(let route, let index):
            return "insert(\(route), at: \(index))"
        case .remove(let index):
            return "remove(at: \(index))"
        }
    }
}
