//
//  RelatedMoviesView.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import SwiftUI
import SwiftData

struct RelatedMoviesView: View {
    let movie: SavedMovie
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var tmdbService = TMDBService()
    @State private var selectedTab = RelatedMoviesTab.similar
    @State private var similarMovies: [TMDBMovie] = []
    @State private var recommendedMovies: [TMDBMovie] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedMovie: TMDBMovie?
    
    enum RelatedMoviesTab: String, CaseIterable {
        case similar = "Similar"
        case recommended = "Recommended"
        
        var icon: String {
            switch self {
            case .similar: return "film.stack"
            case .recommended: return "sparkles"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Related Movies Type", selection: $selectedTab) {
                    ForEach(RelatedMoviesTab.allCases, id: \.self) { tab in
                        Label(tab.rawValue, systemImage: tab.icon)
                            .tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
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
                    } else {
                        moviesList
                    }
                }
            }
            .navigationTitle("Related to \(movie.title)")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadMovies()
            }
            .sheet(item: $selectedMovie) { movie in
                AddMovieSheet(movie: movie, modelContext: modelContext)
            }
        }
    }
    
    private var moviesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                let movies = selectedTab == .similar ? similarMovies : recommendedMovies
                
                if movies.isEmpty {
                    ContentUnavailableView(
                        "No \(selectedTab.rawValue) Movies",
                        systemImage: "film.stack",
                        description: Text("No \(selectedTab.rawValue.lowercased()) movies found for this title")
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    ForEach(movies) { movie in
                        RelatedMovieCard(movie: movie)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedMovie = movie
                            }
                    }
                }
            }
            .padding()
        }
    }
    
    private func loadMovies() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch both similar and recommended movies in parallel
            async let similar = tmdbService.fetchSimilarMovies(movieId: movie.tmdbId)
            async let recommended = tmdbService.fetchRecommendedMovies(movieId: movie.tmdbId)
            
            let (similarResults, recommendedResults) = try await (similar, recommended)
            
            similarMovies = similarResults
            recommendedMovies = recommendedResults
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

struct RelatedMovieCard: View {
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SavedMovie.self, configurations: config)
    
    let movie = SavedMovie(
        tmdbId: 278,
        title: "The Shawshank Redemption",
        year: "1994",
        overview: "Framed in the 1940s for the double murder of his wife and her lover, upstanding banker Andy Dufresne begins a new life at the Shawshank prison.",
        posterPath: "/9cqNxx0GxF0bflZmeSMuL5tnGzr.jpg",
        status: .wantToWatch
    )
    
    return RelatedMoviesView(movie: movie)
        .modelContainer(container)
}
