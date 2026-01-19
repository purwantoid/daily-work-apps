import SwiftUI
import Combine

public class MainViewModel: ObservableObject {
    @Published public var calendarManager = CalendarManager()
    @Published public var selectedTab: MainView.Tab = .timeline
    @Published public var quickLogText: String = ""
    @Published public var quickLogNotes: String = ""
    @Published public var selectedType: EventType = .task
    @Published public var currentTime = Date()
    
    private var timer: AnyCancellable?
    
    public init() {
        startTimer()
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
    
    var isAuthenticated: Bool {
        calendarManager.isAuthenticated
    }
    
    func authenticate() {
        calendarManager.authenticate()
    }
}
