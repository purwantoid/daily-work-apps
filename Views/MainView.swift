import SwiftUI
import AppKit

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @Namespace private var animation
    
    enum Tab {
        case timeline, summary
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Work Logger")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.15))
                    
                    Text(Date().formatted(.dateTime.weekday(.abbreviated).month().day()))
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.black.opacity(0.4))
                }
                
                Spacer()
                
                Button(action: { viewModel.authenticate() }) {
                    HStack(spacing: 6) {
                        Image(systemName: viewModel.isAuthenticated ? "checkmark.circle.fill" : "link")
                        Text(viewModel.isAuthenticated ? "Google Sync Action" : "Connect Google")
                    }
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(viewModel.isAuthenticated ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                    .foregroundColor(viewModel.isAuthenticated ? .green : .blue)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 20)
            
            // Quick Log Input Area
            VStack(spacing: 16) {
                // Type Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(EventType.allCases.filter { $0 != .workBlock }) { type in
                            Button(action: { viewModel.selectedType = type }) {
                                Text(type.rawValue)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(viewModel.selectedType == type ? Color.blue.opacity(0.1) : Color.white)
                                    .foregroundColor(viewModel.selectedType == type ? .blue : .black.opacity(0.6))
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.02), radius: 3, x: 0, y: 1)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(viewModel.selectedType == type ? Color.blue.opacity(0.2) : Color.black.opacity(0.05), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.horizontal, -24) // Allow scroll to edges
                
                // Inputs Card
                VStack(spacing: 0) {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "pencil.line")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black.opacity(0.4))
                        
                        TextField("Task title...", text: $viewModel.quickLogText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.black.opacity(0.8))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    
                    Divider().opacity(0.05).padding(.horizontal, 16)
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.3))
                            .padding(.top, 3)
                        
                        TextField("Add notes or description (optional)", text: $viewModel.quickLogNotes)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.black.opacity(0.6))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
                
                // Submit Action
                Button(action: { viewModel.handleQuickLog() }) {
                    HStack {
                        Spacer()
                        Image(systemName: "play.fill")
                        Text("Start Tracking")
                        Spacer()
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .background(viewModel.quickLogText.isEmpty ? Color.blue.opacity(0.3) : Color.blue)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.quickLogText.isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            // Tracking Indicator (Start/Stop/End)
            HStack(spacing: 16) {
                if let active = viewModel.activeTrackingEvent {
                    Button(action: {
                        withAnimation {
                            if active.isPaused {
                                viewModel.resumeTracking()
                            } else {
                                viewModel.pauseTracking()
                            }
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(active.isPaused ? Color.blue.opacity(0.1) : Color.primary.opacity(0.04))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: active.isPaused ? "play.fill" : "pause.fill")
                                .font(.system(size: 14))
                                .foregroundColor(active.isPaused ? .blue : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(active.title)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.black.opacity(0.8))
                        Text(active.isPaused ? "Paused" : "Tracking...")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(active.isPaused ? .blue.opacity(0.6) : .black.opacity(0.5))
                    }
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.primary.opacity(0.04))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "pause.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("No active task")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.black.opacity(0.8))
                        Text("Log something to start tracking")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.black.opacity(0.5))
                    }
                }
                
                Spacer()
                
                if viewModel.activeTrackingEvent != nil {
                    HStack(spacing: 8) {
                        Button(action: {
                            if let active = viewModel.activeTrackingEvent {
                                let content = "[\(active.type.rawValue)] \(active.title)\(active.notes != nil ? " - \(active.notes!)" : "") (\(active.durationFormatted))"
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(content, forType: .string)
                            }
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .padding(8)
                                .background(Color.blue.opacity(0.05))
                                .foregroundColor(.blue.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            withAnimation { viewModel.endTracking() }
                        }) {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 14))
                                .padding(8)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .background(Color.primary.opacity(0.025))
            .cornerRadius(20)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            // Tab Switcher
            HStack(spacing: 0) {
                TabButton(title: "Timeline", icon: "calendar", isSelected: viewModel.selectedTab == .timeline, namespace: animation) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { viewModel.selectedTab = .timeline }
                }
                
                TabButton(title: "Summary", icon: "list.bullet.indent", isSelected: viewModel.selectedTab == .summary, namespace: animation) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { viewModel.selectedTab = .summary }
                }
            }
            .padding(6)
            .background(Color.primary.opacity(0.04))
            .cornerRadius(18)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            // Content
            Group {
                if viewModel.selectedTab == .summary {
                    SummaryContentView(events: viewModel.events) { event in
                        withAnimation { viewModel.resumeTracking(event: event) }
                    }
                    .transition(.opacity)
                } else {
                    TimelineContentView(events: viewModel.events) { event in
                        withAnimation { viewModel.resumeTracking(event: event) }
                    }
                    .transition(.opacity)
                }
            }
            .frame(maxHeight: .infinity)
            
            // Footer
            HStack {
                Text("Press")
                    .foregroundColor(.secondary)
                Text("⌘ K")
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(5)
                Text("to quick log from anywhere")
                    .foregroundColor(.secondary)
            }
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .padding(.vertical, 20)
        }
        .background(
            ZStack {
                Color(red: 0.98, green: 0.96, blue: 1.0) // Soft white-pink base
                LinearGradient(colors: [
                    Color(red: 0.98, green: 0.95, blue: 1.0),
                    Color(red: 0.99, green: 0.98, blue: 1.0)
                ], startPoint: .top, endPoint: .bottom)
            }
            .edgesIgnoringSafeArea(.all)
        )
        .cornerRadius(28)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .preferredColorScheme(.light)
        .frame(width: 385, height: 900)
        .textSelection(.enabled)
    }
}
