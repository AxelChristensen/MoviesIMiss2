//
//  RewatchTimelineView.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import SwiftUI
import SwiftData

struct RewatchTimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<SavedMovie> { movie in
        movie.statusRawValue == "wantToWatch"
    }) private var watchlistMovies: [SavedMovie]
    
    @State private var selectedMovie: SavedMovie?
    
    enum RewatchUrgency {
        case overdue
        case soon
        case eventually
        case noData
        
        var color: Color {
            switch self {
            case .overdue: return .red
            case .soon: return .orange
            case .eventually: return .green
            case .noData: return .gray
            }
        }
        
        var title: String {
            switch self {
            case .overdue: return "Overdue for Rewatch"
            case .soon: return "Watch Soon"
            case .eventually: return "Watch Eventually"
            case .noData: return "Never Watched"
            }
        }
        
        var icon: String {
            switch self {
            case .overdue: return "exclamationmark.triangle.fill"
            case .soon: return "clock.fill"
            case .eventually: return "calendar"
            case .noData: return "questionmark.circle"
            }
        }
    }
    
    var categorizedMovies: [(urgency: RewatchUrgency, movies: [SavedMovie])] {
        var overdue: [SavedMovie] = []
        var soon: [SavedMovie] = []
        var eventually: [SavedMovie] = []
        var noData: [SavedMovie] = []
        
        for movie in watchlistMovies {
            let urgency = calculateUrgency(for: movie)
            switch urgency {
            case .overdue: overdue.append(movie)
            case .soon: soon.append(movie)
            case .eventually: eventually.append(movie)
            case .noData: noData.append(movie)
            }
        }
        
        return [
            (.overdue, overdue),
            (.soon, soon),
            (.eventually, eventually),
            (.noData, noData)
        ].filter { !$0.movies.isEmpty }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if watchlistMovies.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(categorizedMovies, id: \.urgency.title) { category in
                            VStack(alignment: .leading, spacing: 12) {
                                // Section header
                                HStack {
                                    Image(systemName: category.urgency.icon)
                                        .foregroundStyle(category.urgency.color)
                                    Text(category.urgency.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text("\(category.movies.count)")
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal)
                                
                                // Movie cards
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(category.movies) { movie in
                                            MovieCardView(movie: movie, urgency: category.urgency)
                                                .onTapGesture {
                                                    selectedMovie = movie
                                                }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Rewatch Timeline")
            .sheet(item: $selectedMovie) { movie in
                MovieDetailView(movie: movie)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Movies to Rewatch Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add movies to your watchlist and log when you watch them to see rewatch recommendations here")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
        }
        .padding(.vertical, 60)
    }
    
    private func calculateUrgency(for movie: SavedMovie) -> RewatchUrgency {
        guard let lastWatched = movie.lastWatched else {
            return .noData
        }
        
        let daysSince = Calendar.current.dateComponents([.day], from: lastWatched, to: Date()).day ?? 0
        
        // More than a year = overdue
        if daysSince > 365 {
            return .overdue
        }
        // 6 months to 1 year = watch soon
        else if daysSince > 180 {
            return .soon
        }
        // Less than 6 months = eventually
        else {
            return .eventually
        }
    }
    
    private func timeSinceWatched(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        
        if days == 0 {
            return "Watched today"
        } else if days == 1 {
            return "1 day ago"
        } else if days < 7 {
            return "\(days) days ago"
        } else if days < 30 {
            let weeks = days / 7
            return "\(weeks) week\(weeks == 1 ? "" : "s") ago"
        } else if days < 365 {
            let months = days / 30
            return "\(months) month\(months == 1 ? "" : "s") ago"
        } else {
            let years = days / 365
            return "\(years) year\(years == 1 ? "" : "s") ago"
        }
    }
}

struct MovieCardView: View {
    let movie: SavedMovie
    let urgency: RewatchTimelineView.RewatchUrgency
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Poster
            if let posterPath = movie.posterPath,
               let url = URL(string: "https://image.tmdb.org/t/p/w300\(posterPath)") {
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
                .frame(width: 180, height: 270)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                posterPlaceholder
            }
            
            // Movie info
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(movie.year)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let lastWatched = movie.lastWatched {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(timeSinceWatched(lastWatched))
                            .font(.caption)
                    }
                    .foregroundStyle(urgency.color)
                }
                
                if let mood = movie.moodItHelpsWithString {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                        Text(mood)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundStyle(.pink)
                }
            }
            .frame(width: 180)
        }
        .padding(12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
    }
    
    private var posterPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 180, height: 270)
            .overlay {
                Image(systemName: "film")
                    .font(.system(size: 50))
                    .foregroundStyle(.gray)
            }
    }
    
    private func timeSinceWatched(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        
        if days == 0 {
            return "Watched today"
        } else if days < 7 {
            return "\(days)d ago"
        } else if days < 30 {
            let weeks = days / 7
            return "\(weeks)w ago"
        } else if days < 365 {
            let months = days / 30
            return "\(months)mo ago"
        } else {
            let years = days / 365
            return "\(years)y ago"
        }
    }
}

#Preview {
    RewatchTimelineView()
        .modelContainer(for: SavedMovie.self, inMemory: true)
}

