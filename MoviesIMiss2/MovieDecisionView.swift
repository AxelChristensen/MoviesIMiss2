//
//  MovieDecisionView.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import SwiftUI
import SwiftData

struct MovieDecisionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var movie: SavedMovie
    let tmdbService: TMDBService
    
    @State private var hasSeenBefore: Bool = false
    @State private var moodWhenWatched: String = ""
    @State private var moodItHelpsWithString: String = ""
    @State private var selectedRewatchInterval: RewatchInterval? = nil
    
    // Vibe fields
    @State private var selectedVibes: [String] = []
    @State private var vibeNotes: String = ""
    
    // Watch providers
    @State private var watchProviders: TMDBCountryProviders?
    @State private var isLoadingProviders = false
    
    enum RewatchInterval: String, CaseIterable {
        #if DEBUG
        case oneMinute = "In 1 Minute (Testing)" // Testing option - only in debug builds
        #endif
        case oneMonth = "In 1 Month"
        case sixMonths = "In 6 Months"
        case oneYear = "In 1 Year"
        case twoYears = "In 2 Years"
        
        var icon: String {
            switch self {
            #if DEBUG
            case .oneMinute: return "alarm.fill"
            #endif
            case .oneMonth: return "calendar.badge.plus"
            case .sixMonths: return "calendar"
            case .oneYear: return "calendar.circle"
            case .twoYears: return "calendar.badge.clock"
            }
        }
        
        func calculateDate(from baseDate: Date = Date()) -> Date {
            let calendar = Calendar.current
            switch self {
            #if DEBUG
            case .oneMinute:
                return calendar.date(byAdding: .minute, value: 1, to: baseDate)!
            #endif
            case .oneMonth:
                return calendar.date(byAdding: .month, value: 1, to: baseDate)!
            case .sixMonths:
                return calendar.date(byAdding: .month, value: 6, to: baseDate)!
            case .oneYear:
                return calendar.date(byAdding: .year, value: 1, to: baseDate)!
            case .twoYears:
                return calendar.date(byAdding: .year, value: 2, to: baseDate)!
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Movie poster
                    posterView
                    
                    // Movie info
                    VStack(spacing: 8) {
                        Text(movie.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(movie.year)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        if !movie.overview.isEmpty {
                            Text(movie.overview)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Where to Watch section
                    whereToWatchSection
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Decision form
                    VStack(spacing: 20) {
                        // Simple button to indicate if seen before
                        HStack {
                            Text("Have you seen this before?")
                                .font(.headline)
                            Spacer()
                            Button {
                                hasSeenBefore.toggle()
                            } label: {
                                Text(hasSeenBefore ? "Yes" : "No")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 8)
                                    .background(hasSeenBefore ? Color.green : Color.gray)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                        
                        if hasSeenBefore {
                            VStack(alignment: .leading, spacing: 16) {
                                // Vibe picker - ALWAYS show when seen before
                                VibePicker(selectedVibes: $selectedVibes, vibeNotes: $vibeNotes)
                                    .padding(.horizontal)
                                
                                // When to watch again selector
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("When do you want to watch it again?")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    ForEach(RewatchInterval.allCases, id: \.self) { interval in
                                        Button {
                                            selectedRewatchInterval = interval
                                            // Automatically save and dismiss when interval is selected
                                            saveMovieWithStatus(.wantToWatch)
                                        } label: {
                                            HStack {
                                                Image(systemName: interval.icon)
                                                Text(interval.rawValue)
                                                Spacer()
                                                if selectedRewatchInterval == interval {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundStyle(.green)
                                                }
                                            }
                                            .padding()
                                            .background(selectedRewatchInterval == interval ? Color.green.opacity(0.1) : Color(.systemGray6))
                                            .cornerRadius(8)
                                        }
                                        .foregroundStyle(.primary)
                                    }
                                    .padding(.horizontal)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("What mood were you in?")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    TextField("e.g., nostalgic, adventurous", text: $moodWhenWatched)
                                        .textFieldStyle(.roundedBorder)
                                }
                                .padding(.horizontal)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("What mood does it help with?")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    TextField("e.g., stress relief, inspiration", text: $moodItHelpsWithString)
                                        .textFieldStyle(.roundedBorder)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        Button {
                            saveMovieWithStatus(.wantToWatch)
                        } label: {
                            Label("Add to My Watchlist", systemImage: "heart.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                        }
                        
                        Button {
                            saveMovieWithStatus(.snoozed)
                        } label: {
                            Label("Snooze for Later", systemImage: "clock.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                        }
                        
                        Button(role: .destructive) {
                            saveMovieWithStatus(.removed)
                        } label: {
                            Label("Remove from List", systemImage: "trash.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.2))
                                .foregroundStyle(.red)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadWatchProviders()
            }
        }
    }
    
    @ViewBuilder
    private var whereToWatchSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Where to Watch")
                .font(.headline)
            
            if isLoadingProviders {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let providers = watchProviders {
                VStack(alignment: .leading, spacing: 12) {
                    // Streaming services (flatrate)
                    if let streaming = providers.flatrate, !streaming.isEmpty {
                        ProviderGroup(title: "Stream", 
                                    icon: "play.circle.fill",
                                    color: .blue,
                                    providers: streaming)
                    }
                    
                    // Free with ads
                    if let ads = providers.ads, !ads.isEmpty {
                        ProviderGroup(title: "Free (with ads)", 
                                    icon: "tv.circle.fill",
                                    color: .green,
                                    providers: ads)
                    }
                    
                    // Rental options
                    if let rent = providers.rent, !rent.isEmpty {
                        ProviderGroup(title: "Rent", 
                                    icon: "arrow.down.circle.fill",
                                    color: .orange,
                                    providers: rent)
                    }
                    
                    // Purchase options
                    if let buy = providers.buy, !buy.isEmpty {
                        ProviderGroup(title: "Buy", 
                                    icon: "cart.circle.fill",
                                    color: .purple,
                                    providers: buy)
                    }
                    
                    // JustWatch link
                    if let link = providers.link {
                        Link(destination: URL(string: link)!) {
                            HStack {
                                Image(systemName: "link.circle.fill")
                                Text("View all options on JustWatch")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                        }
                    }
                }
            } else {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.secondary)
                    Text("Streaming information not available")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
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
                .frame(maxWidth: 200, maxHeight: 300)
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
            .frame(width: 200, height: 300)
            .overlay {
                Image(systemName: "film")
                    .font(.system(size: 60))
                    .foregroundStyle(.gray)
            }
    }
    
    private func saveMovieWithStatus(_ status: MovieStatus) {
        movie.status = status
        
        if hasSeenBefore {
            movie.hasSeenBefore = true
            movie.lastWatched = Date() // Set to today
            movie.moodWhenWatched = moodWhenWatched.isEmpty ? nil : moodWhenWatched
            movie.moodItHelpsWithString = moodItHelpsWithString.isEmpty ? nil : moodItHelpsWithString
            
            // Save vibe data
            movie.personalVibes = selectedVibes.isEmpty ? nil : selectedVibes
            movie.vibeNotes = vibeNotes.isEmpty ? nil : vibeNotes
            
            // Set next rewatch date if selected
            if let interval = selectedRewatchInterval {
                movie.nextRewatchDate = interval.calculateDate(from: Date())
                
                // Schedule notification after setting the date
                Task {
                    do {
                        try await NotificationManager.shared.scheduleRewatchNotification(for: movie)
                        print("✅ Notification scheduled for \(movie.title)")
                    } catch {
                        print("❌ Failed to schedule notification: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        try? modelContext.save()
        dismiss()
    }
    
    private func loadWatchProviders() async {
        isLoadingProviders = true
        defer { isLoadingProviders = false }
        
        do {
            let response = try await tmdbService.fetchWatchProviders(movieId: movie.tmdbId)
            // You can change "US" to use user's locale or allow them to select their country
            watchProviders = response.providers(for: "US")
        } catch {
            print("Failed to load watch providers: \(error.localizedDescription)")
            watchProviders = nil
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
        posterPath: "/9cqNxx0GxF0bflZmeSMuL5tnGzr.jpg"
    )
    
    return MovieDecisionView(movie: movie, tmdbService: TMDBService())
        .modelContainer(container)
}
