import SwiftUI

public struct SummaryContentView: View {
    public let events: [WorkEvent]
    public var onResume: (WorkEvent) -> Void
    public var onDelete: (WorkEvent) -> Void
    public var onUpdate: (WorkEvent) -> Void
    
    public init(events: [WorkEvent], onResume: @escaping (WorkEvent) -> Void, onDelete: @escaping (WorkEvent) -> Void, onUpdate: @escaping (WorkEvent) -> Void) {
        self.events = events
        self.onResume = onResume
        self.onDelete = onDelete
        self.onUpdate = onUpdate
    }
    
    private func copyStandup() {
        let dateStr = Date().formatted(.dateTime.day().month().year())
        var content = "🚀 Standup Summary - \(dateStr)\n\n"
        
        let sortedEvents = events.sorted(by: { $0.startTime < $1.startTime })
        
        if !sortedEvents.isEmpty {
            content += "✅ Completed:\n"
            for event in sortedEvents {
                content += "• [\(event.type.rawValue)] \(event.title) (\(event.durationFormatted))\n"
                if let notes = event.notes, !notes.isEmpty {
                    content += "  └─ \(notes)\n"
                }
            }
            content += "\n"
        }
        
        content += "📊 Stats:\n"
        content += "• Meetings: \(meetingTime)\n"
        content += "• Deep Work: \(deepWorkTime)\n"
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
    }

    private var meetingTime: String {
        let seconds = events.filter { $0.type == .meeting }.reduce(0) { $0 + $1.duration }
        let minutes = Int(seconds / 60)
        return "\(minutes / 60)h \(minutes % 60)m"
    }
    
    private var deepWorkTime: String {
        let seconds = events.filter { $0.type == .task || $0.type == .codeReview }.reduce(0) { $0 + $1.duration }
        let minutes = Int(seconds / 60)
        return "\(minutes / 60)h \(minutes % 60)m"
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HStack {
                    Label("DAILY SUMMARY", systemImage: "doc.text")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: { copyStandup() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.on.doc")
                            Text("Copy for Standup")
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 24)
                
                HStack(spacing: 16) {
                    SummaryCard(title: "MEETINGS", value: meetingTime, subtitle: "\(events.filter { $0.type == .meeting }.count) events", color: Color(red: 0.7, green: 0.4, blue: 0.9))
                    SummaryCard(title: "DEEP WORK", value: deepWorkTime, subtitle: "\(events.filter { $0.type == .task || $0.type == .codeReview }.count) blocks", color: Color(red: 0.3, green: 0.6, blue: 1.0))
                }
                .padding(.horizontal, 24)
                
                VStack(spacing: 8) {
                    ForEach(events.sorted(by: { $0.startTime > $1.startTime })) { event in
                        EventRow(
                            event: event,
                            onResume: { onResume(event) },
                            onDelete: { onDelete(event) },
                            onUpdate: { onUpdate($0) }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
    }
}
