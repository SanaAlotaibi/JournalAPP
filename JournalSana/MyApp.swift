import SwiftUI
import SwiftData

// @main: نقطة بداية التطبيق، أول شي يشتغل
@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // ينشئ داتابيس SwiftData للمذكرات ويوصلها لكل الواجهات
        .modelContainer(for: Journal.self)
    }
}
