import Cocoa
import SwiftData
import CryptoKit

class ClipboardMonitor {
    private var lastChangeCount: Int = 0
    private let modelContext: ModelContext

    init(container: ModelContainer) {
        self.modelContext = ModelContext(container)
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkClipboard), userInfo: nil, repeats: true)
    }

    @objc func checkClipboard() {
        let pasteboard = NSPasteboard.general

        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        guard let entry = readClipboardEntry(from: pasteboard) else { return }
        persist(entry: entry)
    }

    private func readClipboardEntry(from pasteboard: NSPasteboard) -> (kind: ItemKind, content: String?, imageData: Data?, fingerprint: String)? {
        if let content = pasteboard.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines), !content.isEmpty {
            return (.text, content, nil, content)
        }

        if let data = pasteboard.data(forType: .png) ?? pasteboard.data(forType: .tiff) {
            let hash = SHA256.hash(data: data)
            let fingerprint = hash.map { String(format: "%02x", $0) }.joined()
            return (.image, nil, data, fingerprint)
        }

        return nil
    }

    private func persist(entry: (kind: ItemKind, content: String?, imageData: Data?, fingerprint: String)) {
        do {
            let fp = entry.fingerprint
            let descriptor = FetchDescriptor<Item>(
                predicate: #Predicate { $0.fingerprint == fp }
            )
            if let existing = try modelContext.fetch(descriptor).first {
                existing.copyCount += 1
                existing.createdAt = Date()
            } else {
                let item = Item(kind: entry.kind,
                                content: entry.content,
                                imageData: entry.imageData,
                                fingerprint: entry.fingerprint,
                                createdAt: Date(),
                                source: "Clipboard",
                                copyCount: 1)
                modelContext.insert(item)
            }
            try modelContext.save()

            NotificationCenter.default.post(name: NSNotification.Name("ClipboardHistoryUpdated"), object: nil)
        } catch {
            print("Failed to persist clipboard content: \(error)")
        }
    }
}
