//
//  MovieDetailView.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import SwiftUI
import SwiftData

struct MovieDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var movie: SavedMovie
    @State private var showingRelatedMovies = false
    @State private var showingCustomDatePicker = false
    @State private var customRewatchDate = Date()
    
    enum RewatchInterval: String, CaseIterable {
        #if DEBUG
        case oneMinute = "In 1 Minute (Testing)" // Testing option - only in debug builds
        #endif
        case immediately = "Immediately"
        case nextWeek = "Next Week"
        case oneMonth = "In 1 Month"
        case sixMonths = "In 6 Months"
        case oneYear = "In 1 Year"
        case twoYears = "In 2 Years"
        case custom = "Custom Date"
        case never = "Never"
        
        var icon: String {
            switch self {
            #if DEBUG
            case .oneMinute: return "alarm.fill"
            #endif
            case .immediately: return "bolt.fill"
            case .nextWeek: return "calendar.badge.clock"
            case .oneMonth: return "calendar.badge.plus"
            case .sixMonths: return "calendar"
            case .oneYear: return "calendar.circle"
            case .twoYears: return "calendar.badge.clock"
            case .custom: return "calendar.badge.exclamationmark"
            case .never: return "infinity"
            }
        }
        
        func calculateDate(from baseDate: Date = Date()) -> Date? {
            let calendar = Calendar.current
            switch self {
            #if DEBUG
            case .oneMinute:
                return calendar.date(byAdding: .minute, value: 1, to: baseDate)
            #endif
            case .immediately:
                return baseDate // Today/now
            case .nextWeek:
                return calendar.date(byAdding: .day, value: 7, to: baseDate)
            case .oneMonth:
                return calendar.date(byAdding: .month, value: 1, to: baseDate)
            case .sixMonths:
                return calendar.date(byAdding: .month, value: 6, to: baseDate)
            case .oneYear:
                return calendar.date(byAdding: .year, value: 1, to: baseDate)
            case .twoYears:
                return calendar.date(byAdding: .year, value: 2, to: baseDate)
            case .custom:
                return nil // User will pick
            case .never:
                return nil // No reminder
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Movie poster and info side-by-side
                    HStack(alignment: .top, spacing: 20) {
                        // Movie poster on the left
                        posterView
                        
                        // Movie info on the right
                        VStack(alignment: .leading, spacing: 8) {
                            Text(movie.title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(movie.year)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            // Overview
                            if !movie.overview.isEmpty {
                                Text("Overview")
                                    .font(.headline)
                                    .padding(.top, 8)
                                
                                Text(movie.overview)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Watch tracking
                    VStack(spacing: 16) {
                        Button {
                            logWatchedToday()
                        } label: {
                            Label("Log Watched Today", systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                        }
                        
                        // Next rewatch selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("When to Watch Again")
                                .font(.headline)
                            
                            if let nextRewatch = movie.nextRewatchDate {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Scheduled for:")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(nextRewatch.formatted(date: .abbreviated, time: .omitted))
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                    Spacer()
                                    Menu {
                                        ForEach(RewatchInterval.allCases, id: \.self) { interval in
                                            Button {
                                                setRewatchInterval(interval)
                                            } label: {
                                                Label(interval.rawValue, systemImage: interval.icon)
                                            }
                                        }
                                    } label: {
                                        Text("Change")
                                            .font(.subheadline)
                                            .foregroundStyle(.blue)
                                    }
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            Menu {
                                ForEach(RewatchInterval.allCases, id: \.self) { interval in
                                    Button {
                                        setRewatchInterval(interval)
                                    } label: {
                                        Label(interval.rawValue, systemImage: interval.icon)
                                    }
                                }
                            } label: {
                                Label("Set Rewatch Reminder", systemImage: "calendar.badge.plus")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.purple.opacity(0.2))
                                    .foregroundStyle(.purple)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Mood information
                    if movie.hasSeenBefore {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Mood Information")
                                .font(.headline)
                            
                            if let mood = movie.moodWhenWatched {
                                InfoRow(label: "Mood when watched", value: mood)
                            }
                            
                            if let helpsMood = movie.moodItHelpsWithString {
                                InfoRow(label: "Helps with", value: helpsMood)
                            }
                            
                            if let approxDate = movie.approximateWatchDate {
                                InfoRow(label: "First watched (approx.)", 
                                       value: approxDate.formatted(date: .abbreviated, time: .omitted))
                            }
                        }
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Discover related movies button
                    Button {
                        showingRelatedMovies = true
                    } label: {
                        Label("Discover Related Movies", systemImage: "film.stack.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Remove button
                    Button(role: .destructive) {
                        deleteMovie()
                    } label: {
                        Label("Remove from Watchlist", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundStyle(.red)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Movie Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingRelatedMovies) {
                RelatedMoviesView(movie: movie)
            }
            .sheet(isPresented: $showingCustomDatePicker) {
                NavigationStack {
                    VStack(spacing: 20) {
                        Text("Choose a custom rewatch date")
                            .font(.headline)
                            .padding(.top)
                        
                        DatePicker(
                            "Rewatch Date",
                            selection: $customRewatchDate,
                            in: Date()..., // Only future dates
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                        .padding()
                        
                        Spacer()
                    }
                    .navigationTitle("Custom Date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingCustomDatePicker = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                movie.nextRewatchDate = customRewatchDate
                                try? modelContext.save()
                                showingCustomDatePicker = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
    
    private var posterView: some View {
        Group {
            if let posterPath = movie.posterPath,
               let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        posterPlaceholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        posterPlaceholder
                    @unknown default:
                        posterPlaceholder
                    }
                }
                .frame(maxWidth: 150, maxHeight: 225)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 8)
            } else {
                posterPlaceholder
            }
        }
    }
    
    private var posterPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 150, height: 225)
            .overlay {
                Image(systemName: "film")
                    .font(.system(size: 40))
                    .foregroundStyle(.gray)
            }
    }
    
    private func logWatchedToday() {
        movie.lastWatched = Date()
        
        // Clear the next rewatch date - user can set a new one if they want
        movie.nextRewatchDate = nil
        
        try? modelContext.save()
    }
    
    private func setRewatchInterval(_ interval: RewatchInterval) {
        if interval == .custom {
            // Show custom date picker
            customRewatchDate = movie.nextRewatchDate ?? Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
            showingCustomDatePicker = true
        } else if interval == .never {
            // Clear the rewatch date
            movie.nextRewatchDate = nil
            try? modelContext.save()
        } else {
            // Calculate date from interval
            if let date = interval.calculateDate(from: Date()) {
                movie.nextRewatchDate = date
                try? modelContext.save()
            }
        }
    }
    
    private func deleteMovie() {
        modelContext.delete(movie)
        try? modelContext.save()
        dismiss()
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SavedMovie.self, configurations: config)
    
    let movie = SavedMovie(
        tmdbId: 123,
        title: "The Shawshank Redemption",
        year: "1994",
        overview: "Framed in the 1940s for the double murder of his wife and her lover, upstanding banker Andy Dufresne begins a new life at the Shawshank prison.",
        posterPath: "/9cqNxx0GxF0bflZmeSMuL5tnGzr.jpg",
        lastWatched: Date(),
        hasSeenBefore: true,
        moodWhenWatched: "Nostalgic",
        moodItHelpsWithString: "Stress relief",
        status: .wantToWatch
    )
    
    return MovieDetailView(movie: movie)
        .modelContainer(container)
}
