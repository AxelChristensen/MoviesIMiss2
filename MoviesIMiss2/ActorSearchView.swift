//
//  ActorSearchView.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import SwiftUI
import SwiftData

struct ActorSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var tmdbService = TMDBService()
    @State private var searchText = ""
    @State private var searchResults: [TMDBPerson] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var selectedActor: TMDBPerson?
    @State private var searchMode: SearchMode = .actors
    
    enum SearchMode: String, CaseIterable {
        case actors = "Actors"
        case directors = "Directors"
        
        var icon: String {
            switch self {
            case .actors: return "person.fill"
            case .directors: return "film.stack"
            }
        }
        
        var prompt: String {
            switch self {
            case .actors: return "Search for an actor..."
            case .directors: return "Search for a director..."
            }
        }
        
        var emptyTitle: String {
            switch self {
            case .actors: return "Search for Actors"
            case .directors: return "Search for Directors"
            }
        }
        
        var emptyDescription: String {
            switch self {
            case .actors: return "Enter an actor's name to find their movies"
            case .directors: return "Enter a director's name to find their movies"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if !tmdbService.hasAPIKey {
                    apiKeyMissingView
                } else {
                    VStack(spacing: 0) {
                        // Segmented control for switching between actors and directors
                        Picker("Search Mode", selection: $searchMode) {
                            ForEach(SearchMode.allCases, id: \.self) { mode in
                                Label(mode.rawValue, systemImage: mode.icon)
                                    .tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        .onChange(of: searchMode) { oldValue, newValue in
                            // Clear search when switching modes
                            searchResults = []
                            errorMessage = nil
                        }
                        
                        searchResultsView
                    }
                }
            }
            .navigationTitle(searchMode == .actors ? "Search by Actor" : "Search by Director")
            .searchable(text: $searchText, prompt: searchMode.prompt)
            .onChange(of: searchText) { oldValue, newValue in
                Task {
                    await performSearch()
                }
            }
            .navigationDestination(item: $selectedActor) { actor in
                ActorMoviesView(actor: actor, searchMode: searchMode)
            }
        }
    }
    
    private var searchResultsView: some View {
        Group {
            if isSearching {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = errorMessage {
                ContentUnavailableView(
                    "Search Error",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if searchText.isEmpty {
                ContentUnavailableView(
                    searchMode.emptyTitle,
                    systemImage: searchMode.icon,
                    description: Text(searchMode.emptyDescription)
                )
            } else if searchResults.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                List(searchResults) { person in
                    ActorRow(person: person)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedActor = person
                        }
                }
                .listStyle(.plain)
            }
        }
    }
    
    private var apiKeyMissingView: some View {
        ContentUnavailableView(
            "TMDB API Key Required",
            systemImage: "key.slash",
            description: Text("Please add your TMDB API key to Secrets.plist")
        )
    }
    
    private func performSearch() async {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        do {
            // Add small delay to avoid excessive API calls while typing
            try await Task.sleep(for: .milliseconds(300))
            
            // Check if search text has changed during delay
            guard !Task.isCancelled else { return }
            
            let results = try await tmdbService.searchPeople(query: searchText)
            
            // Filter based on search mode
            switch searchMode {
            case .actors:
                // Filter to only actors (known for acting)
                searchResults = results.filter { person in
                    person.knownForDepartment?.lowercased() == "acting"
                }
            case .directors:
                // Filter to only directors (known for directing)
                searchResults = results.filter { person in
                    person.knownForDepartment?.lowercased() == "directing"
                }
            }
            
        } catch {
            errorMessage = error.localizedDescription
            searchResults = []
        }
        
        isSearching = false
    }
}

struct ActorRow: View {
    let person: TMDBPerson
    
    var body: some View {
        HStack(spacing: 12) {
            // Actor profile image with caching
            if let url = person.profileURL() {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    profilePlaceholder
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            } else {
                profilePlaceholder
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(person.name)
                    .font(.headline)
                
                if let knownFor = person.knownFor, !knownFor.isEmpty {
                    let movieTitles = knownFor
                        .filter { $0.mediaType == "movie" }
                        .prefix(2)
                        .map { $0.displayTitle }
                        .joined(separator: ", ")
                    
                    if !movieTitles.isEmpty {
                        Text("Known for: \(movieTitles)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    private var profilePlaceholder: some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 60, height: 60)
            .overlay {
                Image(systemName: "person.fill")
                    .foregroundStyle(.gray)
            }
    }
}

struct ActorMoviesView: View {
    let actor: TMDBPerson
    let searchMode: ActorSearchView.SearchMode
    
    @Environment(\.modelContext) private var modelContext
    @State private var tmdbService = TMDBService()
    @State private var movies: [TMDBMovie] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedMovie: TMDBMovie?
    
    private var navigationTitle: String {
        switch searchMode {
        case .actors:
            return actor.name
        case .directors:
            return "\(actor.name) (Director)"
        }
    }
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = errorMessage {
                ContentUnavailableView(
                    "Unable to Load Movies",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if movies.isEmpty {
                ContentUnavailableView(
                    "No Movies Found",
                    systemImage: "film.stack",
                    description: Text("No movies found for \(actor.name)")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(movies) { movie in
                            MovieCard(movie: movie)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedMovie = movie
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(navigationTitle)
        .task {
            await loadMovies()
        }
        .sheet(item: $selectedMovie) { movie in
            AddMovieSheet(movie: movie, modelContext: modelContext)
        }
    }
    
    private func loadMovies() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch movies based on search mode
            // Load multiple pages to ensure we get all significant movies
            var allMovies: [TMDBMovie] = []
            
            switch searchMode {
            case .actors:
                // Load first 12 pages (240 movies) to get a comprehensive filmography
                for page in 1...12 {
                    let pageMovies = try await tmdbService.fetchMoviesByActor(personId: actor.id, page: page)
                    if pageMovies.isEmpty {
                        break // No more movies
                    }
                    allMovies.append(contentsOf: pageMovies)
                }
            case .directors:
                // Load first 12 pages for directors too
                for page in 1...12 {
                    let pageMovies = try await tmdbService.fetchMoviesByDirector(personId: actor.id, page: page)
                    if pageMovies.isEmpty {
                        break // No more movies
                    }
                    allMovies.append(contentsOf: pageMovies)
                }
            }
            
            // Remove duplicates (just in case)
            var seenIds = Set<Int>()
            movies = allMovies.filter { movie in
                if seenIds.contains(movie.id) {
                    return false
                }
                seenIds.insert(movie.id)
                return true
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

struct MovieCard: View {
    let movie: TMDBMovie
    
    @Environment(\.modelContext) private var modelContext
    @Query private var allMovies: [SavedMovie]
    
    // Check if this movie is already saved
    private var existingMovie: SavedMovie? {
        allMovies.first { $0.tmdbId == movie.id }
    }
    
    private var collectionStatus: String? {
        guard let existing = existingMovie else { return nil }
        
        switch existing.status {
        case .wantToWatch:
            if existing.hasSeenBefore {
                return "In Again! List"
            } else {
                return "In New! List"
            }
        case .watched:
            return "Watched"
        case .snoozed:
            return "Snoozed"
        case .removed:
            return "Previously Removed"
        case .pending:
            return nil // Don't show for pending
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Poster with caching
            ZStack(alignment: .topTrailing) {
                if let url = movie.posterURL() {
                    CachedAsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        posterPlaceholder
                    }
                    .frame(width: 80, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    posterPlaceholder
                }
                
                // Collection badge overlay
                if existingMovie != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .background(
                            Circle()
                                .fill(.green)
                                .padding(-4)
                        )
                        .offset(x: 8, y: -8)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(movie.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Spacer()
                }
                
                // Collection status badge
                if let status = collectionStatus {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                        Text(status)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green)
                    .clipShape(Capsule())
                }
                
                Text(movie.year)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let rating = movie.voteAverage, rating > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if !movie.overview.isEmpty {
                    Text(movie.overview)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
            
            Spacer()
        }
        .padding()
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(NSColor.windowBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var posterPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 80, height: 120)
            .overlay {
                Image(systemName: "film")
                    .foregroundStyle(.gray)
            }
    }
}

struct AddMovieSheet: View {
    let movie: TMDBMovie
    let modelContext: ModelContext
    
    @Environment(\.dismiss) private var dismiss
    @State private var hasSeenBefore = false
    @State private var moodItHelpsWithString: String = ""
    @State private var nextRewatchDate: Date?
    @State private var showingCustomDatePicker = false
    
    // Vibe fields
    @State private var selectedVibes: [String] = []
    @State private var vibeNotes: String = ""
    
    // Watch providers
    @State private var watchProviders: TMDBCountryProviders?
    @State private var isLoadingProviders = false
    private let tmdbService = TMDBService()
    
    enum RewatchInterval: String, CaseIterable, Identifiable {
        case testIn1Minute = "TEST: In 1 Minute"
        case immediately = "Immediately"
        case nextWeek = "Next Week"
        case oneMonth = "In 1 Month"
        case sixMonths = "In 6 Months"
        case oneYear = "In 1 Year"
        case twoYears = "In 2 Years"
        case custom = "Custom Date"
        case never = "Never"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .testIn1Minute: return "bolt.badge.clock.fill"
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
            case .testIn1Minute:
                return calendar.date(byAdding: .minute, value: 1, to: baseDate)
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
            Form {
                movieInfoSection
                
                // Watch providers section
                watchProvidersSection
                
                seenBeforeSection
                
                // Always show vibe section
                vibeSection
                
                // Only show rewatch reminder if seen before
                if hasSeenBefore {
                    rewatchReminderSection
                }
                
                moodInfoSection
            }
            .navigationTitle("Add Movie")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveMovie()
                        dismiss()
                    }
                }
            }
            .task {
                await loadWatchProviders()
            }
        }
    }
    
    private var movieInfoSection: some View {
        Section {
            HStack(alignment: .top, spacing: 12) {
                if let url = movie.posterURL(size: .w200) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 150)
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(movie.title)
                        .font(.headline)
                    Text(movie.year)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if let rating = movie.voteAverage, rating > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 2)
                    }
                }
            }
            
            if !movie.overview.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Overview")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Text(movie.overview)
                        .font(.subheadline)
                }
                .padding(.top, 4)
            }
        }
    }
    
    private var seenBeforeSection: some View {
        Section {
            Toggle("I've seen this before", isOn: $hasSeenBefore)
        }
    }
    
    private var vibeSection: some View {
        Section {
            VibePicker(selectedVibes: $selectedVibes, vibeNotes: $vibeNotes)
        }
    }
    
    private var rewatchReminderSection: some View {
        Section("Rewatch Reminder") {
            Menu {
                ForEach(RewatchInterval.allCases) { interval in
                    Button {
                        setRewatchInterval(interval)
                    } label: {
                        Label(interval.rawValue, systemImage: interval.icon)
                    }
                }
            } label: {
                menuLabel
            }
            
            if showingCustomDatePicker {
                DatePicker(
                    "Custom date",
                    selection: Binding(
                        get: { nextRewatchDate ?? Date() },
                        set: { nextRewatchDate = $0 }
                    ),
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
            }
            
            if nextRewatchDate != nil {
                Button(role: .destructive) {
                    nextRewatchDate = nil
                    showingCustomDatePicker = false
                } label: {
                    Label("Clear Reminder", systemImage: "xmark.circle")
                }
            }
        }
    }
    
    private var moodInfoSection: some View {
        Section("Mood Info") {
            TextField("Mood it helps with", text: $moodItHelpsWithString)
        }
    }
    
    @ViewBuilder
    private var watchProvidersSection: some View {
        Section("Where to Watch") {
            if isLoadingProviders {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.vertical, 8)
                    Spacer()
                }
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
                    
                    // Rent
                    if let rent = providers.rent, !rent.isEmpty {
                        ProviderGroup(title: "Rent", 
                                    icon: "dollarsign.circle.fill",
                                    color: .orange,
                                    providers: rent)
                    }
                    
                    // Buy
                    if let buy = providers.buy, !buy.isEmpty {
                        ProviderGroup(title: "Buy", 
                                    icon: "cart.circle.fill",
                                    color: .purple,
                                    providers: buy)
                    }
                }
                .padding(.vertical, 4)
            } else {
                HStack {
                    Image(systemName: "tv.slash")
                        .foregroundStyle(.secondary)
                    Text("No streaming info available")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
                .padding(.vertical, 4)
            }
        }
    }
    
    private func loadWatchProviders() async {
        isLoadingProviders = true
        defer { isLoadingProviders = false }
        
        do {
            let response = try await tmdbService.fetchWatchProviders(movieId: movie.id)
            watchProviders = response.providers(for: "US")
        } catch {
            print("Failed to load watch providers: \(error)")
            watchProviders = nil
        }
    }
    
    private var menuLabel: some View {
        HStack {
            Label("When to watch again", systemImage: "calendar.badge.plus")
            Spacer()
            if let rewatchDate = nextRewatchDate {
                Text(rewatchDate.formatted(date: .abbreviated, time: .omitted))
                    .foregroundStyle(.secondary)
            } else {
                Text("None")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func setRewatchInterval(_ interval: RewatchInterval) {
        print("\n📅 === SETTING REWATCH INTERVAL ===")
        print("   Selected: \(interval.rawValue)")
        
        showingCustomDatePicker = false
        
        if interval == .custom {
            showingCustomDatePicker = true
            // Set initial date to 1 month from now if not already set
            if nextRewatchDate == nil {
                nextRewatchDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
            }
            print("   Custom date picker shown")
        } else {
            let calculatedDate = interval.calculateDate(from: Date())
            nextRewatchDate = calculatedDate
            print("   Calculated date: \(calculatedDate?.formatted() ?? "nil")")
        }
        
        print("   nextRewatchDate is now: \(nextRewatchDate?.formatted() ?? "nil")")
        print("=================================\n")
    }
    
    private func saveMovie() {
        print("\n🎬 === SAVING MOVIE ===")
        print("   Title: \(movie.title)")
        print("   Has Seen Before: \(hasSeenBefore)")
        print("   Next Rewatch Date: \(nextRewatchDate?.formatted() ?? "nil")")
        
        let savedMovie = SavedMovie(
            tmdbId: movie.id,
            title: movie.title,
            year: movie.year,
            overview: movie.overview,
            posterPath: movie.posterPath,
            hasSeenBefore: hasSeenBefore,
            moodWhenWatched: nil,
            moodItHelpsWithString: moodItHelpsWithString.isEmpty ? nil : moodItHelpsWithString,
            approximateWatchDate: nil,
            status: .wantToWatch // For "Again!" list when hasSeenBefore is true
        )
        
        // Set vibes if selected
        if !selectedVibes.isEmpty {
            savedMovie.personalVibes = selectedVibes
            savedMovie.vibeNotes = vibeNotes.isEmpty ? nil : vibeNotes
            print("   Vibes set to: \(selectedVibes.joined(separator: ", "))")
            if let notes = savedMovie.vibeNotes {
                print("   Vibe notes: \(notes)")
            }
        }
        
        // If they've seen it before, set lastWatched so it doesn't appear in "New!" list
        if hasSeenBefore {
            savedMovie.lastWatched = Date()
            print("   Setting lastWatched to: \(Date().formatted())")
        }
        
        print("   Status set to: \(savedMovie.statusRawValue)")
        print("   hasSeenBefore set to: \(savedMovie.hasSeenBefore)")
        print("   lastWatched: \(savedMovie.lastWatched?.formatted() ?? "nil")")
        
        // Set the rewatch date if one was selected
        if let rewatchDate = nextRewatchDate {
            savedMovie.nextRewatchDate = rewatchDate
            print("✅ Set rewatch date on movie: \(rewatchDate.formatted())")
        } else {
            print("⚠️ No rewatch date to set")
        }
        
        modelContext.insert(savedMovie)
        
        do {
            try modelContext.save()
            print("✅ Movie saved to database")
            print("   Final status: \(savedMovie.statusRawValue)")
            print("   Final hasSeenBefore: \(savedMovie.hasSeenBefore)")
            print("   Final lastWatched: \(savedMovie.lastWatched?.formatted() ?? "nil")")
        } catch {
            print("❌ Failed to save movie: \(error)")
        }
        
        // Schedule notification if rewatch date is set
        if let rewatchDate = nextRewatchDate {
            print("🔔 Attempting to schedule notification for \(savedMovie.title) at \(rewatchDate.formatted())")
            Task {
                do {
                    try await NotificationManager.shared.scheduleRewatchNotification(for: savedMovie)
                } catch {
                    print("❌ Failed to schedule notification: \(error)")
                }
            }
        } else {
            print("⚠️ No rewatch date set, skipping notification")
        }
        
        print("=== END SAVING MOVIE ===\n")
    }
}

#Preview {
    ActorSearchView()
        .modelContainer(for: SavedMovie.self, inMemory: true)
}
