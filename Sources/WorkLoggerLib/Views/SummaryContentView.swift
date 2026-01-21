import SwiftUI

public struct SummaryContentView: View {
    public let events: [WorkEvent]
    public var onResume: (WorkEvent) -> Void
    public var onDelete: (WorkEvent) -> Void
    public var onUpdate: (WorkEvent) -> Void
    
    @State private var selectedDate = Date()
    
    public init(events: [WorkEvent], onResume: @escaping (WorkEvent) -> Void, onDelete: @escaping (WorkEvent) -> Void, onUpdate: @escaping (WorkEvent) -> Void) {
        self.events = events
        self.onResume = onResume
        self.onDelete = onDelete
        self.onUpdate = onUpdate
    }
    
    private var filteredEvents: [WorkEvent] {
        let calendar = Calendar.current
        return events.filter { calendar.isDate($0.startTime, inSameDayAs: selectedDate) }
    }
    
    private func copyStandup() {
        let dateStr = selectedDate.formatted(.dateTime.day().month().year())
        var content = "🚀 Standup Summary - \(dateStr)\n\n"
        
        let sortedEvents = filteredEvents.sorted(by: { $0.startTime < $1.startTime })
        
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
        content += "• Total Time: \(totalTime)\n"
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
    }

    private var meetingTime: String {
        let seconds = filteredEvents.filter { $0.type == .meeting }.reduce(0) { $0 + $1.duration }
        let minutes = Int(seconds / 60)
        return "\(minutes / 60)h \(minutes % 60)m"
    }
    
    private var totalTime: String {
        let seconds = filteredEvents.reduce(0) { $0 + $1.duration }
        let minutes = Int(seconds / 60)
        return "\(minutes / 60)h \(minutes % 60)m"
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HStack {
                    Label("DAILY SUMMARY", systemImage: "chart.bar.doc.horizontal.fill")
                        .font(.custom("JetBrains Mono", size: 12)).bold()
                        .foregroundColor(.secondary)
                    Spacer()
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.stepperField)
                        .labelsHidden()
                        .frame(width: 100)
                    
                    Button(action: { copyStandup() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.on.doc")
                            Text("Copy")
                        }
                        .font(.custom("JetBrains Mono", size: 11)).bold()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 24)
                
                HStack(spacing: 16) {
                    SummaryCard(title: "MEETINGS", value: meetingTime, subtitle: "\(filteredEvents.filter { $0.type == .meeting }.count) events", color: Color(red: 0.7, green: 0.4, blue: 0.9), icon: "video.bubble.left.fill")
                    SummaryCard(title: "TOTAL TIME", value: totalTime, subtitle: "\(filteredEvents.count) items", color: Color(red: 0.1, green: 0.6, blue: 0.5), icon: "timer")
                }
                .padding(.horizontal, 24)
                
                VStack(spacing: 8) {
                    if filteredEvents.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 32))
                                .foregroundColor(.secondary.opacity(0.3))
                            Text("No events for this date")
                                .font(.custom("JetBrains Mono", size: 12))
                                .foregroundColor(.secondary.opacity(0.6))
                        }
                        .padding(.vertical, 40)
                    } else {
                        ForEach(filteredEvents.sorted(by: { $0.startTime > $1.startTime })) { event in
                            EventRow(
                                event: event,
                                onResume: nil,
                                onDelete: { onDelete(event) },
                                onUpdate: { onUpdate($0) }
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
    }
}
