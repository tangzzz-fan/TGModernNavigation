import Testing
import SwiftUI
@testable import TGModernNavigation

// MARK: - Router Tests

@Suite("Router Tests")
@MainActor
struct RouterTests {
    
    @Test("Router initialization")
    func routerInit() {
        let router = Router<TestRoute>()
        
        #expect(router.navigation.path.isEmpty)
        #expect(!router.presentation.isPresenting)
    }
    
    @Test("Router push delegates to navigation store")
    func routerPush() {
        let router = Router<TestRoute>()
        
        router.push(.home)
        
        #expect(router.navigation.path.count == 1)
        #expect(router.navigation.path.last == .home)
    }
    
    @Test("Router pop delegates to navigation store")
    func routerPop() {
        let router = Router<TestRoute>()
        router.push(.home)
        router.push(.settings)
        
        router.pop()
        
        #expect(router.navigation.path.count == 1)
        #expect(router.navigation.path.last == .home)
    }
    
    @Test("Router sheet delegates to presentation store")
    func routerSheet() {
        let router = Router<TestRoute>()
        
        // Check default behavior for 0.0.4
        router.sheet(.settings)
        
        #expect(router.presentation.count == 1)
        #expect(router.presentation.currentRoute == .settings)
        #expect(router.presentation.current?.embedInNavigationStack == false)
    }
    
    @Test("Router fullScreenCover delegates to presentation store")
    func routerFullScreenCover() {
        let router = Router<TestRoute>()
        
        router.fullScreenCover(.profile(name: "Charlie"))
        
        #expect(router.presentation.count == 1)
        #expect(router.presentation.currentRoute == .profile(name: "Charlie"))
        #expect(router.presentation.current?.style == .fullScreenCover)
    }
    
    @Test("Router dismissAll delegates to presentation store")
    func routerDismissAll() {
        let router = Router<TestRoute>()
        router.sheet(.settings)
        router.sheet(.detail(id: 1))
        
        #expect(router.presentation.count == 2)
        
        router.dismissAll()
        
        #expect(router.presentation.count == 0)
    }
}
