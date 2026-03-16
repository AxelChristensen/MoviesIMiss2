//
//  NewMoviesView.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import SwiftUI
import SwiftData
import CoreTransferable
import UniformTypeIdentifiers

#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct NewMoviesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<SavedMovie> { movie in
        movie.statusRawValue == "wantToWatch"
    }, sort: \SavedMovie.dateAdded) private var watchlistMovies: [SavedMovie]
    
    @State private var selectedMovie: SavedMovie?
    
    // Filter to show only movies without a last watched date (never watched)
    var newMovies: [SavedMovie] {
        watchlistMovies.filter { $0.lastWatched == nil }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if newMovies.isEmpty {
                    emptyStateView
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(newMovies) { movie in
                            NewMovieRow(movie: movie)
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
                            
                            if movie.id != newMovies.last?.id {
                                Divider()
                                    .padding(.leading, 100)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New!")
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    if !newMovies.isEmpty {
                        ShareLink(
                            item: MovieListDocument(
                                content: generateShareableText(),
                                filename: "MoviesIMiss-NewMovies-\(Date().formatted(date: .abbreviated, time: .omitted)).txt"
                            ),
                            preview: SharePreview(
                                "New Movies List",
                                image: Image(systemName: "sparkles")
                            )
                        ) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            printList()
                        } label: {
                            Label("Print", systemImage: "printer")
                        }
                    }
                }
            }
            .sheet(item: $selectedMovie) { movie in
                MovieDetailView(movie: movie)
            }
        }
    }
    
    private func deleteMovie(_ movie: SavedMovie) {
        modelContext.delete(movie)
        try? modelContext.save()
    }
    
    private func generateShareableText() -> String {
        print("🎬 === GENERATING SHAREABLE TEXT ===")
        
        var text = "✨ New Movies to Watch!\n"
        text += "Generated on \(Date().formatted(date: .abbreviated, time: .omitted))\n\n"
        
        for (index, movie) in newMovies.enumerated() {
            text += "\(index + 1). \(movie.title) (\(movie.year))\n"
            
            if let mood = movie.moodItHelpsWithString {
                text += "   ❤️ Helps with: \(mood)\n"
            }
            
            if !movie.overview.isEmpty {
                let shortOverview = movie.overview.prefix(100)
                text += "   📝 \(shortOverview)\(movie.overview.count > 100 ? "..." : "")\n"
            }
            
            text += "\n"
        }
        
        text += "Total: \(newMovies.count) movie\(newMovies.count == 1 ? "" : "s")\n"
        text += "\nCreated with MoviesIMiss"
        
        print("📝 Generated text:")
        print(text)
        print("=================================\n")
        
        return text
    }
    
    private func printList() {
        #if os(macOS)
        let printInfo = NSPrintInfo.shared
        printInfo.orientation = .portrait
        
        let printText = generateShareableText()
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 500, height: 700))
        textView.string = printText
        textView.font = NSFont.systemFont(ofSize: 12)
        
        let printOperation = NSPrintOperation(view: textView, printInfo: printInfo)
        printOperation.run()
        #else
        let printText = generateShareableText()
        let activityVC = UIActivityViewController(activityItems: [printText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
        #endif
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No New Movies Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Movies you haven't watched yet will appear here")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
        }
        .padding(.vertical, 60)
    }
}

struct NewMovieRow: View {
    let movie: SavedMovie
    
    var body: some View {
        HStack(spacing: 12) {
            // Small poster
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
            
            // Movie info
            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(movie.year)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    
                    Text("Never watched")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
                
                if let mood = movie.moodItHelpsWithString {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                        Text(mood)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                    .foregroundStyle(.pink)
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.clear)
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

#Preview {
    NewMoviesView()
        .modelContainer(for: SavedMovie.self, inMemory: true)
}

