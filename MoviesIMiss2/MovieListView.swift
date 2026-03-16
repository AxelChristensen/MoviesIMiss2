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
    
    @State private var selectedMovie: SavedMovie?
    @State private var tmdbService = TMDBService()
    @State private var isLoadingCuratedList = false
    @State private var errorMessage: String?
    @State private var selectedList: MovieListType = .topRated
    @State private var selectedDecade: Decade = .all
    
    // Search-related state
    @State private var searchText = ""
    @State private var searchResults: [TMDBMovie] = []
    @State private var isSearching = false
    @State private var selectedSearchMovie: TMDBMovie?
    
    var isShowingSearchResults: Bool {
        !searchText.isEmpty
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
    
    var body: some View {
        NavigationStack {
            Group {
                if isShowingSearchResults {
                    searchResultsView
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
            .navigationTitle(isShowingSearchResults ? "Search Results" : "Browse")
            .searchable(text: $searchText, prompt: "Search for movies...")
            .onChange(of: searchText) { oldValue, newValue in
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
                    ToolbarItem(placement: .automatic) {
                        Menu {
                            ForEach(Decade.allCases, id: \.self) { decade in
                                Button {
                                    selectedDecade = decade
                                    Task {
                                        await loadCuratedMovies()
                                    }
                                } label: {
                                    Label(decade.rawValue, systemImage: decade.icon)
                                    if selectedDecade == decade {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        } label: {
                            Label(selectedDecade.rawValue, systemImage: selectedDecade.icon)
                        }
                    }
                    
                    ToolbarItem(placement: .automatic) {
                        Menu {
                            ForEach(MovieListType.allCases, id: \.self) { listType in
                                Button {
                                    selectedList = listType
                                    Task {
                                        await loadCuratedMovies()
                                    }
                                } label: {
                                    Label(listType.rawValue, systemImage: listType.icon)
                                    if selectedList == listType {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        } label: {
                            Label(selectedList.rawValue, systemImage: selectedList.icon)
                        }
                    }
                    
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
    
    private var moviesList: some View {
        List {
            ForEach(pendingMovies) { movie in
                MovieRowView(movie: movie)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedMovie = movie
                    }
            }
        }
    }
    
    private var searchResultsView: some View {
        Group {
            if isSearching {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if searchResults.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(searchResults) { movie in
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
            Image(systemName: "film")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Movies to Review")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the refresh button to load the curated movie list")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
    }
    
    private func loadCuratedMovies() async {
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
            
            // Load movies based on selected list type and decade
            var allMovies: [TMDBMovie] = []
            for page in 1...5 {
                let movies: [TMDBMovie]
                
                // If a decade is selected (not "All Time"), use discover API
                if let dateRange = selectedDecade.dateRange {
                    movies = try await tmdbService.fetchByDecade(
                        startDate: dateRange.start,
                        endDate: dateRange.end,
                        genreId: selectedList.genreId,
                        page: page
                    )
                } else if let genreId = selectedList.genreId {
                    // Genre-based list (all time)
                    movies = try await tmdbService.fetchByGenre(genreId: genreId, page: page)
                } else {
                    // Standard list type
                    switch selectedList {
                    case .topRated:
                        movies = try await tmdbService.fetchTopRated(page: page)
                    case .popular:
                        movies = try await tmdbService.fetchPopular(page: page)
                    case .nowPlaying:
                        movies = try await tmdbService.fetchNowPlaying(page: page)
                    case .upcoming:
                        movies = try await tmdbService.fetchUpcoming(page: page)
                    default:
                        movies = try await tmdbService.fetchTopRated(page: page)
                    }
                }
                
                allMovies.append(contentsOf: movies)
            }
            
            // Add to database as pending
            for tmdbMovie in allMovies {
                let savedMovie = SavedMovie(
                    tmdbId: tmdbMovie.id,
                    title: tmdbMovie.title,
                    year: tmdbMovie.year,
                    overview: tmdbMovie.overview,
                    posterPath: tmdbMovie.posterPath,
                    status: MovieStatus.pending
                )
                modelContext.insert(savedMovie)
            }
            
            try modelContext.save()
        } catch {
            errorMessage = "Failed to load movies: \(error.localizedDescription)"
        }
        
        isLoadingCuratedList = false
    }
}

struct MovieRowView: View {
    let movie: SavedMovie
    
    var body: some View {
        HStack(spacing: 12) {
            // Poster thumbnail
            if let posterPath = movie.posterPath,
               let url = URL(string: "https://image.tmdb.org/t/p/w200\(posterPath)") {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        posterPlaceholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        posterPlaceholder
                    @unknown default:
                        posterPlaceholder
                    }
                }
                .frame(width: 60, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                posterPlaceholder
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                
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

struct SearchMovieCard: View {
    let movie: TMDBMovie
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Poster
            if let url = movie.posterURL() {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        posterPlaceholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        posterPlaceholder
                    @unknown default:
                        posterPlaceholder
                    }
                }
                .frame(width: 80, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                posterPlaceholder
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(movie.year)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
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
                
                if !movie.overview.isEmpty {
                    Text(movie.overview)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
            
            Spacer()
            
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)
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

#Preview {
    MovieListView()
        .modelContainer(for: SavedMovie.self, inMemory: true)
}
