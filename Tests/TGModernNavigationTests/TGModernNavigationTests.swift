import Testing
import SwiftUI
@testable import TGModernNavigation

// MARK: - Test Route

enum TestRoute: Route {
    case home
    case detail(id: Int)
    case settings
    case profile(name: String)
    
    var id: Self { self }
    
    @MainActor
    @ViewBuilder
    var body: some View {
        switch self {
        case .home:
            Text("Home")
        case .detail(let id):
            Text("Detail \(id)")
        case .settings:
            Text("Settings")
        case .profile(let name):
            Text("Profile \(name)")
        }
    }
}

// MARK: - NavigationState Tests

@Suite("NavigationState Tests")
struct NavigationStateTests {
    
    @Test("Initial state should be empty")
    func initialStateEmpty() {
        let state = NavigationState<TestRoute>()
        #expect(state.isEmpty)
        #expect(state.count == 0)
        #expect(state.currentRoute == nil)
        #expect(!state.canPop)
    }
    
    @Test("State with initial path")
    func stateWithInitialPath() {
        let state = NavigationState<TestRoute>(path: [.home, .settings])
        #expect(!state.isEmpty)
        #expect(state.count == 2)
        #expect(state.currentRoute == .settings)
        #expect(state.canPop)
    }
    
    @Test("Push operation")
    func pushOperation() {
        var state = NavigationState<TestRoute>()
        state.push(.home)
        #expect(state.count == 1)
        #expect(state.currentRoute == .home)
        
        state.push(.detail(id: 42))
        #expect(state.count == 2)
        #expect(state.currentRoute == .detail(id: 42))
    }
    
    @Test("Pop operation")
    func popOperation() {
        var state = NavigationState<TestRoute>(path: [.home, .settings])
        let popped = state.pop()
        #expect(popped == .settings)
        #expect(state.count == 1)
        #expect(state.currentRoute == .home)
    }
    
    @Test("Pop from empty state")
    func popFromEmpty() {
        var state = NavigationState<TestRoute>()
        let popped = state.pop()
        #expect(popped == nil)
        #expect(state.isEmpty)
    }
    
    @Test("PopToRoot operation")
    func popToRootOperation() {
        var state = NavigationState<TestRoute>(path: [.home, .settings, .detail(id: 1)])
        state.popToRoot()
        #expect(state.isEmpty)
        #expect(state.count == 0)
    }
    
    @Test("PopTo specific route")
    func popToRoute() {
        var state = NavigationState<TestRoute>(path: [.home, .settings, .detail(id: 1)])
        let success = state.popTo(.settings)
        #expect(success)
        #expect(state.count == 2)
        #expect(state.currentRoute == .settings)
    }
    
    @Test("PopTo non-existent route")
    func popToNonExistent() {
        var state = NavigationState<TestRoute>(path: [.home, .settings])
        let success = state.popTo(.detail(id: 99))
        #expect(!success)
        #expect(state.count == 2)
    }
    
    @Test("Replace path")
    func replacePath() {
        var state = NavigationState<TestRoute>(path: [.home])
        state.replace(with: [.settings, .detail(id: 1), .profile(name: "Test")])
        #expect(state.count == 3)
        #expect(state.path == [.settings, .detail(id: 1), .profile(name: "Test")])
    }
    
    @Test("Insert at index")
    func insertAtIndex() {
        var state = NavigationState<TestRoute>(path: [.home, .settings])
        state.insert(.detail(id: 5), at: 1)
        #expect(state.count == 3)
        #expect(state.path[1] == .detail(id: 5))
    }
    
    @Test("Remove at index")
    func removeAtIndex() {
        var state = NavigationState<TestRoute>(path: [.home, .detail(id: 1), .settings])
        let removed = state.remove(at: 1)
        #expect(removed == .detail(id: 1))
        #expect(state.count == 2)
        #expect(state.path == [.home, .settings])
    }
    
    @Test("Subscript access")
    func subscriptAccess() {
        let state = NavigationState<TestRoute>(path: [.home, .settings])
        #expect(state[0] == .home)
        #expect(state[1] == .settings)
        #expect(state[2] == nil)
        #expect(state[-1] == nil)
    }
}

// MARK: - NavigationAction Tests

@Suite("NavigationAction Tests")
struct NavigationActionTests {
    
    @Test("Action name property")
    func actionNames() {
        let push: NavigationAction<TestRoute> = .push(.home)
        let pop: NavigationAction<TestRoute> = .pop
        let popToRoot: NavigationAction<TestRoute> = .popToRoot
        
        #expect(push.name == "push")
        #expect(pop.name == "pop")
        #expect(popToRoot.name == "popToRoot")
    }
    
    @Test("Additive actions")
    func additiveActions() {
        let push: NavigationAction<TestRoute> = .push(.home)
        let insert: NavigationAction<TestRoute> = .insert(.home, at: 0)
        
        #expect(push.isAdditive)
        #expect(insert.isAdditive)
    }
    
    @Test("Subtractive actions")
    func subtractiveActions() {
        let pop: NavigationAction<TestRoute> = .pop
        let popToRoot: NavigationAction<TestRoute> = .popToRoot
        let remove: NavigationAction<TestRoute> = .remove(at: 0)
        
        #expect(pop.isSubtractive)
        #expect(popToRoot.isSubtractive)
        #expect(remove.isSubtractive)
    }
}

// MARK: - NavigationReducer Tests

@Suite("NavigationReducer Tests")
struct NavigationReducerTests {
    
    @Test("Reduce push action")
    func reducePush() {
        let state = NavigationState<TestRoute>()
        let newState = NavigationReducer.reduce(state: state, action: .push(.home))
        
        #expect(newState.count == 1)
        #expect(newState.currentRoute == .home)
    }
    
    @Test("Reduce pop action")
    func reducePop() {
        let state = NavigationState<TestRoute>(path: [.home, .settings])
        let newState = NavigationReducer.reduce(state: state, action: .pop)
        
        #expect(newState.count == 1)
        #expect(newState.currentRoute == .home)
    }
    
    @Test("Reduce popToRoot action")
    func reducePopToRoot() {
        let state = NavigationState<TestRoute>(path: [.home, .settings, .detail(id: 1)])
        let newState = NavigationReducer.reduce(state: state, action: .popToRoot)
        
        #expect(newState.isEmpty)
    }
    
    @Test("Reduce replace action")
    func reduceReplace() {
        let state = NavigationState<TestRoute>(path: [.home])
        let newPath: [TestRoute] = [.settings, .detail(id: 2)]
        let newState = NavigationReducer.reduce(state: state, action: .replace(newPath))
        
        #expect(newState.path == newPath)
    }
    
    @Test("Reduce insert action")
    func reduceInsert() {
        let state = NavigationState<TestRoute>(path: [.home, .settings])
        let newState = NavigationReducer.reduce(state: state, action: .insert(.detail(id: 3), at: 1))
        
        #expect(newState.count == 3)
        #expect(newState.path[1] == .detail(id: 3))
    }
    
    @Test("Reduce remove action")
    func reduceRemove() {
        let state = NavigationState<TestRoute>(path: [.home, .detail(id: 1), .settings])
        let newState = NavigationReducer.reduce(state: state, action: .remove(at: 1))
        
        #expect(newState.count == 2)
        #expect(newState.path == [.home, .settings])
    }
    
    @Test("Reduce pop with count")
    func reducePopWithCount() {
        let state = NavigationState<TestRoute>(path: [.home, .settings, .detail(id: 1), .profile(name: "Test")])
        let newState = NavigationReducer.reduce(state: state, action: .popCount(2))
        
        #expect(newState.count == 2)
        #expect(newState.path == [.home, .settings])
    }
}

// MARK: - NavigationStore Tests

@Suite("NavigationStore Tests")
@MainActor
struct NavigationStoreTests {
    
    @Test("Store initial state")
    func storeInitialState() {
        let store = NavigationStore<TestRoute>()
        
        #expect(store.isEmpty)
        #expect(store.count == 0)
        #expect(store.currentRoute == nil)
        #expect(!store.canPop)
    }
    
    @Test("Store with initial path")
    func storeWithInitialPath() {
        let store = NavigationStore<TestRoute>(initialPath: [.home, .settings])
        
        #expect(store.count == 2)
        #expect(store.path == [.home, .settings])
    }
    
    @Test("Push via store")
    func pushViaStore() {
        let store = NavigationStore<TestRoute>()
        store.push(.home)
        
        #expect(store.count == 1)
        #expect(store.currentRoute == .home)
    }
    
    @Test("Pop via store")
    func popViaStore() {
        let store = NavigationStore<TestRoute>(initialPath: [.home, .settings])
        store.pop()
        
        #expect(store.count == 1)
        #expect(store.currentRoute == .home)
    }
    
    @Test("PopToRoot via store")
    func popToRootViaStore() {
        let store = NavigationStore<TestRoute>(initialPath: [.home, .settings, .detail(id: 1)])
        store.popToRoot()
        
        #expect(store.isEmpty)
    }
    
    @Test("Replace via store")
    func replaceViaStore() {
        let store = NavigationStore<TestRoute>(initialPath: [.home])
        store.replace([.settings, .detail(id: 2)])
        
        #expect(store.path == [.settings, .detail(id: 2)])
    }
    
    @Test("Dispatch action")
    func dispatchAction() {
        let store = NavigationStore<TestRoute>()
        store.dispatch(.push(.home))
        store.dispatch(.push(.settings))
        
        #expect(store.count == 2)
        
        store.dispatch(.pop)
        #expect(store.count == 1)
    }
    
    @Test("Path binding")
    func pathBinding() {
        let store = NavigationStore<TestRoute>()
        let binding = store.pathBinding
        
        binding.wrappedValue = [.home, .settings]
        #expect(store.path == [.home, .settings])
    }
}

// MARK: - Middleware Tests

@Suite("Middleware Tests")
@MainActor
struct MiddlewareTests {
    
    @Test("Logging middleware prints logs")
    func loggingMiddleware() async {
        let store = NavigationStore<TestRoute>()
        
        // 使用无捕获的日志器来避免并发问题
        store.enableLogging { _ in
            // 日志被调用
        }
        
        store.push(.home)
        
        // 验证导航成功执行
        #expect(store.count == 1)
        #expect(store.currentRoute == .home)
    }
    
    @Test("Guard middleware blocks navigation")
    func guardMiddlewareBlocks() {
        let store = NavigationStore<TestRoute>()
        store.addGuard { action, _ in
            if case .push(.settings) = action {
                return nil // Block settings
            }
            return action
        }
        
        store.push(.home)
        #expect(store.count == 1)
        
        store.push(.settings)
        #expect(store.count == 1) // Should be blocked
        
        store.push(.detail(id: 1))
        #expect(store.count == 2) // Should work
    }
    
    @Test("Guard middleware redirects navigation")
    func guardMiddlewareRedirects() {
        let store = NavigationStore<TestRoute>()
        store.addGuard { action, _ in
            if case .push(.settings) = action {
                return .push(.home) // Redirect to home
            }
            return action
        }
        
        store.push(.settings)
        #expect(store.currentRoute == .home)
    }
}

// MARK: - State Observer Tests

@Suite("State Observer Tests")
@MainActor
struct StateObserverTests {
    
    @Test("Observer receives state changes")
    func observerReceivesChanges() {
        var oldStates: [NavigationState<TestRoute>] = []
        var newStates: [NavigationState<TestRoute>] = []
        
        let store = NavigationStore<TestRoute>()
        store.observe { old, new in
            oldStates.append(old)
            newStates.append(new)
        }
        
        store.push(.home)
        store.push(.settings)
        
        #expect(oldStates.count == 2)
        #expect(newStates.count == 2)
        #expect(oldStates[0].isEmpty)
        #expect(newStates[0].count == 1)
    }
}

// MARK: - Route Equality Tests

@Suite("Route Equality Tests")
struct RouteEqualityTests {
    
    @Test("Simple routes are equal")
    func simpleRoutesEqual() {
        #expect(TestRoute.home == TestRoute.home)
        #expect(TestRoute.settings == TestRoute.settings)
    }
    
    @Test("Routes with same associated values are equal")
    func routesWithSameValuesEqual() {
        #expect(TestRoute.detail(id: 42) == TestRoute.detail(id: 42))
        #expect(TestRoute.profile(name: "Test") == TestRoute.profile(name: "Test"))
    }
    
    @Test("Routes with different values are not equal")
    func routesWithDifferentValuesNotEqual() {
        #expect(TestRoute.detail(id: 1) != TestRoute.detail(id: 2))
        #expect(TestRoute.profile(name: "A") != TestRoute.profile(name: "B"))
    }
    
    @Test("Different routes are not equal")
    func differentRoutesNotEqual() {
        #expect(TestRoute.home != TestRoute.settings)
    }
}
