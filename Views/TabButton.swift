import SwiftUI

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
                        .matchedGeometryEffect(id: "TAB_BG", in: namespace)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(isSelected ? .black.opacity(0.8) : .black.opacity(0.4))
    }
}
