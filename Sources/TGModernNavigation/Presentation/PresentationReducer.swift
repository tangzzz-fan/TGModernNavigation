import SwiftUI

// MARK: - PresentationReducer

/// Reducer for Modal Presentation
public enum PresentationReducer<R: Route> {
    
    public static func reduce(
        state: PresentationState<R>,
        action: PresentationAction<R>
    ) -> PresentationState<R> {
        var newState = state
        
        switch action {
        case .present(let route, let style, let configuration):
            let presented = PresentedRoute(route: route, style: style, configuration: configuration)
            newState.present(presented)
            
        case .dismiss:
            newState.dismiss()
            
        case .dismissAll:
            newState.dismissAll()
            
        case .dismissTo(let route):
            newState.dismissTo(route)
            
        case .replace(let route, let style, let configuration):
            let presented = PresentedRoute(route: route, style: style, configuration: configuration)
            newState.replace(with: presented)
        }
        
        return newState
    }
}
