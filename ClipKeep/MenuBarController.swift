import Cocoa
import SwiftUI
import SwiftData

final class MenuBarController {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
        self.popover = NSPopover()
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.doc.fill", accessibilityDescription: "ClipKeep")
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 380, height: 760)
        popover.contentViewController = NSHostingController(
            rootView: MenuBarView()
                .modelContainer(container)
        )
    }

    @objc func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            showPopover()
        }
    }

    func showPopover() {
        guard let button = statusItem.button else { return }
        NSApplication.shared.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
        popover.contentViewController?.view.window?.makeKey()
    }

    func closePopover() {
        popover.performClose(nil)
    }
}
