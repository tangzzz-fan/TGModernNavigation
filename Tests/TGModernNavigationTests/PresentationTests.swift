import Testing
import SwiftUI
@testable import TGModernNavigation

// MARK: - PresentationStore Tests

@Suite("PresentationStore Tests")
@MainActor
struct PresentationStoreTests {
    
    @Test("Initial state is empty")
    func initialState() {
        let store = PresentationStore<TestRoute>()
        
        #expect(store.count == 0)
        #expect(!store.isPresenting)
        #expect(store.currentRoute == nil)
        #expect(store.current == nil)
    }
    
    @Test("Present sheet with default configuration")
    func presentSheetDefaults() {
        let store = PresentationStore<TestRoute>()
        
        // embedInNavigationStack should default to false in 0.0.4
        store.sheet(.settings)
        
        #expect(store.count == 1)
        #expect(store.isPresenting)
        #expect(store.currentRoute == .settings)
        #expect(store.current?.style == .sheet)
        #expect(store.current?.embedInNavigationStack == false) // Crucial check for 0.0.4 change
    }
    
    @Test("Present sheet explicitly embedding in stack")
    func presentSheetEmbedded() {
        let store = PresentationStore<TestRoute>()
        
        store.sheet(.settings, embedInNavigationStack: true)
        
        #expect(store.count == 1)
        #expect(store.current?.embedInNavigationStack == true)
    }
    
    @Test("Present fullScreenCover")
    func presentFullScreenCover() {
        let store = PresentationStore<TestRoute>()
        
        store.fullScreenCover(.profile(name: "Alice"))
        
        #expect(store.count == 1)
        #expect(store.currentRoute == .profile(name: "Alice"))
        #expect(store.current?.style == .fullScreenCover)
        #expect(store.current?.embedInNavigationStack == false) // Default check
    }
    
    @Test("Dismiss modal")
    func dismissModal() {
        let store = PresentationStore<TestRoute>()
        store.sheet(.settings)
        #expect(store.isPresenting)
        
        store.dismiss()
        #expect(!store.isPresenting)
        #expect(store.count == 0)
    }
    
    @Test("Dismiss from empty state")
    func dismissFromEmpty() {
        let store = PresentationStore<TestRoute>()
        store.dismiss() // Should not crash
        #expect(!store.isPresenting)
    }
    
    @Test("Dismiss All")
    func dismissAll() {
        let store = PresentationStore<TestRoute>()
        store.sheet(.settings)
        store.sheet(.detail(id: 1))
        
        #expect(store.count == 2)
        
        store.dismissAll()
        #expect(store.count == 0)
    }
    
    @Test("Dismiss To specific route")
    func dismissTo() {
        let store = PresentationStore<TestRoute>()
        store.sheet(.settings)
        store.sheet(.detail(id: 1))
        store.sheet(.profile(name: "Bob"))
        
        #expect(store.count == 3)
        
        store.dismissTo(.settings)
        #expect(store.count == 1)
        #expect(store.currentRoute == .settings)
    }
    
    @Test("Replace modal")
    func replaceModal() {
        let store = PresentationStore<TestRoute>()
        store.sheet(.settings)
        
        store.replace(.detail(id: 99))
        
        #expect(store.count == 1)
        #expect(store.currentRoute == .detail(id: 99))
    }
}
