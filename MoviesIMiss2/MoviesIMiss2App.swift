//
//  MoviesIMiss2App.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct MoviesIMiss2App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SavedMovie.self,
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
                .task {
                    // Request notification permission on app launch
                    await NotificationManager.shared.updateAuthorizationStatus()
                    
                    if NotificationManager.shared.authorizationStatus == .notDetermined {
                        try? await NotificationManager.shared.requestAuthorization()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
