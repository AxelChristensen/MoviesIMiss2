//
//  MovieListView.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import SwiftUI
import SwiftData

struct MovieListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<SavedMovie> { movie in
        movie.statusRawValue == "pending"
    }, sort: \SavedMovie.dateAdded) private var pendingMovies: [SavedMovie]
    
    @Query(sort: \SavedMovie.dateAdded, order: .reverse) private var allMovies: [SavedMovie]
    
    private var processedMovies: [SavedMovie] {
        allMovies.filter { movie in
            movie.statusRawValue == "snoozed" || 
            movie.statusRawValue == "removed" || 
            movie.statusRawValue == "wantToWatch"
        }
    }
    
    @State private var selectedMovie: SavedMovie?
    @State private var tmdbService = TMDBService()
    @State private var isLoadingCuratedList = false
    @State private var errorMessage: String?
    @State private var selectedList: MovieListType = .topRated
    @State private var selectedDecade: Decade = .all
    @State private var selectedRating: RatingFilter = .all
    @State private var selectedActor: FamousActor = .all
    @State private var showProcessedMovies = false
    
    // Lazy loading state
    @State private var currentPage = 1
    @State private var isLoadingMore = false
    @State private var hasMorePages = true
    private let maxPages = 10 // Maximum pages to load (200 movies)
    
    // Search-related state
    @State private var searchText = ""
    @State private var searchResults: [TMDBMovie] = []
    @State private var isSearching = false
    @State private var selectedSearchMovie: TMDBMovie?
    @State private var selectedVibeFilter: String? = nil // nil = show all
    
    var isShowingSearchResults: Bool {
        !searchText.isEmpty
    }
    
    // Check if any filters are currently active
    var hasActiveFilters: Bool {
        selectedDecade != .all || 
        selectedRating != .all || 
        selectedActor != .all ||
        selectedList != .topRated
    }
    
    // Get available vibes from all saved movies with vibes
    var availableVibes: [MovieVibe] {
        let vibeStrings = Set(allMovies.flatMap { $0.personalVibes ?? [] })
        return MovieVibe.allCases.filter { vibeStrings.contains($0.rawValue) }
    }
    
    // Filter search results by selected vibe
    var filteredSearchResults: [TMDBMovie] {
        guard let vibeFilter = selectedVibeFilter else {
            return searchResults
        }
        
        // Filter search results to only include movies that:
        // 1. Are already in our database
        // 2. Have the selected vibe
        let moviesWithVibe = allMovies.filter { movie in
            movie.personalVibes?.contains(vibeFilter) ?? false
        }
        let tmdbIdsWithVibe = Set(moviesWithVibe.map { $0.tmdbId })
        
        return searchResults.filter { tmdbIdsWithVibe.contains($0.id) }
    }
    
    enum Decade: String, CaseIterable {
        case all = "All Time"
        case twenties = "2020s"
        case tens = "2010s"
        case thousands = "2000s"
        case nineties = "1990s"
        case eighties = "1980s"
        case seventies = "1970s"
        case sixties = "1960s"
        case fifties = "1950s"
        case classics = "Before 1950"
        
        var dateRange: (start: String, end: String)? {
            let currentYear = Calendar.current.component(.year, from: Date())
            switch self {
            case .all: return nil
            case .twenties: return ("2020-01-01", "\(currentYear)-12-31")
            case .tens: return ("2010-01-01", "2019-12-31")
            case .thousands: return ("2000-01-01", "2009-12-31")
            case .nineties: return ("1990-01-01", "1999-12-31")
            case .eighties: return ("1980-01-01", "1989-12-31")
            case .seventies: return ("1970-01-01", "1979-12-31")
            case .sixties: return ("1960-01-01", "1969-12-31")
            case .fifties: return ("1950-01-01", "1959-12-31")
            case .classics: return ("1900-01-01", "1949-12-31")
            }
        }
        
        var icon: String {
            switch self {
            case .all: return "infinity"
            case .twenties: return "calendar"
            case .tens: return "calendar.badge.clock"
            case .thousands: return "calendar.circle"
            default: return "calendar.badge.exclamationmark"
            }
        }
    }
    
    enum MovieListType: String, CaseIterable {
        case topRated = "Top Rated"
        case popular = "Popular"
        case nowPlaying = "Now Playing"
        case upcoming = "Upcoming"
        case action = "Action"
        case comedy = "Comedy"
        case drama = "Drama"
        case horror = "Horror"
        case sciFi = "Sci-Fi"
        case romance = "Romance"
        
        var icon: String {
            switch self {
            case .topRated: return "star.fill"
            case .popular: return "flame.fill"
            case .nowPlaying: return "film.fill"
            case .upcoming: return "calendar"
            case .action: return "bolt.fill"
            case .comedy: return "face.smiling"
            case .drama: return "theatermasks.fill"
            case .horror: return "moon.fill"
            case .sciFi: return "sparkles"
            case .romance: return "heart.fill"
            }
        }
        
        var genreId: Int? {
            switch self {
            case .action: return 28
            case .comedy: return 35
            case .drama: return 18
            case .horror: return 27
            case .sciFi: return 878
            case .romance: return 10749
            default: return nil
            }
        }
    }
    
    enum RatingFilter: String, CaseIterable {
        case all = "All Ratings"
        case nineplus = "8.5+"  // Changed from 9.0+ (very few movies exceed 9.0 on TMDB)
        case eightplus = "8.0+"
        case sevenplus = "7.0+"
        case sixplus = "6.0+"
        
        var threshold: Double? {
            switch self {
            case .all: return nil
            case .nineplus: return 8.5  // Adjusted to 8.5 (still represents "masterpiece" tier)
            case .eightplus: return 8.0
            case .sevenplus: return 7.0
            case .sixplus: return 6.0
            }
        }
        
        var icon: String {
            switch self {
            case .all: return "line.3.horizontal.decrease.circle"  // Filter icon
            case .nineplus: return "rosette"  // Award/medal for masterpieces
            case .eightplus: return "star.circle.fill"  // High quality
            case .sevenplus: return "star.circle"  // Good quality
            case .sixplus: return "star"  // Decent quality
            }
        }
    }
    
    enum FamousActor: String, CaseIterable, Identifiable {
        case all = "Any Actor"
        case tomHanks = "Tom Hanks"
        case merylStreep = "Meryl Streep"
        case leonardoDiCaprio = "Leonardo DiCaprio"
        case scarlettJohansson = "Scarlett Johansson"
        case denzelWashington = "Denzel Washington"
        case cateBlanchett = "Cate Blanchett"
        case bradPitt = "Brad Pitt"
        case nataliePortman = "Natalie Portman"
        case robertDowneyJr = "Robert Downey Jr."
        case charlizeTheron = "Charlize Theron"
        case christianBale = "Christian Bale"
        case anneHathaway = "Anne Hathaway"
        case morganFreeman = "Morgan Freeman"
        case emmaStone = "Emma Stone"
        case mattDamon = "Matt Damon"
        case jenniferLawrence = "Jennifer Lawrence"
        case johnnyDepp = "Johnny Depp"
        case sandraBullock = "Sandra Bullock"
        case willSmith = "Will Smith"
        case juliaRoberts = "Julia Roberts"
        case samuelLJackson = "Samuel L. Jackson"
        
        var id: String { self.rawValue }
        
        var tmdbId: Int? {
            switch self {
            case .all: return nil
            case .tomHanks: return 31
            case .merylStreep: return 5064
            case .leonardoDiCaprio: return 6193
            case .scarlettJohansson: return 1245
            case .denzelWashington: return 5292
            case .cateBlanchett: return 112
            case .bradPitt: return 287
            case .nataliePortman: return 524
            case .robertDowneyJr: return 3223
            case .charlizeTheron: return 6885
            case .christianBale: return 3894
            case .anneHathaway: return 1813
            case .morganFreeman: return 192
            case .emmaStone: return 54693
            case .mattDamon: return 1892
            case .jenniferLawrence: return 72129
            case .johnnyDepp: return 85
            case .sandraBullock: return 18277
            case .willSmith: return 2888
            case .juliaRoberts: return 1204
            case .samuelLJackson: return 2231
            }
        }
        
        var icon: String {
            "person.fill"
        }
    }
    
    var body: some View {
        NavigationStack {
            mainContent
                .navigationTitle(navigationTitle)
                .searchable(text: $searchText, prompt: "Search for movies...")
                .onChange(of: searchText) { oldValue, newValue in
                    // Reset vibe filter when starting a new search
                    if oldValue.isEmpty && !newValue.isEmpty {
                        selectedVibeFilter = nil
                    }
                    Task {
                        await performSearch()
                    }
                }
                .onAppear {
                    print("\n=== BROWSE TAB DEBUG ===")
                    print("Pending Movies Count: \(pendingMovies.count)")
                    for movie in pendingMovies {
                        print("- \(movie.title)")
                        print("  Status: \(movie.statusRawValue)")
                        print("  Seen Before: \(movie.hasSeenBefore)")
                    }
                    print("========================\n")
                }
                .toolbar {
                    if !isShowingSearchResults {
                        historyButton
                        decadeMenu
                        listTypeMenu
                        ratingMenu
                        actorMenu
                        if hasActiveFilters {
                            resetFiltersButton
                        }
                        refreshButton
                    }
                }
                .sheet(item: $selectedMovie) { movie in
                    MovieDecisionView(movie: movie, tmdbService: tmdbService)
                }
                .sheet(item: $selectedSearchMovie) { movie in
                    AddMovieSheet(movie: movie, modelContext: modelContext)
                }
                .alert("Error", isPresented: .constant(errorMessage != nil)) {
                    Button("OK") {
                        errorMessage = nil
                    }
                } message: {
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                    }
                }
        }
        .task {
            if pendingMovies.isEmpty && !isLoadingCuratedList {
                await loadCuratedMovies()
            }
        }
    }
    
    private var navigationTitle: String {
        if isShowingSearchResults {
            return "Search Results"
        } else if showProcessedMovies {
            return "Browse History"
        } else {
            return "Browse"
        }
    }
    
    private var mainContent: some View {
        Group {
            if isShowingSearchResults {
                searchResultsView
            } else if showProcessedMovies {
                processedMoviesView
            } else if pendingMovies.isEmpty {
                if isLoadingCuratedList {
                    ProgressView("Loading curated movie list...")
                } else {
                    emptyStateView
                }
            } else {
                moviesList
            }
        }
    }
    
    private var moviesList: some View {
        List {
            ForEach(pendingMovies) { movie in
                MovieRowView(movie: movie)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedMovie = movie
                    }
                    .onAppear {
                        // Lazy loading: Load more when reaching near the end
                        if let lastMovie = pendingMovies.last,
                           movie.id == lastMovie.id {
                            loadMoreMoviesIfNeeded()
                        }
                    }
            }
            
            // Loading indicator at the bottom
            if isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            } else if !hasMorePages && !pendingMovies.isEmpty {
                HStack {
                    Spacer()
                    Text("No more movies")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding()
                    Spacer()
                }
            }
        }
    }
    
    private var addedMovies: [SavedMovie] {
        processedMovies.filter { $0.statusRawValue == "wantToWatch" }
    }
    
    private var snoozedMovies: [SavedMovie] {
        processedMovies.filter { $0.statusRawValue == "snoozed" }
    }
    
    private var removedMovies: [SavedMovie] {
        processedMovies.filter { $0.statusRawValue == "removed" }
    }
    
    private var processedMoviesView: some View {
        Group {
            if processedMovies.isEmpty {
                ContentUnavailableView(
                    "No History Yet",
                    systemImage: "clock",
                    description: Text("Movies you've added, snoozed, or removed will appear here")
                )
            } else {
                List {
                    addedMoviesSection
                    snoozedMoviesSection
                    removedMoviesSection
                }
            }
        }
    }
    
    @ViewBuilder
    private var addedMoviesSection: some View {
        if !addedMovies.isEmpty {
            Section {
                ForEach(addedMovies) { movie in
                    ProcessedMovieRow(movie: movie, status: .added)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedMovie = movie
                        }
                }
            } header: {
                Label("Added to Watchlist", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
    }
    
    @ViewBuilder
    private var snoozedMoviesSection: some View {
        if !snoozedMovies.isEmpty {
            Section {
                ForEach(snoozedMovies) { movie in
                    ProcessedMovieRow(movie: movie, status: .snoozed)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedMovie = movie
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                unsnoozeMovie(movie)
                            } label: {
                                Label("Add", systemImage: "plus.circle")
                            }
                            .tint(.green)
                        }
                }
            } header: {
                Label("Snoozed", systemImage: "clock.fill")
                    .foregroundStyle(.orange)
            }
        }
    }
    
    @ViewBuilder
    private var removedMoviesSection: some View {
        if !removedMovies.isEmpty {
            Section {
                ForEach(removedMovies) { movie in
                    ProcessedMovieRow(movie: movie, status: .removed)
                        .contentShape(Rectangle())
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                restoreMovie(movie)
                            } label: {
                                Label("Restore", systemImage: "arrow.uturn.backward")
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                permanentlyDeleteMovie(movie)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            } header: {
                Label("Removed", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
            } footer: {
                Text("Swipe right to restore, swipe left to permanently delete")
                    .font(.caption)
            }
        }
    }
    
    private var searchResultsView: some View {
        VStack(spacing: 0) {
            // Vibe filter pills (only show if user has tagged movies with vibes)
            if !availableVibes.isEmpty {
                vibeFilterScrollView
                    .padding(.vertical, 8)
            }
            
            Group {
                if isSearching {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchResults.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else if filteredSearchResults.isEmpty && selectedVibeFilter != nil {
                    // Show empty state when filter returns no results
                    searchFilterEmptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: 16) {
                            ForEach(filteredSearchResults) { movie in
                                SearchMovieCard(movie: movie)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedSearchMovie = movie
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    // Adaptive grid columns for different screen sizes
    private var gridColumns: [GridItem] {
        #if os(iOS)
        // On iPad, use multiple columns; on iPhone, use single column
        let minWidth: CGFloat = 300
        return [GridItem(.adaptive(minimum: minWidth, maximum: 500))]
        #else
        return [GridItem(.adaptive(minimum: 300, maximum: 500))]
        #endif
    }
    
    // MARK: - Vibe Filter Views
    
    private var vibeFilterScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // "All" button
                Button {
                    selectedVibeFilter = nil
                } label: {
                    Text("All")
                        .font(.subheadline)
                        .fontWeight(selectedVibeFilter == nil ? .semibold : .regular)
                        .foregroundStyle(selectedVibeFilter == nil ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedVibeFilter == nil ? Color.blue : Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
                // Vibe filter buttons
                ForEach(availableVibes) { vibe in
                    Button {
                        if selectedVibeFilter == vibe.rawValue {
                            selectedVibeFilter = nil // Deselect
                        } else {
                            selectedVibeFilter = vibe.rawValue
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: vibe.icon)
                                .font(.caption2)
                                .imageScale(.small)
                            Text(vibe.rawValue)
                                .font(.caption)
                                .fontWeight(selectedVibeFilter == vibe.rawValue ? .semibold : .regular)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .foregroundStyle(selectedVibeFilter == vibe.rawValue ? .white : vibe.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedVibeFilter == vibe.rawValue ? vibe.color : vibe.color.opacity(0.15))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var searchFilterEmptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Saved Movies with This Vibe")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("These search results don't include any movies you've saved with the \"\(selectedVibeFilter ?? "")\" vibe")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
            
            Button {
                selectedVibeFilter = nil
            } label: {
                Text("Show All Results")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 60)
    }
    
    // MARK: - Toolbar Items
    
    private var historyButton: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Button {
                showProcessedMovies.toggle()
            } label: {
                Label(
                    showProcessedMovies ? "Show Pending" : "Show History",
                    systemImage: showProcessedMovies ? "list.bullet" : "clock.arrow.circlepath"
                )
            }
        }
    }
    
    private var decadeMenu: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Menu {
                ForEach(Decade.allCases, id: \.self) { decade in
                    decadeButton(for: decade)
                }
            } label: {
                Label(selectedDecade.rawValue, systemImage: selectedDecade.icon)
            }
        }
    }
    
    private func decadeButton(for decade: Decade) -> some View {
        Button {
            selectedDecade = decade
            Task {
                await loadCuratedMovies()
            }
        } label: {
            if selectedDecade == decade {
                Label(decade.rawValue, systemImage: decade.icon)
                Image(systemName: "checkmark")
            } else {
                Label(decade.rawValue, systemImage: decade.icon)
            }
        }
    }
    
    private var listTypeMenu: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Menu {
                ForEach(MovieListType.allCases, id: \.self) { listType in
                    listTypeButton(for: listType)
                }
            } label: {
                Label(selectedList.rawValue, systemImage: selectedList.icon)
            }
        }
    }
    
    private func listTypeButton(for listType: MovieListType) -> some View {
        Button {
            selectedList = listType
            Task {
                await loadCuratedMovies()
            }
        } label: {
            if selectedList == listType {
                Label(listType.rawValue, systemImage: listType.icon)
                Image(systemName: "checkmark")
            } else {
                Label(listType.rawValue, systemImage: listType.icon)
            }
        }
    }
    
    private var refreshButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                Task {
                    await loadCuratedMovies()
                }
            } label: {
                Label("Load Movies", systemImage: "arrow.clockwise")
            }
            .disabled(isLoadingCuratedList)
        }
    }
    
    private var resetFiltersButton: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Button {
                resetAllFilters()
            } label: {
                Label("Reset Filters", systemImage: "xmark.circle.fill")
            }
        }
    }
    
    private var ratingMenu: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Menu {
                ForEach(RatingFilter.allCases, id: \.self) { rating in
                    ratingButton(for: rating)
                }
            } label: {
                Label(selectedRating.rawValue, systemImage: selectedRating.icon)
            }
        }
    }
    
    private func ratingButton(for rating: RatingFilter) -> some View {
        Button {
            selectedRating = rating
            Task {
                await loadCuratedMovies()
            }
        } label: {
            if selectedRating == rating {
                Label(rating.rawValue, systemImage: rating.icon)
                Image(systemName: "checkmark")
            } else {
                Label(rating.rawValue, systemImage: rating.icon)
            }
        }
    }
    
    private var actorMenu: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Menu {
                // Organized by gender for easier browsing
                Section("Any Actor") {
                    actorButton(for: .all)
                }
                
                Section("Leading Men") {
                    actorButton(for: .tomHanks)
                    actorButton(for: .leonardoDiCaprio)
                    actorButton(for: .denzelWashington)
                    actorButton(for: .bradPitt)
                    actorButton(for: .robertDowneyJr)
                    actorButton(for: .christianBale)
                    actorButton(for: .morganFreeman)
                    actorButton(for: .mattDamon)
                    actorButton(for: .johnnyDepp)
                    actorButton(for: .willSmith)
                    actorButton(for: .samuelLJackson)
                }
                
                Section("Leading Women") {
                    actorButton(for: .merylStreep)
                    actorButton(for: .scarlettJohansson)
                    actorButton(for: .cateBlanchett)
                    actorButton(for: .nataliePortman)
                    actorButton(for: .charlizeTheron)
                    actorButton(for: .anneHathaway)
                    actorButton(for: .emmaStone)
                    actorButton(for: .jenniferLawrence)
                    actorButton(for: .sandraBullock)
                    actorButton(for: .juliaRoberts)
                }
            } label: {
                Label(selectedActor.rawValue, systemImage: selectedActor.icon)
            }
        }
    }
    
    private func actorButton(for actor: FamousActor) -> some View {
        Button {
            selectedActor = actor
            Task {
                await loadCuratedMovies()
            }
        } label: {
            if selectedActor == actor {
                Label(actor.rawValue, systemImage: actor.icon)
                Image(systemName: "checkmark")
            } else {
                Label(actor.rawValue, systemImage: actor.icon)
            }
        }
    }
    
    // MARK: - Functions
    
    private func resetAllFilters() {
        selectedDecade = .all
        selectedRating = .all
        selectedActor = .all
        selectedList = .topRated
        
        Task {
            await loadCuratedMovies()
        }
    }
    
    private func performSearch() async {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        do {
            // Add small delay to avoid excessive API calls while typing
            try await Task.sleep(for: .milliseconds(300))
            
            // Check if search text has changed during delay
            guard !Task.isCancelled else { return }
            
            searchResults = try await tmdbService.searchMovies(query: searchText)
        } catch {
            errorMessage = error.localizedDescription
            searchResults = []
        }
        
        isSearching = false
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: selectedRating == .nineplus ? "star.fill" : "film")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text(emptyStateTitle)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(emptyStateMessage)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            if selectedRating == .nineplus {
                Text("💡 Tip: Try 8.0+ for more highly-rated movies")
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .padding(.top, 8)
            }
        }
    }
    
    private var emptyStateTitle: String {
        if selectedRating == .nineplus {
            return "Very Few 8.5+ Movies"
        } else if selectedRating != .all {
            return "No Movies Found"
        } else {
            return "No Movies to Review"
        }
    }
    
    private var emptyStateMessage: String {
        if selectedRating == .nineplus {
            return "Movies rated 8.5+ are extremely rare masterpieces on TMDB. Even classics like The Godfather are rated around 8.6-8.7. Try the 8.0+ filter for more highly-rated options."
        } else if hasActiveFilters {
            return "No movies match your current filters. Try adjusting your filters or tap 'Reset Filters' to start fresh."
        } else {
            return "Tap the refresh button to load the curated movie list"
        }
    }
    
    private func loadCuratedMovies() async {
        // Reset pagination state
        currentPage = 1
        hasMorePages = true
        isLoadingCuratedList = true
        errorMessage = nil
        
        do {
            // Clear existing pending movies when switching categories
            let descriptor = FetchDescriptor<SavedMovie>(
                predicate: #Predicate { $0.statusRawValue == "pending" }
            )
            let existingPending = try modelContext.fetch(descriptor)
            for movie in existingPending {
                modelContext.delete(movie)
            }
            
            // Load first page (20 movies)
            try await loadMoviesPage()
            
            // If we're filtering by rating or actor, automatically load a few more pages
            // to compensate for the reduced results
            if selectedRating != .all || selectedActor != .all {
                // For very high ratings (8.5+), load even more pages since results are sparse
                let pagesToLoad: Int
                let minMovies: Int
                
                if selectedRating == .nineplus {
                    pagesToLoad = 7
                    minMovies = 5
                } else {
                    pagesToLoad = 3
                    minMovies = 15
                }
                
                print("🔄 Auto-loading up to \(pagesToLoad) more pages (target: \(minMovies) movies)")
                
                // Load up to more pages automatically to get more results
                for _ in 1...pagesToLoad {
                    if hasMorePages && currentPage < maxPages && pendingMovies.count < minMovies {
                        currentPage += 1
                        try await loadMoviesPage()
                    } else {
                        break
                    }
                }
                
                print("✅ Final count: \(pendingMovies.count) movies loaded")
            }
            
            isLoadingCuratedList = false
        } catch {
            errorMessage = "Failed to load movies: \(error.localizedDescription)"
            isLoadingCuratedList = false
        }
    }
    
    private func loadMoreMoviesIfNeeded() {
        guard !isLoadingMore && hasMorePages && currentPage < maxPages else {
            return
        }
        
        Task {
            await loadNextPage()
        }
    }
    
    private func loadNextPage() async {
        guard currentPage < maxPages else {
            hasMorePages = false
            return
        }
        
        isLoadingMore = true
        currentPage += 1
        
        do {
            try await loadMoviesPage()
            isLoadingMore = false
        } catch {
            errorMessage = "Failed to load more movies: \(error.localizedDescription)"
            isLoadingMore = false
            currentPage -= 1 // Revert page increment on error
        }
    }
    
    private func loadMoviesPage() async throws {
        // Fetch ALL existing movies to check for duplicates
        let allMoviesDescriptor = FetchDescriptor<SavedMovie>()
        let allExistingMovies = try modelContext.fetch(allMoviesDescriptor)
        let existingTmdbIds = Set(allExistingMovies.map { $0.tmdbId })
        
        // Load movies for current page
        var movies: [TMDBMovie]
        
        // Get the minimum rating threshold (if any)
        let minRating = selectedRating.threshold
        let actorId = selectedActor.tmdbId
        
        print("\n🎬 Loading movies - Page \(currentPage)")
        print("📊 Rating Filter: \(selectedRating.rawValue) (threshold: \(minRating ?? 0))")
        print("🎭 Actor Filter: \(selectedActor.rawValue) (ID: \(actorId ?? 0))")
        print("📅 Decade Filter: \(selectedDecade.rawValue)")
        print("🎥 List Type: \(selectedList.rawValue)")
        
        // If actor is selected, ALWAYS use discover API (it's much faster)
        if let actorId = actorId {
            print("🔍 Using discover API for actor: \(selectedActor.rawValue) (ID: \(actorId))")
            
            var queryItems: [(String, String)] = [
                ("with_cast", "\(actorId)"),
                ("page", "\(currentPage)"),
                ("sort_by", "popularity.desc")
            ]
            
            // Add decade filter if selected
            if let dateRange = selectedDecade.dateRange {
                queryItems.append(("primary_release_date.gte", dateRange.start))
                queryItems.append(("primary_release_date.lte", dateRange.end))
            }
            
            // Add genre filter if selected
            if let genreId = selectedList.genreId {
                queryItems.append(("with_genres", "\(genreId)"))
            }
            
            // Add rating filter if selected
            if let threshold = minRating {
                queryItems.append(("vote_average.gte", "\(threshold)"))
            }
            
            // Use a new method to fetch by actor with all filters
            movies = try await tmdbService.fetchMoviesByActorWithFilters(
                actorId: actorId,
                queryItems: queryItems
            )
        }
        // If a decade is selected (not "All Time"), use discover API
        else if let dateRange = selectedDecade.dateRange {
            print("🔍 Using fetchByDecade")
            movies = try await tmdbService.fetchByDecade(
                startDate: dateRange.start,
                endDate: dateRange.end,
                genreId: selectedList.genreId,
                page: currentPage,
                minRating: minRating,
                actorId: nil
            )
        } else if let genreId = selectedList.genreId {
            // Genre-based list (all time)
            print("🔍 Using fetchByGenre")
            movies = try await tmdbService.fetchByGenre(
                genreId: genreId,
                page: currentPage,
                minRating: minRating,
                actorId: nil
            )
        } else {
            // Standard list type (Top Rated, Popular, etc.)
            print("🔍 Using standard endpoint (Top Rated/Popular/etc)")
            switch selectedList {
            case .topRated:
                movies = try await tmdbService.fetchTopRated(page: currentPage)
            case .popular:
                movies = try await tmdbService.fetchPopular(page: currentPage)
            case .nowPlaying:
                movies = try await tmdbService.fetchNowPlaying(page: currentPage)
            case .upcoming:
                movies = try await tmdbService.fetchUpcoming(page: currentPage)
            default:
                movies = try await tmdbService.fetchTopRated(page: currentPage)
            }
            
            // Apply rating filter client-side for these endpoints
            if let threshold = minRating {
                movies = movies.filter { ($0.voteAverage ?? 0) >= threshold }
            }
        }
        
        print("📦 Fetched \(movies.count) movies from API")
        if movies.count > 0 {
            let ratings = movies.compactMap { $0.voteAverage }
            if !ratings.isEmpty {
                print("⭐ Rating range: \(ratings.min() ?? 0) - \(ratings.max() ?? 0)")
                print("⭐ Sample movies:")
                for movie in movies.prefix(3) {
                    print("   - \(movie.title) (\(movie.year)): \(movie.voteAverage ?? 0)")
                }
            }
        }
        
        // Check if we got NO movies at all (end of list)
        // Note: We allow fewer than 20 movies after filtering, because filters reduce the count
        // Only set hasMorePages = false if we got literally nothing
        if movies.isEmpty && currentPage > 1 {
            hasMorePages = false
        }
        
        print("✅ Saving \(movies.count) new movies to database")
        
        var savedCount = 0
        var duplicateCount = 0
        var duplicateInWatchlist = 0
        
        // Add to database as pending
        for tmdbMovie in movies {
            // Check if this movie already exists
            if let existingMovie = allExistingMovies.first(where: { $0.tmdbId == tmdbMovie.id }) {
                // Skip if it's already pending (this is a true duplicate we want to avoid)
                if existingMovie.status == .pending {
                    duplicateCount += 1
                    continue
                }
                // Skip if it's removed (don't show removed movies again)
                if existingMovie.status == .removed {
                    duplicateCount += 1
                    continue
                }
                // For wantToWatch, watched, or snoozed movies, add a new pending entry
                // This allows users to see the movie in Browse with the badge showing it's already added
                duplicateInWatchlist += 1
            }
            
            // Create a new pending entry
            let savedMovie = SavedMovie(
                tmdbId: tmdbMovie.id,
                title: tmdbMovie.title,
                year: tmdbMovie.year,
                overview: tmdbMovie.overview,
                posterPath: tmdbMovie.posterPath,
                status: MovieStatus.pending
            )
            modelContext.insert(savedMovie)
            savedCount += 1
        }
        
        print("💾 Saved: \(savedCount) new | 🚫 Skipped duplicates: \(duplicateCount) | ⚠️ Already in watchlist: \(duplicateInWatchlist)")
        
        try modelContext.save()
    }
    
    private func unsnoozeMovie(_ movie: SavedMovie) {
        movie.status = .wantToWatch
        try? modelContext.save()
    }
    
    private func restoreMovie(_ movie: SavedMovie) {
        movie.status = .pending
        try? modelContext.save()
        showProcessedMovies = false // Switch back to pending view
    }
    
    private func permanentlyDeleteMovie(_ movie: SavedMovie) {
        modelContext.delete(movie)
        try? modelContext.save()
    }
}

struct MovieRowView: View {
    let movie: SavedMovie
    
    @Query private var allMovies: [SavedMovie]
    
    // Check if this movie exists in watchlist (not pending)
    private var watchlistStatus: WatchlistStatus? {
        // Look for this movie in the database by TMDB ID
        guard let existingMovie = allMovies.first(where: { $0.tmdbId == movie.tmdbId && $0.id != movie.id }) else {
            return nil
        }
        
        switch existingMovie.status {
        case .wantToWatch:
            return existingMovie.hasSeenBefore ? .again : .new
        case .watched:
            return .watched
        default:
            return nil
        }
    }
    
    enum WatchlistStatus {
        case new, again, watched
        
        var badge: (icon: String, color: Color, text: String) {
            switch self {
            case .new:
                return ("checkmark.circle.fill", .blue, "In New!")
            case .again:
                return ("arrow.clockwise.circle.fill", .purple, "In Again!")
            case .watched:
                return ("eye.circle.fill", .green, "Watched")
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Poster thumbnail with caching
            ZStack(alignment: .topTrailing) {
                if let posterPath = movie.posterPath,
                   let url = URL(string: "https://image.tmdb.org/t/p/w200\(posterPath)") {
                    CachedAsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        posterPlaceholder
                    }
                    .frame(width: 60, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    posterPlaceholder
                }
                
                // Show badge if movie is in watchlist
                if let status = watchlistStatus {
                    Image(systemName: status.badge.icon)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(status.badge.color)
                        .clipShape(Circle())
                        .offset(x: 5, y: -5)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(movie.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    // Show inline badge for watchlist status
                    if let status = watchlistStatus {
                        HStack(spacing: 4) {
                            Image(systemName: status.badge.icon)
                                .font(.caption2)
                            Text(status.badge.text)
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(status.badge.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(status.badge.color.opacity(0.15))
                        .clipShape(Capsule())
                    }
                }
                
                Text(movie.year)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if !movie.overview.isEmpty {
                    Text(movie.overview)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var posterPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 60, height: 90)
            .overlay {
                Image(systemName: "film")
                    .foregroundStyle(.gray)
            }
    }
}

struct ProcessedMovieRow: View {
    let movie: SavedMovie
    let status: ProcessedStatus
    
    enum ProcessedStatus {
        case added, snoozed, removed
        
        var badge: (icon: String, color: Color, text: String) {
            switch self {
            case .added:
                return ("checkmark.circle.fill", .green, "Added")
            case .snoozed:
                return ("clock.fill", .orange, "Snoozed")
            case .removed:
                return ("xmark.circle.fill", .red, "Removed")
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            posterView
            textContent
        }
        .padding(.vertical, 4)
    }
    
    private var posterView: some View {
        Group {
            if let posterPath = movie.posterPath,
               let url = URL(string: "https://image.tmdb.org/t/p/w200\(posterPath)") {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    posterPlaceholder
                }
                .frame(width: 60, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(alignment: .topTrailing) {
                    statusBadgeOverlay
                }
            } else {
                posterPlaceholder
                    .overlay(alignment: .topTrailing) {
                        statusBadgeOverlay
                    }
            }
        }
    }
    
    private var statusBadgeOverlay: some View {
        Image(systemName: status.badge.icon)
            .font(.caption)
            .foregroundStyle(.white)
            .padding(4)
            .background(status.badge.color)
            .clipShape(Circle())
            .offset(x: 5, y: -5)
    }
    
    private var textContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(movie.title)
                .font(.headline)
                .lineLimit(2)
            
            yearAndBadgeRow
            
            if !movie.overview.isEmpty {
                Text(movie.overview)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
    
    private var yearAndBadgeRow: some View {
        HStack {
            Text(movie.year)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            statusBadgePill
        }
    }
    
    private var statusBadgePill: some View {
        HStack(spacing: 4) {
            Image(systemName: status.badge.icon)
                .font(.caption2)
            Text(status.badge.text)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundStyle(status.badge.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.badge.color.opacity(0.15))
        .clipShape(Capsule())
    }
    
    private var posterPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 60, height: 90)
            .overlay {
                Image(systemName: "film")
                    .foregroundStyle(.gray)
            }
    }
}

struct SearchMovieCard: View {
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
            posterImage
            movieInfo
            Spacer()
            addIcon
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var posterImage: some View {
        ZStack(alignment: .topTrailing) {
            Group {
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
    }
    
    private var movieInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(movie.title)
                .font(.headline)
                .lineLimit(2)
            
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
            
            ratingView
            
            if !movie.overview.isEmpty {
                Text(movie.overview)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
    }
    
    @ViewBuilder
    private var ratingView: some View {
        if let rating = movie.voteAverage, rating > 0 {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
                Text(String(format: "%.1f", rating))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var addIcon: some View {
        Image(systemName: existingMovie != nil ? "checkmark.circle.fill" : "plus.circle.fill")
            .font(.title2)
            .foregroundStyle(existingMovie != nil ? .green : .blue)
    }
    
    private var cardBackground: some View {
        #if os(iOS)
        Color(.systemBackground)
        #else
        Color(NSColor.windowBackgroundColor)
        #endif
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

