import SwiftUI

public struct SummaryCard: View {
    public let title: String
    public let value: String
    public let subtitle: String
    public let color: Color
    
    public init(title: String, value: String, subtitle: String, color: Color) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.color = color
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundColor(color.opacity(0.5))
                .tracking(1.0)
            
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(color.opacity(0.8))
            
            Text(subtitle)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.black.opacity(0.4))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(color.opacity(0.04))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(color.opacity(0.08), lineWidth: 1)
        )
    }
}
