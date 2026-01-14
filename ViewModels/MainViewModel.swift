import SwiftUI
import Combine

class MainViewModel: ObservableObject {
    @Published var calendarManager = CalendarManager()
    @Published var selectedTab: MainView.Tab = .timeline
    @Published var quickLogText: String = ""
    @Published var quickLogNotes: String = ""
    @Published var selectedType: EventType = .task
    @Published var currentTime = Date()
    
    private var timer: AnyCancellable?
    
    init() {
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
