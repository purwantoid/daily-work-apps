import SwiftUI

public struct SettingsView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var morningTime: Date
    @State private var eveningTime: Date
    
    public init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        self._morningTime = State(initialValue: viewModel.morningReminderTime)
        self._eveningTime = State(initialValue: viewModel.eveningReminderTime)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            HStack {
                Text("Reminder Settings")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 8)
            
            VStack(spacing: 20) {
                // Morning Setting
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Morning Reminder ☕️")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                        Text("When should we remind you to plan your day?")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    DatePicker("", selection: $morningTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .padding()
                .background(Color.primary.opacity(0.03))
                .cornerRadius(12)
                
                // Evening Setting
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Evening Retro 🌙")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                        Text("When should we ask about your accomplishments?")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    DatePicker("", selection: $eveningTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .padding()
                .background(Color.primary.opacity(0.03))
                .cornerRadius(12)
            }
            
            Spacer()
            
            // Save Button
            Button(action: {
                viewModel.updateReminderSettings(morning: morningTime, evening: eveningTime)
                dismiss()
            }) {
                HStack {
                    Spacer()
                    Text("Save Settings")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Spacer()
                }
                .padding(.vertical, 14)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding(30)
        .frame(width: 385, height: 400)
        .background(Color.white)
    }
}
