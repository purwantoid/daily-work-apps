import SwiftUI

public struct TomorrowPlanView: View {
    public let todos: [TodoItem]
    public var onAdd: (String, String?) -> Void
    public var onToggle: (TodoItem) -> Void
    public var onDelete: (TodoItem) -> Void
    public var onUpdate: (TodoItem) -> Void
    
    @Binding var todoTitle: String
    @Binding var todoNotes: String
    
    @State private var editingTodo: TodoItem?
    @State private var isEditingTodo = false
    @State private var editedTodoTitle = ""
    @State private var editedTodoNotes = ""
    
    public init(todos: [TodoItem], todoTitle: Binding<String>, todoNotes: Binding<String>, onAdd: @escaping (String, String?) -> Void, onToggle: @escaping (TodoItem) -> Void, onDelete: @escaping (TodoItem) -> Void, onUpdate: @escaping (TodoItem) -> Void) {
        self.todos = todos
        self._todoTitle = todoTitle
        self._todoNotes = todoNotes
        self.onAdd = onAdd
        self.onToggle = onToggle
        self.onDelete = onDelete
        self.onUpdate = onUpdate
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("TOMORROW'S PLAN", systemImage: "calendar.badge.plus")
                    .font(.custom("JetBrains Mono", size: 12)).bold()
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(todos.count) items")
                    .font(.custom("JetBrains Mono", size: 10))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            .padding(.horizontal, 24)
            
            // Enhanced Input Area
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "pencil.line")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black.opacity(0.4))
                        .padding(.top, 2)
                    
                    TextField("Next day task title...", text: $todoTitle, axis: .vertical)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.custom("JetBrains Mono", size: 15)).bold()
                        .foregroundColor(.black.opacity(0.8))
                        .lineLimit(1...3)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                
                Divider().opacity(0.05).padding(.horizontal, 16)
                
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "text.alignleft")
                        .font(.system(size: 13))
                        .foregroundColor(.black.opacity(0.3))
                        .padding(.top, 3)
                    
                    TextField("Add notes or description (optional)", text: $todoNotes, axis: .vertical)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.custom("JetBrains Mono", size: 11))
                        .foregroundColor(.black.opacity(0.6))
                        .lineLimit(1...5)
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
                    Text("Add Task")
                    Spacer()
                }
                .font(.custom("JetBrains Mono", size: 13)).bold()
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .background(todoTitle.isEmpty ? Color.blue.opacity(0.3) : Color.blue)
                .cornerRadius(10)
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
                            
                            VStack(alignment: .leading, spacing: 1) {
                                Text(todo.title)
                                    .font(.custom("JetBrains Mono", size: 14)).bold()
                                    .foregroundColor(todo.isCompleted ? .secondary : .primary)
                                    .strikethrough(todo.isCompleted)
                                
                                if let notes = todo.notes {
                                    Text(notes)
                                        .font(.custom("JetBrains Mono", size: 10))
                                        .foregroundColor(.secondary.opacity(0.8))
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                editingTodo = todo
                                editedTodoTitle = todo.title
                                editedTodoNotes = todo.notes ?? ""
                                isEditingTodo = true
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary.opacity(0.4))
                            }
                            .buttonStyle(.plain)
                            
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
        .sheet(isPresented: $isEditingTodo) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Edit Task")
                    .font(.custom("JetBrains Mono", size: 14)).bold()
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
                
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "pencil.line")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.4))
                            .padding(.top, 2)
                        
                        TextField("Task title...", text: $editedTodoTitle, axis: .vertical)
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
                        
                        TextField("Add notes or description...", text: $editedTodoNotes, axis: .vertical)
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
                    Button("Cancel") { isEditingTodo = false }
                        .font(.custom("JetBrains Mono", size: 12))
                        .buttonStyle(.plain)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        if var updatedTodo = editingTodo {
                            updatedTodo.title = editedTodoTitle
                            updatedTodo.notes = editedTodoNotes.isEmpty ? nil : editedTodoNotes
                            onUpdate(updatedTodo)
                        }
                        isEditingTodo = false
                    }) {
                        Text("Save Changes")
                            .font(.custom("JetBrains Mono", size: 12)).bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(editedTodoTitle.isEmpty ? Color.blue.opacity(0.3) : Color.blue)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .disabled(editedTodoTitle.isEmpty)
                }
                .padding(.top, 4)
            }
            .padding(20)
            .frame(width: 320)
        }
    }
}
