import AppKit
import SwiftUI
import Combine
import WorkLoggerLib

class FocusablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        self.isFloatingPanel = true
        self.becomesKeyOnlyIfNeeded = false
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var window: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        // Listen for notification to show window
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowWorkLoggerWindow"), object: nil, queue: .main) { _ in
            self.showWindow()
        }
        
        // Request notification permissions
        NotificationManager.shared.requestPermissions()
        
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "calendar.badge.clock", accessibilityDescription: "Work Logger")
            button.action = #selector(toggleWindow(_:))
            button.imagePosition = .imageLeft
        }
        
        // Observe ViewModel for menu bar updates
        MainViewModel.shared.$currentTime
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateMenuBarTitle()
            }
            .store(in: &cancellables)
        
        setupWindow()
    }
    
    private func updateMenuBarTitle() {
        guard let button = statusItem?.button else { return }
        
        if let activeEvent = MainViewModel.shared.activeTrackingEvent, !activeEvent.isPaused {
            let title = activeEvent.title.count > 15 ? String(activeEvent.title.prefix(12)) + "..." : activeEvent.title
            button.title = "[\(title)] \(activeEvent.menuBarDuration)"
            button.font = .monospacedDigitSystemFont(ofSize: 12, weight: .semibold)
        } else {
            button.title = ""
        }
    }
    
    private func setupWindow() {
        let mainView = MainView()
        let hostingController = NSHostingController(rootView: mainView)
        
        let window = FocusablePanel(
            contentRect: NSRect(x: 0, y: 0, width: 385, height: 900),
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless, .hudWindow],
            backing: .buffered,
            defer: false
        )
        
        window.contentViewController = hostingController
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        self.window = window
    }
    
    @objc func toggleWindow(_ sender: AnyObject?) {
        guard let window = window else { return }
        
        if window.isVisible {
            window.orderOut(nil)
        } else {
            showWindow()
        }
    }
    
    public func showWindow() {
        guard let window = window else { return }
        positionWindowInTopRight()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func positionWindowInTopRight() {
        guard let window = window, let screen = NSScreen.main else { return }
        
        let screenFrame = screen.visibleFrame
        let windowFrame = window.frame
        
        let x = screenFrame.maxX - windowFrame.width - 20
        let y = screenFrame.maxY - windowFrame.height - 10
        
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
