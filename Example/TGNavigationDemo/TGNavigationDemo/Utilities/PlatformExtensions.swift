import SwiftUI

// MARK: - Platform Compatibility Extensions

extension View {
    /// Cross-platform navigation bar title display mode
    @ViewBuilder
    func navigationBarTitleDisplayModeCompat(_ displayMode: NavigationBarTitleDisplayMode) -> some View {
        #if os(iOS) || os(visionOS)
        self.navigationBarTitleDisplayMode(displayMode.native)
        #else
        self
        #endif
    }
}

enum NavigationBarTitleDisplayMode {
    case inline
    case large
    case automatic
    
    #if os(iOS) || os(visionOS)
    var native: NavigationBarItem.TitleDisplayMode {
        switch self {
        case .inline: return .inline
        case .large: return .large
        case .automatic: return .automatic
        }
    }
    #endif
}

// MARK: - Cross-Platform Colors

extension Color {
    static var systemGroupedBackground: Color {
        #if os(iOS)
        Color(uiColor: .systemGroupedBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }
    
    static var secondarySystemGroupedBackground: Color {
        #if os(iOS)
        Color(uiColor: .secondarySystemGroupedBackground)
        #else
        Color(nsColor: .controlBackgroundColor)
        #endif
    }
}

// MARK: - TextField Extensions

extension View {
    @ViewBuilder
    func textInputAutocapitalizationCompat(_ autocapitalization: TextInputAutocapitalizationType) -> some View {
        #if os(iOS) || os(visionOS)
        self.textInputAutocapitalization(autocapitalization.native)
        #else
        self
        #endif
    }
}

enum TextInputAutocapitalizationType {
    case never
    case words
    case sentences
    case characters
    
    #if os(iOS) || os(visionOS)
    var native: TextInputAutocapitalization {
        switch self {
        case .never: return .never
        case .words: return .words
        case .sentences: return .sentences
        case .characters: return .characters
        }
    }
    #endif
}
