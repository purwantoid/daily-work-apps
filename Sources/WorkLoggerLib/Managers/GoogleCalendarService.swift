import Foundation

class GoogleCalendarService {
    private let calendarURL = "https://www.googleapis.com/calendar/v3/calendars/primary/events"
    
    func createEvent(token: String, event: WorkEvent) async throws {
        var request = URLRequest(url: URL(string: calendarURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let formatter = ISO8601DateFormatter()
        
        // Finalize duration if not already done
        let endTime = event.endTime
        
        let body: [String: Any] = [
            "summary": "[\(event.type.rawValue)] \(event.title)",
            "description": event.notes ?? "",
            "start": ["dateTime": formatter.string(from: event.startTime)],
            "end": ["dateTime": formatter.string(from: endTime)]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No error details"
            print("Google Calendar API Error: \(errorBody)")
            throw NSError(domain: "GoogleCalendarService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create event"])
        }
    }
}
