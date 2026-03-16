//
//  NotificationDebugView.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import SwiftUI
import SwiftData
import UserNotifications

/// A debug view to test and inspect notification scheduling
struct NotificationDebugView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allMovies: [SavedMovie]
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var pendingNotificationCount = 0
    @State private var showingDetailedLog = false
    
    var moviesWithRewatchDates: [SavedMovie] {
        allMovies.filter { $0.nextRewatchDate != nil }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Authorization Status Section
                Section("Notification Permissions") {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(notificationManager.authorizationStatus.description)
                            .foregroundStyle(statusColor)
                            .fontWeight(.semibold)
                    }
                    
                    if notificationManager.authorizationStatus != .authorized {
                        Button {
                            Task {
                                try? await notificationManager.requestAuthorization()
                            }
                        } label: {
                            Label("Request Permission", systemImage: "bell.badge")
                        }
                    }
                }
                
                // Pending Notifications Section
                Section("Pending Notifications") {
                    HStack {
                        Text("Total Scheduled")
                        Spacer()
                        Text("\(pendingNotificationCount)")
                            .foregroundStyle(.secondary)
                            .fontWeight(.semibold)
                    }
                    
                    Button {
                        Task {
                            await notificationManager.printPendingNotifications()
                            showingDetailedLog = true
                        }
                    } label: {
                        Label("Print to Console", systemImage: "printer")
                    }
                }
                
                // Movies with Rewatch Dates Section
                Section("Movies with Rewatch Dates") {
                    if moviesWithRewatchDates.isEmpty {
                        Text("No movies with rewatch dates")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(moviesWithRewatchDates) { movie in
                            MovieNotificationRow(movie: movie)
                        }
                    }
                }
                
                // Quick Actions Section
                Section("Quick Actions") {
                    Button {
                        Task {
                            await notificationManager.rescheduleAllNotifications(movies: moviesWithRewatchDates)
                            await updatePendingCount()
                        }
                    } label: {
                        Label("Reschedule All Notifications", systemImage: "arrow.clockwise")
                    }
                    
                    Button(role: .destructive) {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        Task {
                            await updatePendingCount()
                        }
                    } label: {
                        Label("Cancel All Notifications", systemImage: "trash")
                    }
                }
                
                // Test Notification Section
                Section("Testing") {
                    Button {
                        scheduleTestNotification(in: 5)
                    } label: {
                        Label("Test Notification (5 seconds)", systemImage: "bell.badge")
                    }
                    
                    Button {
                        scheduleTestNotification(in: 60)
                    } label: {
                        Label("Test Notification (1 minute)", systemImage: "bell.badge")
                    }
                    
                    Text("Test notifications help verify your app can send notifications")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Notification Debugger")
            .task {
                await updatePendingCount()
            }
            .refreshable {
                await updatePendingCount()
            }
        }
    }
    
    private var statusColor: Color {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return .green
        #if !os(macOS)
        case .provisional, .ephemeral:
            return .green
        #endif
        case .denied:
            return .red
        case .notDetermined:
            return .orange
        @unknown default:
            return .gray
        }
    }
    
    private func updatePendingCount() async {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        await MainActor.run {
            pendingNotificationCount = requests.count
        }
    }
    
    private func scheduleTestNotification(in seconds: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification scheduled \(seconds) seconds ago"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(
            identifier: "test-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule test notification: \(error)")
            } else {
                print("✅ Test notification scheduled for \(seconds) seconds from now")
            }
        }
        
        Task {
            await updatePendingCount()
        }
    }
}

struct MovieNotificationRow: View {
    let movie: SavedMovie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(movie.title)
                .font(.headline)
            
            if let date = movie.nextRewatchDate {
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                    
                    Spacer()
                    
                    Text(timeUntilString(date))
                        .font(.caption)
                        .foregroundStyle(urgencyColor(for: date))
                        .fontWeight(.semibold)
                }
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                NotificationManager.shared.cancelRewatchNotification(for: movie)
            } label: {
                Label("Cancel", systemImage: "bell.slash")
            }
            
            Button {
                Task {
                    try? await NotificationManager.shared.scheduleRewatchNotification(for: movie)
                }
            } label: {
                Label("Reschedule", systemImage: "arrow.clockwise")
            }
            .tint(.blue)
        }
    }
    
    private func timeUntilString(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: date)
        
        if let days = components.day, days < 0 {
            return "Overdue"
        } else if let days = components.day, days > 0 {
            return "In \(days)d"
        } else if let hours = components.hour, hours > 0 {
            return "In \(hours)h"
        } else if let minutes = components.minute {
            return "In \(minutes)m"
        } else {
            return "Now"
        }
    }
    
    private func urgencyColor(for date: Date) -> Color {
        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        
        if daysUntil < 0 {
            return .red
        } else if daysUntil <= 7 {
            return .orange
        } else {
            return .green
        }
    }
}

#Preview {
    NotificationDebugView()
        .modelContainer(for: SavedMovie.self, inMemory: true)
}
