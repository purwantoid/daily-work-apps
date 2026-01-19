import XCTest
@testable import WorkLoggerLib

final class WorkLoggerTests: XCTestCase {
    var calendarManager: CalendarManager!
    
    override func setUp() {
        super.setUp()
        calendarManager = CalendarManager()
    }
    
    override func tearDown() {
        calendarManager = nil
        super.tearDown()
    }
    
    func testWorkEventDuration() {
        let startTime = Date().addingTimeInterval(-3600) // 1 hour ago
        let endTime = Date()
        let event = WorkEvent(
            title: "Test Task",
            startTime: startTime,
            endTime: endTime,
            type: .task,
            totalAccumulatedDuration: 3600
        )
        
        XCTAssertEqual(event.duration, 3600, "Duration should be 3600 seconds")
        XCTAssertEqual(event.durationFormatted, "1h 0m", "Formatted duration should be 1h 0m")
    }
    
    func testTrackingLogic() {
        // Start tracking
        calendarManager.startTracking(title: "New Task", notes: "Notes", type: .task)
        XCTAssertNotNil(calendarManager.activeTrackingEvent, "Active event should not be nil")
        XCTAssertEqual(calendarManager.activeTrackingEvent?.title, "New Task")
        
        // Pause tracking
        calendarManager.pauseTracking()
        XCTAssertTrue(calendarManager.activeTrackingEvent?.isPaused ?? false, "Event should be paused")
        
        // Resume tracking
        calendarManager.resumeTracking()
        XCTAssertFalse(calendarManager.activeTrackingEvent?.isPaused ?? true, "Event should be resumed")
        
        // End tracking
        calendarManager.endTracking()
        XCTAssertNil(calendarManager.activeTrackingEvent, "Active event should be nil after ending")
    }
    
    func testCRUDOperations() {
        let event = WorkEvent(
            title: "CRUD Task",
            startTime: Date(),
            endTime: Date().addingTimeInterval(1800),
            type: .meeting
        )
        
        // Save
        DatabaseManager.shared.saveEvent(event)
        
        // Fetch
        let events = DatabaseManager.shared.fetchEvents()
        XCTAssertTrue(events.contains(where: { $0.id == event.id }), "Fetched events should contain the saved event")
        
        // Update
        var updatedEvent = event
        updatedEvent.title = "Updated Task"
        DatabaseManager.shared.updateEvent(updatedEvent)
        let updatedEvents = DatabaseManager.shared.fetchEvents()
        XCTAssertTrue(updatedEvents.contains(where: { $0.title == "Updated Task" }), "Fetched events should reflect the update")
        
        // Delete
        DatabaseManager.shared.deleteEvent(id: event.id)
        let postDeleteEvents = DatabaseManager.shared.fetchEvents()
        XCTAssertFalse(postDeleteEvents.contains(where: { $0.id == event.id }), "Fetched events should not contain the deleted event")
    }
}
