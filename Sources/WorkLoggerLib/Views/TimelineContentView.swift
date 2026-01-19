import SwiftUI

public struct TimelineContentView: View {
    public let events: [WorkEvent]
    public var onResume: (WorkEvent) -> Void
    public var onDelete: (WorkEvent) -> Void
    public var onUpdate: (WorkEvent) -> Void
    
    @State private var isEditing = false
    @State private var selectedEvent: WorkEvent?
    @State private var editedTitle = ""
    @State private var editedNotes = ""
    @State private var editedType: EventType = .task
    
    public init(events: [WorkEvent], onResume: @escaping (WorkEvent) -> Void, onDelete: @escaping (WorkEvent) -> Void, onUpdate: @escaping (WorkEvent) -> Void) {
        self.events = events
        self.onResume = onResume
        self.onDelete = onDelete
        self.onUpdate = onUpdate
    }
    
    public var body: some View {
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
                    ForEach(events.sorted(by: { $0.startTime > $1.startTime })) { event in
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
        .sheet(isPresented: $isEditing) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Edit Event")
                    .font(.headline)
                
                TextField("Title", text: $editedTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Notes", text: $editedNotes)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Picker("Type", selection: $editedType) {
                    ForEach(EventType.allCases.filter { $0 != .workBlock }) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                HStack {
                    Button("Cancel") { isEditing = false }
                    Spacer()
                    Button("Save") {
                        if var updatedEvent = selectedEvent {
                            updatedEvent.title = editedTitle
                            updatedEvent.notes = editedNotes.isEmpty ? nil : editedNotes
                            updatedEvent.type = editedType
                            onUpdate(updatedEvent)
                        }
                        isEditing = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .frame(width: 300)
        }
    }
}
