import SwiftUI

public struct PlanView: View {
    public let todayTodos: [TodoItem]
    public let tomorrowTodos: [TodoItem]
    
    @Binding var todoTitle: String
    @Binding var todoNotes: String
    @Binding var todoType: EventType
    @Binding var plannedStartTime: Date
    @Binding var plannedEndTime: Date
    @Binding var planDate: Date
    
    public var onAdd: (String, String?, Date, EventType, Date?, Date?) -> Void
    public var onToggle: (TodoItem) -> Void
    public var onDelete: (TodoItem) -> Void
    public var onUpdate: (TodoItem) -> Void
    
    @State private var selectedDay: Int = 0 // 0 for Today, 1 for Tomorrow
    @State private var editingTodo: TodoItem?
    @State private var isEditingTodo = false
    @State private var editedTodoTitle = ""
    @State private var editedTodoNotes = ""
    @State private var editedTodoType: EventType = .task
    @State private var editedStartTime = Date()
    @State private var editedEndTime = Date()
    
    public init(
        todayTodos: [TodoItem], 
        tomorrowTodos: [TodoItem],
        todoTitle: Binding<String>, 
        todoNotes: Binding<String>, 
        todoType: Binding<EventType>,
        plannedStartTime: Binding<Date>,
        plannedEndTime: Binding<Date>,
        planDate: Binding<Date>,
        onAdd: @escaping (String, String?, Date, EventType, Date?, Date?) -> Void, 
        onToggle: @escaping (TodoItem) -> Void, 
        onDelete: @escaping (TodoItem) -> Void, 
        onUpdate: @escaping (TodoItem) -> Void
    ) {
        self.todayTodos = todayTodos
        self.tomorrowTodos = tomorrowTodos
        self._todoTitle = todoTitle
        self._todoNotes = todoNotes
        self._todoType = todoType
        self._plannedStartTime = plannedStartTime
        self._plannedEndTime = plannedEndTime
        self._planDate = planDate
        self.onAdd = onAdd
        self.onToggle = onToggle
        self.onDelete = onDelete
        self.onUpdate = onUpdate
    }
    
    private var filteredTodos: [TodoItem] {
        selectedDay == 0 ? todayTodos : tomorrowTodos
    }
    
    private var currentTargetDate: Date {
        if selectedDay == 0 {
            return Calendar.current.startOfDay(for: Date())
        } else {
            return Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Day Selector
            Picker("", selection: $selectedDay) {
                Text("TODAY").tag(0)
                Text("TOMORROW").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            
            HStack {
                Label(selectedDay == 0 ? "TODAY'S PLAN" : "TOMORROW'S PLAN", systemImage: "calendar.badge.plus")
                    .font(.custom("JetBrains Mono", size: 12)).bold()
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(filteredTodos.count) items")
                    .font(.custom("JetBrains Mono", size: 10))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            .padding(.horizontal, 24)
            
            // Input Area
            VStack(spacing: 0) {
                // Type Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(EventType.allCases, id: \.self) { type in
                            Button(action: { todoType = type }) {
                                HStack(spacing: 4) {
                                    Image(systemName: type.icon)
                                    Text(type.rawValue.uppercased())
                                }
                                .font(.custom("JetBrains Mono", size: 9)).bold()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(todoType == type ? type.color : Color.black.opacity(0.05))
                                .foregroundColor(todoType == type ? .white : .black.opacity(0.4))
                                .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
                
                // 1. Title
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "pencil.line")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black.opacity(0.4))
                        .padding(.top, 4)
                    
                    TextField("What's the plan?", text: $todoTitle, axis: .vertical)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.custom("JetBrains Mono", size: 15)).bold()
                        .foregroundColor(.black.opacity(0.8))
                        .lineLimit(1...10)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                
                Divider().opacity(0.05).padding(.horizontal, 16).padding(.vertical, 4)
                
                // 2. Notes
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "text.alignleft")
                        .font(.system(size: 13))
                        .foregroundColor(.black.opacity(0.3))
                        .padding(.top, 3)
                    
                    TextField("Add notes or description (optional)", text: $todoNotes, axis: .vertical)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.custom("JetBrains Mono", size: 12))
                        .foregroundColor(.black.opacity(0.6))
                        .lineLimit(1...20)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                
                Divider().opacity(0.05).padding(.horizontal, 16).padding(.vertical, 8)
                
                // 3. Start/End Time
                HStack(spacing: 12) {
                    Label {
                        DatePicker("", selection: $plannedStartTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(.stepperField)
                            .frame(width: 70)
                    } icon: {
                        Image(systemName: "play.circle")
                            .font(.system(size: 11))
                            .foregroundColor(.blue.opacity(0.6))
                    }
                    
                    Text("to")
                        .font(.custom("JetBrains Mono", size: 10))
                        .foregroundColor(.secondary)
                    
                    Label {
                        DatePicker("", selection: $plannedEndTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(.stepperField)
                            .frame(width: 70)
                    } icon: {
                        Image(systemName: "stop.circle")
                            .font(.system(size: 11))
                            .foregroundColor(.red.opacity(0.6))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
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
                    onAdd(todoTitle, todoNotes.isEmpty ? nil : todoNotes, currentTargetDate, todoType, plannedStartTime, plannedEndTime)
                    todoTitle = ""
                    todoNotes = ""
                }
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                    Text("Add to \(selectedDay == 0 ? "Today" : "Tomorrow")")
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
                    ForEach(filteredTodos) { todo in
                        HStack(spacing: 12) {
                            Button(action: { onToggle(todo) }) {
                                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(todo.isCompleted ? .green : .secondary.opacity(0.4))
                            }
                            .buttonStyle(.plain)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Image(systemName: todo.type.icon)
                                        .font(.system(size: 10))
                                        .foregroundColor(todo.type.color)
                                    Text(todo.title)
                                        .font(.custom("JetBrains Mono", size: 14)).bold()
                                        .foregroundColor(todo.isCompleted ? .secondary : .primary)
                                        .strikethrough(todo.isCompleted)
                                }
                                
                                if let start = todo.plannedStartTime, let end = todo.plannedEndTime {
                                    HStack(spacing: 4) {
                                        Image(systemName: "timer")
                                            .font(.system(size: 9))
                                        Text("\(start.formatted(.dateTime.hour().minute())) – \(end.formatted(.dateTime.hour().minute()))")
                                            .font(.custom("JetBrains Mono", size: 10))
                                    }
                                    .foregroundColor(.blue.opacity(0.6))
                                }
                                
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
                                editedTodoType = todo.type
                                editedStartTime = todo.plannedStartTime ?? Date()
                                editedEndTime = todo.plannedEndTime ?? Date().addingTimeInterval(3600)
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
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(EventType.allCases, id: \.self) { type in
                                Button(action: { editedTodoType = type }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: type.icon)
                                        Text(type.rawValue.uppercased())
                                    }
                                    .font(.custom("JetBrains Mono", size: 8)).bold()
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(editedTodoType == type ? type.color : Color.black.opacity(0.05))
                                    .foregroundColor(editedTodoType == type ? .white : .black.opacity(0.4))
                                    .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    }

                    // 1. Title
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "pencil.line")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.4))
                            .padding(.top, 4)
                        
                        TextField("Task title...", text: $editedTodoTitle, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.custom("JetBrains Mono", size: 14)).bold()
                            .foregroundColor(.black.opacity(0.8))
                            .lineLimit(1...10)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    
                    Divider().opacity(0.05).padding(.horizontal, 16).padding(.vertical, 4)

                    // 2. Notes
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 12))
                            .foregroundColor(.black.opacity(0.3))
                            .padding(.top, 3)
                        
                        TextField("Add notes or description...", text: $editedTodoNotes, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.custom("JetBrains Mono", size: 11))
                            .foregroundColor(.black.opacity(0.6))
                            .lineLimit(1...20)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)

                    Divider().opacity(0.05).padding(.horizontal, 16).padding(.vertical, 8)

                    // 3. Time
                    HStack(spacing: 12) {
                        DatePicker("", selection: $editedStartTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(.stepperField)
                            .frame(width: 70)
                        Text("to").font(.caption).foregroundColor(.secondary)
                        DatePicker("", selection: $editedEndTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(.stepperField)
                            .frame(width: 70)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
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
                            updatedTodo.type = editedTodoType
                            updatedTodo.plannedStartTime = editedStartTime
                            updatedTodo.plannedEndTime = editedEndTime
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
