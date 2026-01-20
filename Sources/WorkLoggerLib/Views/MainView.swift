import SwiftUI
import AppKit

public struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @Namespace private var animation
    @FocusState private var isTitleFocused: Bool
    @State private var showingSettings = false
    
    public init() {}
    
    public enum Tab {
        case timeline, summary, tomorrow
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Work Logger")
                        .font(.custom("JetBrains Mono", size: 20)).bold()
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.15))
                    
                    Text(Date().formatted(.dateTime.weekday(.abbreviated).month().day()))
                        .font(.custom("JetBrains Mono", size: 11))
                        .foregroundColor(.black.opacity(0.4))
                }
                
                Spacer()
                
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.3))
                }
                .buttonStyle(.plain)
                .padding(.trailing, 8)
                .sheet(isPresented: $showingSettings) {
                    SettingsView(viewModel: viewModel)
                }
                
                Button(action: { NSApp.terminate(nil) }) {
                    Image(systemName: "power")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red.opacity(0.6))
                        .padding(8)
                        .background(Color.red.opacity(0.05))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Quit Application")
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Quick Log Input Area
            VStack(spacing: 16) {
            // Elegant Dropdown-style Menu
            HStack {
                Menu {
                    ForEach(EventType.allCases.filter { $0 != .workBlock }) { type in
                        Button(action: { viewModel.selectedType = type }) {
                            Text(type.rawValue)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.selectedType.icon)
                            .font(.system(size: 11))
                            .foregroundColor(.blue.opacity(0.8))
                        
                        Text(viewModel.selectedType.rawValue)
                            .font(.custom("JetBrains Mono", size: 13)).bold()
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(6)
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                
                Spacer()
            }
            .padding(.horizontal, 16) // Align with the internal padding of the card below
            .padding(.bottom, -8)
            
            // Inputs Card
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "pencil.line")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black.opacity(0.4))
                            .padding(.top, 2)
                        
                        TextField("Task title...", text: $viewModel.quickLogText, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.custom("JetBrains Mono", size: 15)).bold()
                            .foregroundColor(.black.opacity(0.8))
                            .focused($isTitleFocused)
                            .lineLimit(1...3)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isTitleFocused = true
                    }
                    
                    Divider().opacity(0.05).padding(.horizontal, 16)
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.3))
                            .padding(.top, 3)
                        
                        TextField("Add notes or description (optional)", text: $viewModel.quickLogNotes, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.custom("JetBrains Mono", size: 12))
                            .foregroundColor(.black.opacity(0.6))
                            .lineLimit(1...5)
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
                    .font(.custom("JetBrains Mono", size: 13)).bold()
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .background(viewModel.quickLogText.isEmpty ? Color.blue.opacity(0.3) : Color.blue)
                    .cornerRadius(10)
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
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(active.title)
                            .font(.custom("JetBrains Mono", size: 14)).bold()
                            .foregroundColor(.black.opacity(0.8))
                        Text(active.isPaused ? "Paused" : "Tracking...")
                            .font(.custom("JetBrains Mono", size: 11))
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
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("No active task")
                            .font(.custom("JetBrains Mono", size: 14)).bold()
                            .foregroundColor(.black.opacity(0.8))
                        Text("Log something to start tracking")
                            .font(.custom("JetBrains Mono", size: 11))
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
            .padding(12)
            .background(Color.primary.opacity(0.025))
            .cornerRadius(16)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            
            // Tab Switcher
            HStack(spacing: 0) {
                TabButton(title: "Timeline", icon: "timer.square", isSelected: viewModel.selectedTab == .timeline, namespace: animation) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { viewModel.selectedTab = .timeline }
                }
                
                TabButton(title: "Summary", icon: "doc.plaintext.fill", isSelected: viewModel.selectedTab == .summary, namespace: animation) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { viewModel.selectedTab = .summary }
                }
                
                TabButton(title: "Tomorrow", icon: "calendar.badge.plus", isSelected: viewModel.selectedTab == .tomorrow, namespace: animation) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { viewModel.selectedTab = .tomorrow }
                }
            }
            .padding(4)
            .background(Color.primary.opacity(0.04))
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            
            // Content
            Group {
                if viewModel.selectedTab == .summary {
                    SummaryContentView(
                        events: viewModel.events,
                        onResume: { event in withAnimation { viewModel.resumeTracking(event: event) } },
                        onDelete: { event in withAnimation { viewModel.deleteEvent(event) } },
                        onUpdate: { event in withAnimation { viewModel.updateEvent(event) } }
                    )
                    .transition(.opacity)
                } else if viewModel.selectedTab == .tomorrow {
                    TomorrowPlanView(
                        todos: viewModel.tomorrowTodos,
                        todoTitle: $viewModel.todoTitle,
                        todoNotes: $viewModel.todoNotes,
                        onAdd: { title, notes in withAnimation { viewModel.addTodo(title: title, notes: notes) } },
                        onToggle: { todo in withAnimation { viewModel.toggleTodo(todo) } },
                        onDelete: { todo in withAnimation { viewModel.deleteTodo(todo) } }
                    )
                    .transition(.opacity)
                } else {
                    TimelineContentView(
                        events: viewModel.events,
                        todayTodos: viewModel.todayTodos,
                        onResume: { event in withAnimation { viewModel.resumeTracking(event: event) } },
                        onDelete: { event in withAnimation { viewModel.deleteEvent(event) } },
                        onUpdate: { event in withAnimation { viewModel.updateEvent(event) } },
                        onStartTodo: { todo in withAnimation { viewModel.startTodoAsTask(todo) } }
                    )
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
            .font(.custom("JetBrains Mono", size: 10))
            .padding(.vertical, 16)
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTitleFocused = true
            }
        }
    }
}
