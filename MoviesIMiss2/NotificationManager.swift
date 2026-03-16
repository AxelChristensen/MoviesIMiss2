//
//  NotificationManager.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import Foundation
import UserNotifications
import SwiftData
import Combine

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {}
    
    // MARK: - Authorization
    
    /// Request notification permissions from the user
    func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        
        if granted {
            print("✅ Notification permission granted")
        } else {
            print("❌ Notification permission denied")
        }
        
        await updateAuthorizationStatus()
    }
    
    /// Check current authorization status
    func updateAuthorizationStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        
        print("📱 Notification Status: \(authorizationStatus.description)")
    }
    
    // MARK: - Scheduling Notifications
    
    /// Schedule a rewatch notification for a specific movie
    func scheduleRewatchNotification(for movie: SavedMovie) async throws {
        print("\n🔔 === SCHEDULING NOTIFICATION ===")
        print("   Movie: \(movie.title)")
        print("   TMDB ID: \(movie.tmdbId)")
        
        // Check authorization first
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        print("   Authorization Status: \(settings.authorizationStatus.rawValue)")
        
        let isAuthorized = settings.authorizationStatus == .authorized
        #if !os(macOS)
        let isProvisional = settings.authorizationStatus == .provisional
        #else
        let isProvisional = false
        #endif
        
        guard isAuthorized || isProvisional else {
            print("❌ Notifications not authorized! Status: \(settings.authorizationStatus.description)")
            return
        }
        
        guard let rewatchDate = movie.nextRewatchDate else {
            print("⚠️ No rewatch date set for \(movie.title)")
            return
        }
        
        print("   Rewatch Date: \(rewatchDate.formatted())")
        
        // Don't schedule notifications for past dates
        guard rewatchDate > Date() else {
            print("⚠️ Rewatch date is in the past for \(movie.title)")
            print("   Date: \(rewatchDate.formatted())")
            print("   Now: \(Date().formatted())")
            return
        }
        
        // Create unique identifier for this movie's notification
        let identifier = "rewatch-\(movie.tmdbId)"
        print("   Identifier: \(identifier)")
        
        // Remove any existing notification for this movie
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to Rewatch!"
        content.body = "It's time to watch \"\(movie.title)\" again 🎬"
        content.sound = .default
        
        // Add movie details to userInfo for handling taps
        content.userInfo = [
            "movieId": movie.tmdbId,
            "movieTitle": movie.title
        ]
        
        if let mood = movie.moodItHelpsWithString {
            content.body += "\nHelps with: \(mood)"
        }
        
        // Create trigger for specific date
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: rewatchDate
        )
        print("   Trigger Components: \(dateComponents)")
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        do {
            try await center.add(request)
            print("✅ Successfully scheduled notification!")
            
            // Verify it was added
            let pendingRequests = await center.pendingNotificationRequests()
            let ourRequest = pendingRequests.first { $0.identifier == identifier }
            if let ourRequest = ourRequest {
                print("✅ Verified notification in pending list")
                if let trigger = ourRequest.trigger as? UNCalendarNotificationTrigger,
                   let nextTrigger = trigger.nextTriggerDate() {
                    print("   Next trigger: \(nextTrigger.formatted())")
                }
            } else {
                print("⚠️ Notification not found in pending list!")
            }
        } catch {
            print("❌ Failed to schedule notification: \(error.localizedDescription)")
            throw error
        }
        
        print("=================================\n")
    }
    
    /// Cancel a rewatch notification for a specific movie
    func cancelRewatchNotification(for movie: SavedMovie) {
        let identifier = "rewatch-\(movie.tmdbId)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("🗑️ Cancelled notification for \(movie.title)")
    }
    
    /// Reschedule all notifications for movies with rewatch dates
    func rescheduleAllNotifications(movies: [SavedMovie]) async {
        // Cancel all existing rewatch notifications
        let center = UNUserNotificationCenter.current()
        let pendingRequests = await center.pendingNotificationRequests()
        let rewatchIdentifiers = pendingRequests
            .filter { $0.identifier.hasPrefix("rewatch-") }
            .map { $0.identifier }
        center.removePendingNotificationRequests(withIdentifiers: rewatchIdentifiers)
        
        print("🔄 Rescheduling \(movies.count) notifications...")
        
        // Schedule new notifications
        for movie in movies {
            if movie.nextRewatchDate != nil {
                try? await scheduleRewatchNotification(for: movie)
            }
        }
    }
    
    // MARK: - Debugging
    
    /// Print all pending notifications (for debugging)
    func printPendingNotifications() async {
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()
        
        print("\n=== PENDING NOTIFICATIONS (\(requests.count)) ===")
        for request in requests.sorted(by: { $0.identifier < $1.identifier }) {
            print("\n📬 \(request.identifier)")
            print("   Title: \(request.content.title)")
            print("   Body: \(request.content.body)")
            
            if let trigger = request.trigger as? UNCalendarNotificationTrigger,
               let nextTriggerDate = trigger.nextTriggerDate() {
                print("   Scheduled: \(nextTriggerDate.formatted())")
                
                let timeUntil = Calendar.current.dateComponents(
                    [.day, .hour, .minute],
                    from: Date(),
                    to: nextTriggerDate
                )
                
                if let days = timeUntil.day, days > 0 {
                    print("   Time until: \(days) days, \(timeUntil.hour ?? 0) hours")
                } else if let hours = timeUntil.hour, hours > 0 {
                    print("   Time until: \(hours) hours, \(timeUntil.minute ?? 0) minutes")
                } else {
                    print("   Time until: \(timeUntil.minute ?? 0) minutes")
                }
            }
        }
        print("===========================\n")
    }
}

// MARK: - Extensions

extension UNAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        #if !os(macOS)
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        #endif
        @unknown default: return "Unknown"
        }
    }
}
