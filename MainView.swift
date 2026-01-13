import SwiftUI
import AppKit

struct MainView: View {
    @StateObject private var calendarManager = CalendarManager()
    @State private var selectedTab: Tab = .timeline
    @State private var quickLogText: String = ""
    @State private var quickLogNotes: String = ""
    @State private var selectedType: EventType = .task
    @State private var currentTime = Date()
    @Namespace private var animation
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    enum Tab {
        case timeline, summary
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                Text("Work Logger")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.15))
                Spacer()
                
                Text(Date().formatted(.dateTime.weekday(.abbreviated).month().day()))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.5))
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 20)
            
            // Quick Log Input Area
            VStack(spacing: 16) {
                // Type Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(EventType.allCases.filter { $0 != .workBlock }) { type in
                            Button(action: { selectedType = type }) {
                                Text(type.rawValue)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedType == type ? Color.blue.opacity(0.1) : Color.white)
                                    .foregroundColor(selectedType == type ? .blue : .black.opacity(0.6))
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.02), radius: 3, x: 0, y: 1)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedType == type ? Color.blue.opacity(0.2) : Color.black.opacity(0.05), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.horizontal, -24) // Allow scroll to edges
                
                // Inputs Card
                VStack(spacing: 0) {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "pencil.line")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black.opacity(0.4))
                        
                        TextField("Task title...", text: $quickLogText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.black.opacity(0.8))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    
                    Divider().opacity(0.05).padding(.horizontal, 16)
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.3))
                            .padding(.top, 3)
                        
                        TextField("Add notes or description (optional)", text: $quickLogNotes)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.black.opacity(0.6))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
                
                // Submit Action
                Button(action: handleQuickLog) {
                    HStack {
                        Spacer()
                        Image(systemName: "play.fill")
                        Text("Start Tracking")
                        Spacer()
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .background(quickLogText.isEmpty ? Color.blue.opacity(0.3) : Color.blue)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .disabled(quickLogText.isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            // Tracking Indicator (Start/Stop/End)
            HStack(spacing: 16) {
                if let active = calendarManager.activeTrackingEvent {
                    Button(action: {
                        withAnimation {
                            if active.isPaused {
                                calendarManager.resumeTracking()
                            } else {
                                calendarManager.pauseTracking()
                            }
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(active.isPaused ? Color.blue.opacity(0.1) : Color.primary.opacity(0.04))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: active.isPaused ? "play.fill" : "pause.fill")
                                .font(.system(size: 14))
                                .foregroundColor(active.isPaused ? .blue : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(active.title)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.black.opacity(0.8))
                        Text(active.isPaused ? "Paused" : "Tracking...")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(active.isPaused ? .blue.opacity(0.6) : .black.opacity(0.5))
                    }
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.primary.opacity(0.04))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "pause.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("No active task")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.black.opacity(0.8))
                        Text("Log something to start tracking")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.black.opacity(0.5))
                    }
                }
                
                Spacer()
                
                if calendarManager.activeTrackingEvent != nil {
                    HStack(spacing: 8) {
                        Button(action: {
                            if let active = calendarManager.activeTrackingEvent {
                                let content = "[\(active.type.rawValue)] \(active.title)\(active.notes != nil ? " - \(active.notes!)" : "") (\(active.durationFormatted))"
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(content, forType: .string)
                            }
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .padding(8)
                                .background(Color.blue.opacity(0.05))
                                .foregroundColor(.blue.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            withAnimation { calendarManager.endTracking() }
                        }) {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 14))
                                .padding(8)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .background(Color.primary.opacity(0.025))
            .cornerRadius(20)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            // Tab Switcher
            HStack(spacing: 0) {
                TabButton(title: "Timeline", icon: "calendar", isSelected: selectedTab == .timeline, namespace: animation) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selectedTab = .timeline }
                }
                
                TabButton(title: "Summary", icon: "list.bullet.indent", isSelected: selectedTab == .summary, namespace: animation) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selectedTab = .summary }
                }
            }
            .padding(6)
            .background(Color.primary.opacity(0.04))
            .cornerRadius(18)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            // Content
            Group {
                if selectedTab == .summary {
                    SummaryContentView(events: calendarManager.events) { event in
                        withAnimation { calendarManager.resumeTracking(event: event) }
                    }
                    .transition(.opacity)
                } else {
                    TimelineContentView(events: calendarManager.events) { event in
                        withAnimation { calendarManager.resumeTracking(event: event) }
                    }
                    .transition(.opacity)
                }
            }
            .frame(maxHeight: .infinity)
            
            // Footer
            HStack {
                Text("Press")
                    .foregroundColor(.secondary)
                Text("⌘ K")
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(5)
                Text("to quick log from anywhere")
                    .foregroundColor(.secondary)
            }
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .padding(.vertical, 20)
        }
        .background(
            ZStack {
                Color(red: 0.98, green: 0.96, blue: 1.0) // Soft white-pink base
                LinearGradient(colors: [
                    Color(red: 0.98, green: 0.95, blue: 1.0),
                    Color(red: 0.99, green: 0.98, blue: 1.0)
                ], startPoint: .top, endPoint: .bottom)
            }
            .edgesIgnoringSafeArea(.all)
        )
        .preferredColorScheme(.light)
        .frame(width: 385, height: 900)
        .textSelection(.enabled)
        .onReceive(timer) { _ in
            self.currentTime = Date()
        }
    }
    
    private func handleQuickLog() {
        guard !quickLogText.isEmpty else { return }
        calendarManager.logWork(title: quickLogText, notes: quickLogNotes.isEmpty ? nil : quickLogNotes, type: selectedType)
        // Clear exactly here as requested
        DispatchQueue.main.async {
            self.quickLogText = ""
            self.quickLogNotes = ""
        }
    }
}

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

// MARK: - Subviews

struct SummaryContentView: View {
    let events: [WorkEvent]
    var onResume: (WorkEvent) -> Void
    
    var meetingTime: String {
        let seconds = events.filter { $0.type == .meeting }.reduce(0) { $0 + $1.duration }
        let minutes = Int(seconds / 60)
        return "\(minutes / 60)h \(minutes % 60)m"
    }
    
    var deepWorkTime: String {
        let seconds = events.filter { $0.type == .task || $0.type == .codeReview }.reduce(0) { $0 + $1.duration }
        let minutes = Int(seconds / 60)
        return "\(minutes / 60)h \(minutes % 60)m"
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HStack {
                    Label("DAILY SUMMARY", systemImage: "doc.text")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.on.doc")
                            Text("Copy for Standup")
                        }
                        .font(.system(size: 13, weight: .bold, design: .rounded))
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
                    ForEach(events.sorted(by: { $0.startTime < $1.startTime })) { event in
                        EventRow(event: event) {
                            onResume(event)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
    }
}

struct TimelineContentView: View {
    let events: [WorkEvent]
    var onResume: (WorkEvent) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("TODAY'S TIMELINE")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(events.count) events")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            .padding(.horizontal, 24)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(events.sorted(by: { $0.startTime < $1.startTime })) { event in
                        HStack(alignment: .top, spacing: 20) {
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(width: 8, height: 8)
                                    .padding(.top, 18)
                                
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.1))
                                    .frame(width: 1.5)
                            }
                            
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(event.type.color.opacity(0.04))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: event.type.icon)
                                        .font(.system(size: 16))
                                        .foregroundColor(event.type.color.opacity(0.8))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(event.title)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.black.opacity(0.7))
                                    
                                    if let notes = event.notes {
                                        Text(notes)
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(.black.opacity(0.4))
                                            .lineLimit(1)
                                    }
                                    
                                    Text("\(event.startTime.formatted(.dateTime.hour().minute())) – \(event.endTime.formatted(.dateTime.hour().minute()))")
                                        .font(.system(size: 11, design: .rounded))
                                        .foregroundColor(.black.opacity(0.3))
                                        .padding(.top, 2)
                                }
                                
                                Spacer()
                                
                                if event.isPaused {
                                    Button(action: { onResume(event) }) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 12, weight: .bold))
                                            .padding(6)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        .frame(minHeight: 80)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

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

struct SummaryCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
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

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

