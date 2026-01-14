import SwiftUI

enum EventType: String, CaseIterable, Identifiable {
    case meeting = "Meeting"
    case task = "Task"
    case codeReview = "Code Review"
    case planning = "Planning"
    case others = "Others"
    case bounding = "Bounding"
    case workBlock = "Work Block" // Keep for legacy if needed
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .meeting: return "video.fill"
        case .task: return "pencil.line"
        case .codeReview: return "bolt.horizontal.fill"
        case .planning: return "calendar.badge.clock"
        case .others: return "ellipsis.circle"
        case .bounding: return "link"
        case .workBlock: return "hammer.fill"
        }
    }
    
    var color: Color {
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

struct WorkEvent: Identifiable {
    let id = UUID()
    var title: String
    var notes: String?
    var startTime: Date
    var endTime: Date
    var type: EventType
    
    // Pause/Resume support
    var isPaused: Bool = false
    var totalAccumulatedDuration: TimeInterval = 0
    var lastStartTime: Date?
    
    var duration: TimeInterval {
        var currentSessionDuration: TimeInterval = 0
        if let lastStart = lastStartTime, !isPaused {
            currentSessionDuration = Date().timeIntervalSince(lastStart)
        }
        return totalAccumulatedDuration + currentSessionDuration
    }
    
    var durationFormatted: String {
        let minutes = Int(duration / 60)
        if minutes >= 60 {
            return "\(minutes / 60)h \(minutes % 60)m"
        }
        return "\(minutes) min"
    }
    
    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH.mm"
        return formatter.string(from: startTime)
    }
}
