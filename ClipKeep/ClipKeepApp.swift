import SwiftUI
import SwiftData
import Carbon

@main
struct ClipKeepApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let sharedModelContainer: ModelContainer
    let clipboardMonitor: ClipboardMonitor
    private var menuController: MenuBarController?

    init() {
        let schema = Schema([
            Item.self,
        ])
        self.sharedModelContainer = ClipKeepApp.makeModelContainer(schema: schema)
        self.clipboardMonitor = ClipboardMonitor(container: sharedModelContainer)
        self.menuController = MenuBarController(container: sharedModelContainer)
        HotKeyManager.shared.register(
            keyCode: UInt32(kVK_ANSI_V),
            modifiers: UInt32(cmdKey | shiftKey)
        ) { [weak menuController] in
            menuController?.togglePopover()
        }
    }

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }

    private static func makeModelContainer(schema: Schema) -> ModelContainer {
        let supportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let storeURL = supportURL.appendingPathComponent("ClipKeep.store")

        try? FileManager.default.createDirectory(at: supportURL, withIntermediateDirectories: true)

        let configuration = ModelConfiguration(schema: schema, url: storeURL)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create persistent ModelContainer at \(storeURL.path): \(error)")
        }
    }
}
