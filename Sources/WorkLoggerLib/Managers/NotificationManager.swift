import UserNotifications
import AppKit

public class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationManager()
    
    private override init() {
        super.init()
        // Gracefully handle cases where the app is not running as a proper .app bundle (e.g., swift run)
        if Bundle.main.bundleIdentifier != nil {
            UNUserNotificationCenter.current().delegate = self
        } else {
            print("Warning: Running without a bundle identifier. Notifications will be disabled.")
        }
    }
    
    public func requestPermissions() {
        guard Bundle.main.bundleIdentifier != nil else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permissions granted.")
                self.scheduleReminders()
            } else if let error = error {
                print("Notification permissions error: \(error)")
            }
        }
    }
    
    public func scheduleReminders(morningTime: Date? = nil, eveningTime: Date? = nil) {
        guard Bundle.main.bundleIdentifier != nil else { return }
        
        // Clear existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Get times from parameters or UserDefaults or Defaults
        let morning = morningTime ?? getStoredTime(for: "morning_reminder") ?? createTime(hour: 10, minute: 0)
        let evening = eveningTime ?? getStoredTime(for: "evening_reminder") ?? createTime(hour: 18, minute: 0)
        
        let morningComponents = Calendar.current.dateComponents([.hour, .minute], from: morning)
        let eveningComponents = Calendar.current.dateComponents([.hour, .minute], from: evening)
        
        // 10:00 AM Morning Reminder (Default)
        scheduleNotification(
            id: "morning_reminder",
            title: "Morning Planning ☕️",
            body: "Time to plan your day! What are your goals for today?",
            hour: morningComponents.hour ?? 10,
            minute: morningComponents.minute ?? 0
        )
        
        // 06:00 PM Evening Retro (Default)
        scheduleNotification(
            id: "evening_retro",
            title: "Daily Retro 🌙",
            body: "Great job today! What did you accomplish? Any obstacles? Plan for tomorrow?",
            hour: eveningComponents.hour ?? 18,
            minute: eveningComponents.minute ?? 0
        )
    }
    
    private func getStoredTime(for key: String) -> Date? {
        let timestamp = UserDefaults.standard.double(forKey: key)
        return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
    }
    
    private func createTime(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
    
    private func scheduleNotification(id: String, title: String, body: String, hour: Int, minute: Int) {
        guard Bundle.main.bundleIdentifier != nil else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification \(id): \(error)")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification click - open the app via NotificationCenter to avoid target dependency issues
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("ShowWorkLoggerWindow"), object: nil)
        }
        completionHandler()
    }
}
