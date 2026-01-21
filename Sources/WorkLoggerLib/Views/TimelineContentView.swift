import SwiftUI

public struct TimelineContentView: View {
    public let events: [WorkEvent]
    public let todayTodos: [TodoItem]
    public var onResume: (WorkEvent) -> Void
    public var onDelete: (WorkEvent) -> Void
    public var onUpdate: (WorkEvent) -> Void
    public var onStartTodo: (TodoItem) -> Void
    
    @State private var isEditing = false
    @State private var selectedEvent: WorkEvent?
    @State private var editedTitle = ""
    @State private var editedNotes = ""
    @State private var editedType: EventType = .task
    
    @State private var eventForDetail: WorkEvent?
    
    public init(events: [WorkEvent], todayTodos: [TodoItem], onResume: @escaping (WorkEvent) -> Void, onDelete: @escaping (WorkEvent) -> Void, onUpdate: @escaping (WorkEvent) -> Void, onStartTodo: @escaping (TodoItem) -> Void) {
        self.events = events
        self.todayTodos = todayTodos
        self.onResume = onResume
        self.onDelete = onDelete
        self.onUpdate = onUpdate
        self.onStartTodo = onStartTodo
    }
    
    private var groupedEvents: [(Date, [WorkEvent])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: events) { event in
            calendar.startOfDay(for: event.startTime)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    private func dateHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "TODAY"
        } else if calendar.isDateInYesterday(date) {
            return "YESTERDAY"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date).uppercased()
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("TODAY'S TIMELINE", systemImage: "timer.square")
                    .font(.custom("JetBrains Mono", size: 11)).bold()
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(events.count) events")
                    .font(.custom("JetBrains Mono", size: 10))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            .padding(.horizontal, 24)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Today's Todos Section
                    if !todayTodos.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("TODAY'S TODOS")
                                .font(.custom("JetBrains Mono", size: 10)).bold()
                                .foregroundColor(.blue.opacity(0.6))
                                .padding(.horizontal, 24)
                            
                            ForEach(todayTodos) { todo in
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 6) {
                                            Image(systemName: todo.type.icon)
                                                .font(.system(size: 10))
                                                .foregroundColor(todo.type.color)
                                            Text(todo.title)
                                                .font(.custom("JetBrains Mono", size: 13)).bold()
                                                .foregroundColor(.black.opacity(0.7))
                                        }
                                        
                                        if let start = todo.plannedStartTime, let end = todo.plannedEndTime {
                                            HStack(spacing: 4) {
                                                Image(systemName: "timer")
                                                    .font(.system(size: 9))
                                                Text("\(start.formatted(.dateTime.hour().minute())) – \(end.formatted(.dateTime.hour().minute()))")
                                                    .font(.custom("JetBrains Mono", size: 9))
                                            }
                                            .foregroundColor(.blue.opacity(0.6))
                                            .padding(.top, 1)
                                        }
                                        
                                        if let notes = todo.notes {
                                            Text(notes)
                                                .font(.custom("JetBrains Mono", size: 10))
                                                .foregroundColor(.black.opacity(0.4))
                                                .lineLimit(1)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        eventForDetail = WorkEvent(
                                            id: todo.id,
                                            title: todo.title,
                                            notes: todo.notes,
                                            startTime: todo.targetDate,
                                            endTime: todo.targetDate,
                                            type: .task
                                        )
                                    }
                                    .popover(item: Binding(
                                        get: { eventForDetail?.id == todo.id ? eventForDetail : nil },
                                        set: { eventForDetail = $0 }
                                    )) { event in
                                        EventDetailView(event: event)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: { onStartTodo(todo) }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "play.fill")
                                                .font(.system(size: 9))
                                            Text("Start")
                                                .font(.custom("JetBrains Mono", size: 11)).bold()
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(6)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.03))
                                .cornerRadius(12)
                                .padding(.horizontal, 24)
                            }
                        }
                    }

                    // Grouped Events
                    ForEach(groupedEvents, id: \.0) { date, dayEvents in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(dateHeader(date))
                                .font(.custom("JetBrains Mono", size: 10)).bold()
                                .foregroundColor(.secondary.opacity(0.5))
                                .padding(.horizontal, 24)
                                .padding(.bottom, 6)

                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(dayEvents.sorted(by: { $0.startTime > $1.startTime })) { event in
                                    HStack(alignment: .top, spacing: 20) {
                                        VStack(spacing: 0) {
                                            Circle()
                                                .fill(Color.secondary.opacity(0.2))
                                                .frame(width: 6, height: 6)
                                                .padding(.top, 14)
                                            
                                            Rectangle()
                                                .fill(Color.secondary.opacity(0.1))
                                                .frame(width: 1.2)
                                        }
                                        
                                        HStack(spacing: 16) {
                                            ZStack {
                                                Circle()
                                                    .fill(event.type.color.opacity(0.04))
                                                    .frame(width: 32, height: 32)
                                                Image(systemName: event.type.icon)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(event.type.color.opacity(0.8))
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(event.title)
                                                    .font(.custom("JetBrains Mono", size: 13)).bold()
                                                    .foregroundColor(.black.opacity(0.7))
                                                
                                                if let notes = event.notes {
                                                    Text(notes)
                                                        .font(.custom("JetBrains Mono", size: 10))
                                                        .foregroundColor(.black.opacity(0.4))
                                                        .lineLimit(1)
                                                }
                                                
                                                Text("\(event.startTime.formatted(.dateTime.hour().minute())) – \(event.endTime.formatted(.dateTime.hour().minute()))")
                                                    .font(.custom("JetBrains Mono", size: 9))
                                                    .foregroundColor(.black.opacity(0.3))
                                                    .padding(.top, 1)
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                eventForDetail = event
                                            }
                                            .popover(item: Binding(
                                                get: { eventForDetail?.id == event.id ? eventForDetail : nil },
                                                set: { eventForDetail = $0 }
                                            )) { event in
                                                EventDetailView(event: event) {
                                                    selectedEvent = event
                                                    editedTitle = event.title
                                                    editedNotes = event.notes ?? ""
                                                    editedType = event.type
                                                    isEditing = true
                                                    eventForDetail = nil
                                                }
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
                                        .padding(.vertical, 6)
                                    }
                                    .frame(minHeight: 60)
                                    .contextMenu {
                                        Button(action: {
                                            selectedEvent = event
                                            editedTitle = event.title
                                            editedNotes = event.notes ?? ""
                                            editedType = event.type
                                            isEditing = true
                                        }) {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        
                                        Button(role: .destructive, action: { onDelete(event) }) {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Edit Event")
                    .font(.custom("JetBrains Mono", size: 14)).bold()
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
                
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "pencil.line")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.4))
                            .padding(.top, 2)
                        
                        TextField("Event title...", text: $editedTitle, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.custom("JetBrains Mono", size: 14)).bold()
                            .foregroundColor(.black.opacity(0.8))
                            .lineLimit(1...3)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    Divider().opacity(0.05).padding(.horizontal, 16)
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 12))
                            .foregroundColor(.black.opacity(0.3))
                            .padding(.top, 3)
                        
                        TextField("Add notes or description...", text: $editedNotes, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.custom("JetBrains Mono", size: 11))
                            .foregroundColor(.black.opacity(0.6))
                            .lineLimit(1...5)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
                
                HStack(spacing: 12) {
                    Button("Cancel") { isEditing = false }
                        .font(.custom("JetBrains Mono", size: 12))
                        .buttonStyle(.plain)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        if var updatedEvent = selectedEvent {
                            updatedEvent.title = editedTitle
                            updatedEvent.notes = editedNotes.isEmpty ? nil : editedNotes
                            onUpdate(updatedEvent)
                        }
                        isEditing = false
                    }) {
                        Text("Save Changes")
                            .font(.custom("JetBrains Mono", size: 12)).bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(editedTitle.isEmpty ? Color.blue.opacity(0.3) : Color.blue)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .disabled(editedTitle.isEmpty)
                }
                .padding(.top, 4)
            }
            .padding(20)
            .frame(width: 320)
        }
    }
}
