import Foundation
import AuthenticationServices

class CalendarManager: ObservableObject {
    @Published var events: [WorkEvent] = []
    @Published var isAuthenticated = false
    @Published var activeTrackingEvent: WorkEvent?
    
    private let clientID = "YOUR_CLIENT_ID.apps.googleusercontent.com" // Needs to be replaced by user
    private let redirectURI = "com.googleusercontent.apps.YOUR_CLIENT_ID:/oauth2redirect"
    private let authURL = "https://accounts.google.com/o/oauth2/v2/auth"
    private let tokenURL = "https://oauth2.googleapis.com/token"
    private let scopes = "https://www.googleapis.com/auth/calendar.events"
    
    private var accessToken: String?
    
    init() {
        loadMockData()
    }
    
    func authenticate() {
        self.isAuthenticated = true
    }
    
    func logWork(title: String, notes: String?, type: EventType) {
        if activeTrackingEvent != nil {
            pauseTracking()
        }
        startTracking(title: title, notes: notes, type: type)
    }
    
    func startTracking(title: String, notes: String?, type: EventType) {
        var newEvent = WorkEvent(
            title: title,
            notes: notes,
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600), // Default 1h
            type: type
        )
        newEvent.lastStartTime = Date()
        activeTrackingEvent = newEvent
        events.append(newEvent)
    }
    
    func pauseTracking() {
        guard var event = activeTrackingEvent, !event.isPaused else { return }
        if let lastStart = event.lastStartTime {
            event.totalAccumulatedDuration += Date().timeIntervalSince(lastStart)
        }
        event.isPaused = true
        event.lastStartTime = nil
        
        // Update in list
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        }
        activeTrackingEvent = event
    }
    
    func resumeTracking(event toResume: WorkEvent? = nil) {
        let event = toResume ?? activeTrackingEvent
        guard var targetEvent = event else { return }
        
        // If we are resuming a different task, pause the current active one first
        if activeTrackingEvent != nil && activeTrackingEvent?.id != targetEvent.id {
            pauseTracking()
        }
        
        targetEvent.isPaused = false
        targetEvent.lastStartTime = Date()
        
        // Update in list
        if let index = events.firstIndex(where: { $0.id == targetEvent.id }) {
            events[index] = targetEvent
        }
        activeTrackingEvent = targetEvent
    }
    
    func endTracking() {
        guard var event = activeTrackingEvent else { return }
        
        // Finalize duration
        if !event.isPaused, let lastStart = event.lastStartTime {
            event.totalAccumulatedDuration += Date().timeIntervalSince(lastStart)
        }
        
        event.endTime = Date()
        event.isPaused = true // Mark as finished/stopped
        event.lastStartTime = nil
        
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        }
        activeTrackingEvent = nil
    }
    
    private func loadMockData() {
        let today = Calendar.current.startOfDay(for: Date())
        events = [
            WorkEvent(title: "Daily Standup", notes: "Sprint update", startTime: today.addingTimeInterval(9*3600), endTime: today.addingTimeInterval(9.25*3600), type: .meeting),
            WorkEvent(title: "Sprint Planning", notes: "Plan for next sprint", startTime: today.addingTimeInterval(10*3600), endTime: today.addingTimeInterval(11*3600), type: .planning),
            WorkEvent(title: "1:1 with Sarah", notes: "Performance review", startTime: today.addingTimeInterval(14*3600), endTime: today.addingTimeInterval(14.5*3600), type: .meeting),
            WorkEvent(title: "Code Review Session", notes: "Review PR #123", startTime: today.addingTimeInterval(16*3600), endTime: today.addingTimeInterval(16.75*3600), type: .codeReview)
        ]
    }
}
