#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#endif

// Global array to store clipboard history
var clipboardHistory: [String] = []

// Function to get the current content of the clipboard
func getClipboardContent() -> String? {
    #if os(macOS)
    let pasteboard = NSPasteboard.general
    return pasteboard.string(forType: .string)
    #elseif os(iOS)
    let pasteboard = UIPasteboard.general
    return pasteboard.string
    #endif
}

// Function to store the clipboard content in the history
func storeClipboardContent() {
    if let content = getClipboardContent(), !content.isEmpty {
        // Check if the content already exists in the clipboard history
        if let existingIndex = clipboardHistory.firstIndex(of: content) {
            // If it exists, remove it from its current position
            clipboardHistory.remove(at: existingIndex)
        }
        // Insert the content at the top of the list
        clipboardHistory.insert(content, at: 0)
        saveClipboardHistory()
        NotificationCenter.default.post(name: NSNotification.Name("ClipboardHistoryUpdated"), object: nil)
    }
}


func saveClipboardHistory() {
    UserDefaults.standard.set(clipboardHistory, forKey: "clipboardHistory")
}

class ClipboardMonitor {
    private var lastChangeCount: Int = 0

    init() {
        #if os(iOS)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        #elseif os(macOS)
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkClipboard), userInfo: nil, repeats: true)
        #endif
    }

    @objc func appDidBecomeActive() {
        checkClipboard()
    }

    @objc func checkClipboard() {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        #elseif os(iOS)
        let pasteboard = UIPasteboard.general
        #endif

        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            storeClipboardContent()
        }
    }
}
