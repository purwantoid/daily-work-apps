import SwiftUI

public struct SummaryCard: View {
    public let title: String
    public let value: String
    public let subtitle: String
    public let color: Color
    public let icon: String
    
    public init(title: String, value: String, subtitle: String, color: Color, icon: String) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.color = color
        self.icon = icon
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(title)
                    .font(.custom("JetBrains Mono", size: 10)).bold()
                    .tracking(0.5)
            }
            .foregroundColor(color.opacity(0.5))
            
            Text(value)
                .font(.custom("JetBrains Mono", size: 22)).bold()
                .foregroundColor(color.opacity(0.8))
            
            Text(subtitle)
                .font(.custom("JetBrains Mono", size: 10))
                .foregroundColor(.black.opacity(0.4))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(color.opacity(0.04))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(color.opacity(0.08), lineWidth: 1)
        )
    }
}
