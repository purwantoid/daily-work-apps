import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "calendar.badge.clock", accessibilityDescription: "Work Logger")
            button.action = #selector(toggleWindow(_:))
        }
        
        setupWindow()
    }
    
    private func setupWindow() {
        let mainView = MainView()
        let hostingController = NSHostingController(rootView: mainView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 385, height: 900),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.contentViewController = hostingController
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        self.window = window
    }
    
    @objc func toggleWindow(_ sender: AnyObject?) {
        guard let window = window else { return }
        
        if window.isVisible {
            window.orderOut(nil)
        } else {
            positionWindowInTopRight()
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
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
