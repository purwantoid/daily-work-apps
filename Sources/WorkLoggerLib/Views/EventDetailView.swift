import SwiftUI
import AppKit

public struct EventDetailView: View {
    let event: WorkEvent
    public var onEdit: (() -> Void)?
    @State private var copied = false
    
    public init(event: WorkEvent, onEdit: (() -> Void)? = nil) {
        self.event = event
        self.onEdit = onEdit
    }
    
    private func copyToClipboard() {
        let content = """
        [\(event.type.rawValue)] \(event.title)
        Time: \(event.startTime.formatted(.dateTime.hour().minute())) - \(event.endTime.formatted(.dateTime.hour().minute()))
        Duration: \(event.durationFormatted)
        \(event.notes != nil ? "Notes: \(event.notes!)" : "")
        """
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
        
        withAnimation {
            copied = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                copied = false
            }
        }
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(event.type.color.opacity(0.1))
                            .frame(width: 40, height: 40)
                        Image(systemName: event.type.icon)
                            .font(.system(size: 18))
                            .foregroundColor(event.type.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.type.rawValue.uppercased())
                            .font(.custom("JetBrains Mono", size: 10)).bold()
                            .foregroundColor(event.type.color)
                        Text(event.title)
                            .font(.custom("JetBrains Mono", size: 16)).bold()
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    if let onEdit = onEdit {
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(8)
                                .background(Color.secondary.opacity(0.05))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .help("Edit event")
                    }
                    
                    Button(action: copyToClipboard) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 14))
                            .foregroundColor(copied ? .green : .secondary)
                            .padding(8)
                            .background(Color.secondary.opacity(0.05))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .help("Copy details")
                }
                
                Divider().opacity(0.1)
                
                VStack(alignment: .leading, spacing: 12) {
                    DetailItem(icon: "clock", label: "Time", value: "\(event.startTime.formatted(.dateTime.hour().minute())) - \(event.endTime.formatted(.dateTime.hour().minute()))")
                    DetailItem(icon: "timer", label: "Duration", value: event.durationFormatted)
                    
                    if let notes = event.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "text.alignleft")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Text("Notes")
                                    .font(.custom("JetBrains Mono", size: 11)).bold()
                                    .foregroundColor(.secondary)
                            }
                            Text(notes)
                                .font(.custom("JetBrains Mono", size: 12))
                                .foregroundColor(.primary.opacity(0.7))
                                .padding(.leading, 20)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(20)
        }
        .frame(width: 300)
        .frame(maxHeight: 400)
        .background(Color.white)
    }
}

struct DetailItem: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.secondary.opacity(0.6))
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(.custom("JetBrains Mono", size: 10))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.custom("JetBrains Mono", size: 12)).bold()
            }
        }
    }
}
