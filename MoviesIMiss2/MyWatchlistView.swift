//
//  MyWatchlistView.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import SwiftUI
import SwiftData

struct MyWatchlistView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<SavedMovie> { movie in
        movie.statusRawValue == "wantToWatch"
    }) private var watchlistMovies: [SavedMovie]
    
    @State private var selectedMovie: SavedMovie?
    @State private var sortOrder: SortOrder = .lastWatchedOldest
    
    enum SortOrder: String, CaseIterable {
        case lastWatchedOldest = "Most Overdue"
        case lastWatchedNewest = "Recently Watched"
        case dateAddedNewest = "Recently Added"
        case title = "Title"
        
        var icon: String {
            switch self {
            case .lastWatchedOldest: return "clock.arrow.circlepath"
            case .lastWatchedNewest: return "clock"
            case .dateAddedNewest: return "calendar"
            case .title: return "textformat"
            }
        }
    }
    
    var sortedMovies: [SavedMovie] {
        switch sortOrder {
        case .lastWatchedOldest:
            return watchlistMovies.sorted { movie1, movie2 in
                // Movies with no watch date go to bottom
                guard let date1 = movie1.lastWatched else { return false }
                guard let date2 = movie2.lastWatched else { return true }
                return date1 < date2
            }
        case .lastWatchedNewest:
            return watchlistMovies.sorted { movie1, movie2 in
                guard let date1 = movie1.lastWatched else { return false }
                guard let date2 = movie2.lastWatched else { return true }
                return date1 > date2
            }
        case .dateAddedNewest:
            return watchlistMovies.sorted { $0.dateAdded > $1.dateAdded }
        case .title:
            return watchlistMovies.sorted { $0.title < $1.title }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if watchlistMovies.isEmpty {
                    emptyStateView
                } else {
                    moviesList
                }
            }
            .navigationTitle("My Watchlist")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Button {
                                sortOrder = order
                            } label: {
                                Label(order.rawValue, systemImage: order.icon)
                                if sortOrder == order {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
            .sheet(item: $selectedMovie) { movie in
                MovieDetailView(movie: movie)
            }
        }
    }
    
    private var moviesList: some View {
        List {
            ForEach(sortedMovies) { movie in
                WatchlistMovieRowView(movie: movie)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedMovie = movie
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deleteMovie(movie)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Movies in Watchlist")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Movies you want to watch will appear here")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
    }
    
    private func deleteMovie(_ movie: SavedMovie) {
        modelContext.delete(movie)
        try? modelContext.save()
    }
}

struct WatchlistMovieRowView: View {
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
            
            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(movie.year)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let lastWatched = movie.lastWatched {
                    Label(lastWatchedText(lastWatched), systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.blue)
                } else {
                    Label("Not yet logged", systemImage: "exclamationmark.circle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                
                if let mood = movie.moodItHelpsWithString {
                    Text("Helps with: \(mood)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
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
    
    private func lastWatchedText(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        
        if days == 0 {
            return "Watched today"
        } else if days == 1 {
            return "Watched yesterday"
        } else if days < 7 {
            return "Watched \(days) days ago"
        } else if days < 30 {
            let weeks = days / 7
            return "Watched \(weeks) week\(weeks == 1 ? "" : "s") ago"
        } else if days < 365 {
            let months = days / 30
            return "Watched \(months) month\(months == 1 ? "" : "s") ago"
        } else {
            let years = days / 365
            return "Watched \(years) year\(years == 1 ? "" : "s") ago"
        }
    }
}

#Preview {
    MyWatchlistView()
        .modelContainer(for: SavedMovie.self, inMemory: true)
}
