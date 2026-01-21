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
            
            // Time Range
            VStack(alignment: .leading, spacing: 1) {
                Text(event.startTime.formatted(.dateTime.hour().minute()))
                    .foregroundColor(.black.opacity(0.4))
                
                if event.endTime != event.startTime {
                    Text(event.endTime.formatted(.dateTime.hour().minute()))
                        .foregroundColor(.black.opacity(0.15))
                }
            }
            .font(.custom("JetBrains Mono", size: 10))
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
                        var updatedEvent = event
                        updatedEvent.title = editedTitle
                        updatedEvent.notes = editedNotes.isEmpty ? nil : editedNotes
                        onUpdate?(updatedEvent)
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
