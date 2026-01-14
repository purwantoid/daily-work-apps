import SwiftUI
import AppKit

struct EventRow: View {
    let event: WorkEvent
    var onResume: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            // Type Icon or Resume Toggle
            if event.isPaused && onResume != nil {
                Button(action: { onResume?() }) {
                    ZStack {
                        Circle()
                            .fill(event.type.color.opacity(0.1))
                            .frame(width: 32, height: 32)
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                            .foregroundColor(event.type.color)
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 35, alignment: .leading)
            } else {
                Image(systemName: event.type.icon)
                    .font(.system(size: 14))
                    .foregroundColor(event.type.color)
                    .frame(width: 35, alignment: .leading)
            }
            
            // Time
            Text(event.timeFormatted)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.black.opacity(0.4))
                .frame(width: 65, alignment: .leading)
            
            // Title & Notes
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(event.isPaused ? .black.opacity(0.5) : .black.opacity(0.8))
                
                if let notes = event.notes {
                    Text(notes)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.black.opacity(0.4))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Duration & Copy
            VStack(alignment: .trailing, spacing: 6) {
                Text(event.durationFormatted)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.4))
                
                Button(action: {
                    let content = "[\(event.type.rawValue)] \(event.title)\(event.notes != nil ? " - \(event.notes!)" : "") (\(event.durationFormatted))"
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(content, forType: .string)
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 11))
                        .foregroundColor(.black.opacity(0.2))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 12)
    }
}
