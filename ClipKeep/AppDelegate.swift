import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSSearchFieldDelegate {
    var statusItem: NSStatusItem?
    var searchField: NSSearchField?
    let menuWidth: CGFloat = 200
    var clipboardHistory: [String] = []

    var filteredClipboardHistory: [String] {
        guard let query = searchField?.stringValue, !query.isEmpty else {
            return clipboardHistory
        }
        return clipboardHistory.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        loadClipboardHistory()
        startClipboardMonitoring()
        NotificationCenter.default.addObserver(self, selector: #selector(updateMenu), name: NSNotification.Name("ClipboardHistoryUpdated"), object: nil)
    }

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "📋"
        statusItem?.button?.target = self
        statusItem?.button?.action = #selector(showMenu)

        // Initialize the search field once
        searchField = NSSearchField(frame: NSRect(x: 0, y: 0, width: 100, height: 25))
        searchField?.placeholderString = "Search..."
        searchField?.delegate = self
    }

    @objc func showMenu() {
        updateMenu()
        statusItem?.button?.performClick(nil)
    }

    @objc func updateMenu() {
        let menu = NSMenu()

        // Add the search field as the first item
        let searchItem = NSMenuItem()
        searchItem.view = searchField
        menu.addItem(searchItem)

        // Add clipboard history items based on search query
        for (index, item) in filteredClipboardHistory.enumerated() {
            let truncatedItem = String(item.prefix(50))
            let menuItem = NSMenuItem(title: truncatedItem, action: #selector(copyItem(_:)), keyEquivalent: "")
            menuItem.tag = index
            menu.addItem(menuItem)
        }

        // Add a separator
        menu.addItem(NSMenuItem.separator())

        // Add "Clear All" button
        let clearAllItem = NSMenuItem(title: "Clear All", action: #selector(clearAllHistory), keyEquivalent: "C")
        clearAllItem.keyEquivalentModifierMask = [.command, .shift]
        menu.addItem(clearAllItem)

        // Add a quit option
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    func controlTextDidChange(_ obj: Notification) {
        updateMenu()
    }

    @objc func copyItem(_ sender: NSMenuItem) {
        let item = filteredClipboardHistory[sender.tag]
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item, forType: .string)
    }

    @objc func clearAllHistory() {
        clipboardHistory.removeAll()
        saveClipboardHistory()
        updateMenu()
        NotificationCenter.default.post(name: NSNotification.Name("ClipboardHistoryUpdated"), object: nil)
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }

    // Clipboard Monitoring
    var lastChangeCount: Int = 0
    var timer: Timer?

    func startClipboardMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkForClipboardChanges()
        }
    }

    func checkForClipboardChanges() {
        let currentChangeCount = NSPasteboard.general.changeCount
        if currentChangeCount != lastChangeCount {
            lastChangeCount = currentChangeCount
            if let items = NSPasteboard.general.pasteboardItems,
               let string = items.first?.string(forType: .string) {
                updateClipboardHistory(with: string)
            }
        }
    }

    func updateClipboardHistory(with newItem: String) {
        if let index = clipboardHistory.firstIndex(of: newItem) {
            clipboardHistory.remove(at: index)
        }
        clipboardHistory.insert(newItem, at: 0)
        saveClipboardHistory()
        NotificationCenter.default.post(name: NSNotification.Name("ClipboardHistoryUpdated"), object: nil)
    }

    func saveClipboardHistory() {
        UserDefaults.standard.set(clipboardHistory, forKey: "ClipboardHistory")
    }

    func loadClipboardHistory() {
        if let savedHistory = UserDefaults.standard.stringArray(forKey: "ClipboardHistory") {
            clipboardHistory = savedHistory
        }
    }
}
