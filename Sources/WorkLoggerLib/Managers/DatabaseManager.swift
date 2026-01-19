import Foundation
import SQLite
import SwiftUI

public class DatabaseManager {
    public static let shared = DatabaseManager()
    private var db: Connection?
    
    // Table
    private let workEvents = Table("work_events")
    
    // Columns
    private let id = Expression<String>("id")
    private let title = Expression<String>("title")
    private let notes = Expression<String?>("notes")
    private let startTime = Expression<Double>("start_time")
    private let endTime = Expression<Double>("end_time")
    private let type = Expression<String>("type")
    private let isPaused = Expression<Bool>("is_paused")
    private let totalAccumulatedDuration = Expression<Double>("total_accumulated_duration")
    private let lastStartTime = Expression<Double?>("last_start_time")
    
    // Todo Table
    private let todoItems = Table("todo_items")
    private let todoId = Expression<String>("id")
    private let todoTitle = Expression<String>("title")
    private let todoNotes = Expression<String?>("notes")
    private let todoTargetDate = Expression<Double>("target_date")
    private let todoIsCompleted = Expression<Bool>("is_completed")
    
    private init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
            let dbPath = "\(path)/WorkLogger"
            
            try? FileManager.default.createDirectory(atPath: dbPath, withIntermediateDirectories: true, attributes: nil)
            
            db = try Connection("\(dbPath)/db.sqlite3")
            createTable()
        } catch {
            print("Database connection error: \(error)")
        }
    }
    
    private func createTable() {
        guard let db = db else { return }
        
        do {
            try db.run(workEvents.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(title)
                t.column(notes)
                t.column(startTime)
                t.column(endTime)
                t.column(type)
                t.column(isPaused)
                t.column(totalAccumulatedDuration)
                t.column(lastStartTime)
            })
            
            try db.run(todoItems.create(ifNotExists: true) { t in
                t.column(todoId, primaryKey: true)
                t.column(todoTitle)
                t.column(todoNotes)
                t.column(todoTargetDate)
                t.column(todoIsCompleted)
            })
            
            // Migration for existing table
            _ = try? db.run(todoItems.addColumn(todoNotes))
        } catch {
            print("Table creation error: \(error)")
        }
    }
    
    func saveEvent(_ event: WorkEvent) {
        guard let db = db else { return }
        
        do {
            let insert = workEvents.insert(
                id <- event.id.uuidString,
                title <- event.title,
                notes <- event.notes,
                startTime <- event.startTime.timeIntervalSince1970,
                endTime <- event.endTime.timeIntervalSince1970,
                type <- event.type.rawValue,
                isPaused <- event.isPaused,
                totalAccumulatedDuration <- event.totalAccumulatedDuration,
                lastStartTime <- event.lastStartTime?.timeIntervalSince1970
            )
            try db.run(insert)
        } catch {
            print("Insert error: \(error)")
        }
    }
    
    func fetchEvents() -> [WorkEvent] {
        guard let db = db else { return [] }
        var events: [WorkEvent] = []
        
        do {
            for row in try db.prepare(workEvents) {
                let event = WorkEvent(
                    id: UUID(uuidString: row[id]) ?? UUID(),
                    title: row[title],
                    notes: row[notes],
                    startTime: Date(timeIntervalSince1970: row[startTime]),
                    endTime: Date(timeIntervalSince1970: row[endTime]),
                    type: EventType(rawValue: row[type]) ?? .others,
                    isPaused: row[isPaused],
                    totalAccumulatedDuration: row[totalAccumulatedDuration],
                    lastStartTime: row[lastStartTime] != nil ? Date(timeIntervalSince1970: row[lastStartTime]!) : nil
                )
                events.append(event)
            }
        } catch {
            print("Fetch error: \(error)")
        }
        
        return events.sorted(by: { $0.startTime > $1.startTime })
    }
    
    func updateEvent(_ event: WorkEvent) {
        guard let db = db else { return }
        let filteredEvent = workEvents.filter(id == event.id.uuidString)
        
        do {
            try db.run(filteredEvent.update(
                title <- event.title,
                notes <- event.notes,
                startTime <- event.startTime.timeIntervalSince1970,
                endTime <- event.endTime.timeIntervalSince1970,
                type <- event.type.rawValue,
                isPaused <- event.isPaused,
                totalAccumulatedDuration <- event.totalAccumulatedDuration,
                lastStartTime <- event.lastStartTime?.timeIntervalSince1970
            ))
        } catch {
            print("Update error: \(error)")
        }
    }
    
    func deleteEvent(id eventId: UUID) {
        guard let db = db else { return }
        let filteredEvent = workEvents.filter(id == eventId.uuidString)
        
        do {
            try db.run(filteredEvent.delete())
        } catch {
            print("Delete error: \(error)")
        }
    }
    // MARK: - Todo CRUD
    
    public func saveTodo(_ todo: TodoItem) {
        guard let db = db else { return }
        do {
            let insert = todoItems.insert(
                todoId <- todo.id.uuidString,
                todoTitle <- todo.title,
                todoNotes <- todo.notes,
                todoTargetDate <- todo.targetDate.timeIntervalSince1970,
                todoIsCompleted <- todo.isCompleted
            )
            try db.run(insert)
        } catch {
            print("Insert todo error: \(error)")
        }
    }
    
    public func fetchTodos(for date: Date) -> [TodoItem] {
        guard let db = db else { return [] }
        
        let startOfDay = Calendar.current.startOfDay(for: date).timeIntervalSince1970
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date))!.timeIntervalSince1970

        do {
            let query = todoItems.filter(todoTargetDate >= startOfDay && todoTargetDate < endOfDay)
            var items: [TodoItem] = []
            for item in try db.prepare(query) {
                if let uuid = UUID(uuidString: item[todoId]) {
                    items.append(TodoItem(
                        id: uuid,
                        title: item[todoTitle],
                        notes: item[todoNotes],
                        targetDate: Date(timeIntervalSince1970: item[todoTargetDate]),
                        isCompleted: item[todoIsCompleted]
                    ))
                }
            }
            return items
        } catch {
            print("Fetch todos error: \(error)")
            return []
        }
    }
    
    public func updateTodo(_ todo: TodoItem) {
        guard let db = db else { return }
        let item = todoItems.filter(todoId == todo.id.uuidString)
        do {
            try db.run(item.update(
                todoTitle <- todo.title,
                todoNotes <- todo.notes,
                todoTargetDate <- todo.targetDate.timeIntervalSince1970,
                todoIsCompleted <- todo.isCompleted
            ))
        } catch {
            print("Update todo error: \(error)")
        }
    }
    
    public func deleteTodo(id: UUID) {
        guard let db = db else { return }
        let item = todoItems.filter(todoId == id.uuidString)
        do {
            try db.run(item.delete())
        } catch {
            print("Delete todo error: \(error)")
        }
    }
}
