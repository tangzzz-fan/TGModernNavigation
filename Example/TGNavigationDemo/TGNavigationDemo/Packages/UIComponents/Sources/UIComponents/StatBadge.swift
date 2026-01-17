import SwiftUI

public struct StatBadge: View {
    public let value: String
    public let label: String
    
    public init(value: String, label: String) {
        self.value = value
        self.label = label
    }
    
    public var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.caption.bold())
                .foregroundStyle(.indigo)
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
