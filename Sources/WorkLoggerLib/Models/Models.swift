import SwiftUI

public enum EventType: String, CaseIterable, Identifiable {
    case meeting = "Meeting"
    case task = "Task"
    case codeReview = "Code Review"
    case planning = "Planning"
    case others = "Others"
    case bounding = "Bounding"
    case workBlock = "Work Block" // Keep for legacy if needed
    
    public var id: String { self.rawValue }
    
    public var icon: String {
        switch self {
        case .meeting: return "video.bubble.left.fill"
        case .task: return "square.stack.3d.up.fill"
        case .codeReview: return "terminal.fill"
        case .planning: return "sparkles"
        case .others: return "circle.grid.3x3.fill"
        case .bounding: return "link.circle.fill"
        case .workBlock: return "timer"
        }
    }
    
    public var color: Color {
        switch self {
        case .meeting: return .purple
        case .task: return .blue
        case .codeReview: return .orange
        case .planning: return .green
        case .others: return .gray
        case .bounding: return .pink
        case .workBlock: return .blue
        }
    }
}

public struct WorkEvent: Identifiable {
    public var id: UUID = UUID()
    public var title: String
    public var notes: String?
    public var startTime: Date
    public var endTime: Date
    public var type: EventType
    
    // Pause/Resume support
    public var isPaused: Bool = false
    public var totalAccumulatedDuration: TimeInterval = 0
    public var lastStartTime: Date?
    
    public init(id: UUID = UUID(), title: String, notes: String? = nil, startTime: Date, endTime: Date, type: EventType, isPaused: Bool = false, totalAccumulatedDuration: TimeInterval = 0, lastStartTime: Date? = nil) {
        self.id = id
        self.title = title
        self.notes = notes
        self.startTime = startTime
        self.endTime = endTime
        self.type = type
        self.isPaused = isPaused
        self.totalAccumulatedDuration = totalAccumulatedDuration
        self.lastStartTime = lastStartTime
    }
    
    public var duration: TimeInterval {
        var currentSessionDuration: TimeInterval = 0
        if let lastStart = lastStartTime, !isPaused {
            currentSessionDuration = Date().timeIntervalSince(lastStart)
        }
        return totalAccumulatedDuration + currentSessionDuration
    }
    
    public var durationFormatted: String {
        let minutes = Int(duration / 60)
        if minutes >= 60 {
            return "\(minutes / 60)h \(minutes % 60)m"
        }
        return "\(minutes) min"
    }
    
    public var menuBarDuration: String {
        let totalSeconds = Int(duration)
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    public var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH.mm"
        return formatter.string(from: startTime)
    }
}

public struct TodoItem: Identifiable {
    public var id: UUID
    public var title: String
    public var notes: String?
    public var targetDate: Date
    public var isCompleted: Bool
    
    public init(id: UUID = UUID(), title: String, notes: String? = nil, targetDate: Date, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.notes = notes
        self.targetDate = targetDate
        self.isCompleted = isCompleted
    }
}
