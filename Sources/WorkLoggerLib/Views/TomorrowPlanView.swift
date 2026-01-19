import SwiftUI

public struct TomorrowPlanView: View {
    public let todos: [TodoItem]
    public var onAdd: (String, String?) -> Void
    public var onToggle: (TodoItem) -> Void
    public var onDelete: (TodoItem) -> Void
    
    @Binding var todoTitle: String
    @Binding var todoNotes: String
    
    public init(todos: [TodoItem], todoTitle: Binding<String>, todoNotes: Binding<String>, onAdd: @escaping (String, String?) -> Void, onToggle: @escaping (TodoItem) -> Void, onDelete: @escaping (TodoItem) -> Void) {
        self.todos = todos
        self._todoTitle = todoTitle
        self._todoNotes = todoNotes
        self.onAdd = onAdd
        self.onToggle = onToggle
        self.onDelete = onDelete
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("TOMORROW'S PLAN")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(todos.count) items")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            .padding(.horizontal, 24)
            
            // Enhanced Input Area
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "pencil.line")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black.opacity(0.4))
                    
                    TextField("Next day task title...", text: $todoTitle)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.black.opacity(0.8))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                
                Divider().opacity(0.05).padding(.horizontal, 16)
                
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "text.alignleft")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.3))
                        .padding(.top, 3)
                    
                    TextField("Add notes or description (optional)", text: $todoNotes)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 16, weight: .regular, design: .rounded))
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
            .padding(.horizontal, 24)
            
            // Add Button
            Button(action: {
                if !todoTitle.isEmpty {
                    onAdd(todoTitle, todoNotes.isEmpty ? nil : todoNotes)
                    todoTitle = ""
                    todoNotes = ""
                }
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                    Text("Add for Tomorrow")
                    Spacer()
                }
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .background(todoTitle.isEmpty ? Color.blue.opacity(0.3) : Color.blue)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .disabled(todoTitle.isEmpty)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(todos) { todo in
                        HStack(spacing: 12) {
                            Button(action: { onToggle(todo) }) {
                                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(todo.isCompleted ? .green : .secondary.opacity(0.4))
                            }
                            .buttonStyle(.plain)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(todo.title)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(todo.isCompleted ? .secondary : .primary)
                                    .strikethrough(todo.isCompleted)
                                
                                if let notes = todo.notes {
                                    Text(notes)
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary.opacity(0.8))
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: { onDelete(todo) }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red.opacity(0.3))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}
