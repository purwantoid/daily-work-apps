import SwiftUI
import Combine

public class MainViewModel: ObservableObject {
    @Published public var calendarManager = CalendarManager()
    @Published public var selectedTab: MainView.Tab = .timeline
    @Published public var quickLogText: String = ""
    @Published public var quickLogNotes: String = ""
    @Published public var selectedType: EventType = .task
    @Published public var currentTime = Date()
    @Published public var tomorrowTodos: [TodoItem] = []
    @Published public var todoTitle: String = ""
    @Published public var todoNotes: String = ""
    
    @Published public var morningReminderTime: Date = Date()
    @Published public var eveningReminderTime: Date = Date()
    
    private var timer: AnyCancellable?
    
    public init() {
        startTimer()
        fetchTomorrowTodos()
        loadReminderSettings()
    }
    
    func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.currentTime = Date()
            }
    }
    
    func handleQuickLog() {
        guard !quickLogText.isEmpty else { return }
        calendarManager.logWork(
            title: quickLogText,
            notes: quickLogNotes.isEmpty ? nil : quickLogNotes,
            type: selectedType
        )
        
        // Clear inputs
        quickLogText = ""
        quickLogNotes = ""
    }
    
    func resumeTracking(event: WorkEvent? = nil) {
        calendarManager.resumeTracking(event: event)
    }
    
    func pauseTracking() {
        calendarManager.pauseTracking()
    }
    
    func endTracking() {
        calendarManager.endTracking()
    }
    
    func deleteEvent(_ event: WorkEvent) {
        calendarManager.deleteEvent(event)
    }
    
    func updateEvent(_ event: WorkEvent) {
        calendarManager.updateEvent(event)
    }
    
    var activeTrackingEvent: WorkEvent? {
        calendarManager.activeTrackingEvent
    }
    
    var events: [WorkEvent] {
        calendarManager.events
    }
    
    // MARK: - Todo Actions
    
    public func fetchTomorrowTodos() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        tomorrowTodos = DatabaseManager.shared.fetchTodos(for: tomorrow)
    }
    
    public func addTodo(title: String, notes: String? = nil) {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let todo = TodoItem(title: title, notes: notes, targetDate: tomorrow)
        DatabaseManager.shared.saveTodo(todo)
        fetchTomorrowTodos()
        todoNotes = "" // Clear after add
    }
    
    public func toggleTodo(_ todo: TodoItem) {
        var updated = todo
        updated.isCompleted.toggle()
        DatabaseManager.shared.updateTodo(updated)
        fetchTomorrowTodos()
    }
    
    public func deleteTodo(_ todo: TodoItem) {
        DatabaseManager.shared.deleteTodo(id: todo.id)
        fetchTomorrowTodos()
    }
    
    // MARK: - Reminder Settings
    
    private func loadReminderSettings() {
        let morningTS = UserDefaults.standard.double(forKey: "morning_reminder")
        let eveningTS = UserDefaults.standard.double(forKey: "evening_reminder")
        
        if morningTS > 0 {
            morningReminderTime = Date(timeIntervalSince1970: morningTS)
        } else {
            morningReminderTime = createTime(hour: 10, minute: 0)
        }
        
        if eveningTS > 0 {
            eveningReminderTime = Date(timeIntervalSince1970: eveningTS)
        } else {
            eveningReminderTime = createTime(hour: 18, minute: 0)
        }
    }
    
    public func updateReminderSettings(morning: Date, evening: Date) {
        morningReminderTime = morning
        eveningReminderTime = evening
        
        UserDefaults.standard.set(morning.timeIntervalSince1970, forKey: "morning_reminder")
        UserDefaults.standard.set(evening.timeIntervalSince1970, forKey: "evening_reminder")
        
        NotificationManager.shared.scheduleReminders(morningTime: morning, eveningTime: evening)
    }
    
    private func createTime(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var isAuthenticated: Bool {
        calendarManager.isAuthenticated
    }
    
    func authenticate() {
        calendarManager.authenticate()
    }
}
