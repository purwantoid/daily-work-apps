import Foundation
import AuthenticationServices

public class CalendarManager: ObservableObject {
    @Published public var events: [WorkEvent] = []
    @Published public var isAuthenticated = false
    @Published public var activeTrackingEvent: WorkEvent?
    
    // Configuration is now handled in Config.swift
    private let clientID = Config.googleClientID
    private let redirectURI = Config.googleRedirectURI
    private let authURL = "https://accounts.google.com/o/oauth2/v2/auth"
    private let tokenURL = "https://oauth2.googleapis.com/token"
    private let scopes = "https://www.googleapis.com/auth/calendar.events"
    
    private var accessToken: String?
    private let googleService = GoogleCalendarService()
    private let authContext = AuthPresentationContext()
    
    public init() {
        loadEvents()
    }
    
    private func loadEvents() {
        events = DatabaseManager.shared.fetchEvents()
    }
    
    func authenticate() {
        // Construct the full auth URL
        var components = URLComponents(string: authURL)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopes),
            URLQueryItem(name: "prompt", value: "consent"),
            URLQueryItem(name: "access_type", value: "offline")
        ]
        
        guard let url = components.url else { return }
        
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: Config.googleAuthScheme) { callbackURL, error in
            if let error = error {
                print("Auth Error: \(error.localizedDescription)")
                return
            }
            
            guard let callbackURL = callbackURL,
                  let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true),
                  let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                return
            }
            
            self.exchangeCodeForToken(code: code)
        }
        
        session.presentationContextProvider = authContext
        session.start()
    }
    
    private func exchangeCodeForToken(code: String) {
        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"
        let body = "code=\(code)&client_id=\(clientID)&redirect_uri=\(redirectURI)&grant_type=authorization_code"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let token = json["access_token"] as? String {
                    DispatchQueue.main.async {
                        self.accessToken = token
                        self.isAuthenticated = true
                    }
                }
            }
        }.resume()
    }
    
    func logWork(title: String, notes: String?, type: EventType) {
        if activeTrackingEvent != nil {
            endTracking() // Changed from pause to end for sync purposes
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
        events.insert(newEvent, at: 0)
        DatabaseManager.shared.saveEvent(newEvent)
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
        DatabaseManager.shared.updateEvent(event)
    }
    
    func resumeTracking(event toResume: WorkEvent? = nil) {
        let event = toResume ?? activeTrackingEvent
        guard var targetEvent = event else { return }
        
        // If we are resuming a different task, end the current active one first
        if activeTrackingEvent != nil && activeTrackingEvent?.id != targetEvent.id {
            endTracking()
        }
        
        targetEvent.isPaused = false
        targetEvent.lastStartTime = Date()
        
        // Update in list
        if let index = events.firstIndex(where: { $0.id == targetEvent.id }) {
            events[index] = targetEvent
        }
        activeTrackingEvent = targetEvent
        DatabaseManager.shared.updateEvent(targetEvent)
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
        DatabaseManager.shared.updateEvent(event)
        
        /*
        // Sync with Google Calendar if authenticated
        if isAuthenticated, let token = accessToken {
            let finalEvent = event
            Task {
                try? await googleService.createEvent(token: token, event: finalEvent)
            }
        }
        */
        
        activeTrackingEvent = nil
    }
    
    func deleteEvent(_ event: WorkEvent) {
        if activeTrackingEvent?.id == event.id {
            activeTrackingEvent = nil
        }
        events.removeAll(where: { $0.id == event.id })
        DatabaseManager.shared.deleteEvent(id: event.id)
    }
    
    func updateEvent(_ event: WorkEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        }
        if activeTrackingEvent?.id == event.id {
            activeTrackingEvent = event
        }
        DatabaseManager.shared.updateEvent(event)
    }
}

// MARK: - Presentation Context
class AuthPresentationContext: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return NSApplication.shared.windows.first { $0.isVisible } ?? NSWindow()
    }
}
