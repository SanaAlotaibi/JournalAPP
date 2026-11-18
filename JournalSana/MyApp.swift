import SwiftUI
import SwiftData

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // ينشئ داتابيس SwiftData للمذكرات ويوصلها لكل الواجهات
        .modelContainer(for: Journal.self)
    }
}
