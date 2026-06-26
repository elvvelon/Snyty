import SwiftUI

@main
struct SnytyApp: App {
    @State private var snytysiaObserver = SnytysiaObserver()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(snytysiaObserver)
        }
    }
}
