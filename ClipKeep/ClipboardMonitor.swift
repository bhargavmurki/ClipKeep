#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#endif
import SwiftData

func getClipboardContent() -> String? {
    #if os(macOS)
    let pasteboard = NSPasteboard.general
    return pasteboard.string(forType: .string)
    #elseif os(iOS)
    let pasteboard = UIPasteboard.general
    return pasteboard.string
    #endif
}

class ClipboardMonitor {
    private var lastChangeCount: Int = 0
    private let modelContext: ModelContext

    init(container: ModelContainer) {
        self.modelContext = ModelContext(container)

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

        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        guard let content = getClipboardContent(), !content.isEmpty else { return }
        persist(content: content)
    }

    private func persist(content: String) {
        do {
            let descriptor = FetchDescriptor<Item>(
                predicate: #Predicate { $0.content == content }
            )
            if let existing = try modelContext.fetch(descriptor).first {
                existing.copyCount += 1
                existing.createdAt = Date()
            } else {
                let item = Item(content: content, createdAt: Date(), source: "Clipboard", copyCount: 1)
                modelContext.insert(item)
            }
            try modelContext.save()

            NotificationCenter.default.post(name: NSNotification.Name("ClipboardHistoryUpdated"), object: nil)
        } catch {
            print("Failed to persist clipboard content: \(error)")
        }
    }
}
