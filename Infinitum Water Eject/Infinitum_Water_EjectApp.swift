//
//  Infinitum_Water_EjectApp.swift
//  Infinitum Water Eject
//
//  Created by Kevin Doyle Jr. on 7/5/25.
//

import SwiftUI
import SwiftData

@main
struct Infinitum_Water_EjectApp: App {
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

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
