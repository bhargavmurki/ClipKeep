import SwiftUI
import SwiftData

@main
struct ClipKeepApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let sharedModelContainer: ModelContainer
    let clipboardMonitor: ClipboardMonitor

    init() {
        let schema = Schema([
            Item.self,
        ])
        self.sharedModelContainer = ClipKeepApp.makeModelContainer(schema: schema)
        self.clipboardMonitor = ClipboardMonitor(container: sharedModelContainer)
    }

    var body: some Scene {
        MenuBarExtra("ClipKeep", systemImage: "doc.on.doc.fill") {
            MenuBarView()
                .modelContainer(sharedModelContainer)
        }
        .menuBarExtraStyle(.window)
    }

    private static func makeModelContainer(schema: Schema) -> ModelContainer {
        let supportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let storeURL = supportURL.appendingPathComponent("ClipKeep.store")

        try? FileManager.default.createDirectory(at: supportURL, withIntermediateDirectories: true)

        let configuration = ModelConfiguration(schema: schema, url: storeURL)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // If the schema changed (e.g., new fields), clear the old store and retry to prevent launch crashes.
            try? FileManager.default.removeItem(at: storeURL)
            do {
                return try ModelContainer(for: schema, configurations: [configuration])
            } catch {
                fatalError("Could not create ModelContainer even after reset: \(error)")
            }
        }
    }
}
