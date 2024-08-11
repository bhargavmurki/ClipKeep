import SwiftUI
import SwiftData

@main
struct ClipKeepApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate // Integrate AppDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var clipboardMonitor = ClipboardMonitor() // Initialize the ClipboardMonitor

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
