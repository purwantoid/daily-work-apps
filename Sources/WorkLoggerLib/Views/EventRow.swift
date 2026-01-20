import SwiftUI
import AppKit

public struct EventRow: View {
    public let event: WorkEvent
    public var onResume: (() -> Void)? = nil
    public var onDelete: (() -> Void)? = nil
    public var onUpdate: ((WorkEvent) -> Void)? = nil
    
    @State private var isEditing = false
    @State private var editedTitle = ""
    @State private var editedNotes = ""
    @State private var editedType: EventType = .task
    
    @State private var showingDetail = false
    
    public init(event: WorkEvent, onResume: (() -> Void)? = nil, onDelete: (() -> Void)? = nil, onUpdate: ((WorkEvent) -> Void)? = nil) {
        self.event = event
        self.onResume = onResume
        self.onDelete = onDelete
        self.onUpdate = onUpdate
    }
    
    public var body: some View {
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
                .frame(width: 38, alignment: .leading)
            } else {
                ZStack {
                    Circle()
                        .fill(event.type.color.opacity(0.06))
                        .frame(width: 32, height: 32)
                    Image(systemName: event.type.icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(event.type.color)
                }
                .frame(width: 38, alignment: .leading)
            }
            
            // Time
            Text(event.timeFormatted)
                .font(.custom("JetBrains Mono", size: 12))
                .foregroundColor(.black.opacity(0.4))
                .frame(width: 55, alignment: .leading)
            
            // Title & Notes
            VStack(alignment: .leading, spacing: 1) {
                Text(event.title)
                    .font(.custom("JetBrains Mono", size: 14)).bold()
                    .foregroundColor(event.isPaused ? .black.opacity(0.5) : .black.opacity(0.8))
                
                if let notes = event.notes {
                    Text(notes)
                        .font(.custom("JetBrains Mono", size: 10))
                        .foregroundColor(.black.opacity(0.4))
                        .lineLimit(1)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showingDetail = true
            }
            
            Spacer()
            
            // Duration & Copy
            VStack(alignment: .trailing, spacing: 4) {
                Text(event.durationFormatted)
                    .font(.custom("JetBrains Mono", size: 12))
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
        .padding(.vertical, 8)
        .popover(isPresented: $showingDetail) {
            EventDetailView(event: event) {
                editedTitle = event.title
                editedNotes = event.notes ?? ""
                editedType = event.type
                isEditing = true
                showingDetail = false
            }
        }
        .contextMenu {
            Button(action: {
                editedTitle = event.title
                editedNotes = event.notes ?? ""
                editedType = event.type
                isEditing = true
            }) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: { onDelete?() }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $isEditing) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Edit Event")
                    .font(.headline)
                
                TextField("Title", text: $editedTitle, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...3)
                
                TextField("Notes", text: $editedNotes, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(2...5)
                
                Picker("Type", selection: $editedType) {
                    ForEach(EventType.allCases.filter { $0 != .workBlock }) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                HStack {
                    Button("Cancel") { isEditing = false }
                    Spacer()
                    Button("Save") {
                        var updatedEvent = event
                        updatedEvent.title = editedTitle
                        updatedEvent.notes = editedNotes.isEmpty ? nil : editedNotes
                        updatedEvent.type = editedType
                        onUpdate?(updatedEvent)
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
