//
//  AgainListView.swift
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

struct AgainListView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Remove the sort parameter - we'll sort manually
    @Query(filter: #Predicate<SavedMovie> { movie in
        movie.statusRawValue == "wantToWatch" && movie.hasSeenBefore == true
    }) private var watchlistMovies: [SavedMovie]
    
    @State private var selectedMovie: SavedMovie?
    
    // Use a more explicit sorting approach
    var sortedByNextWatch: [SavedMovie] {
        let allMovies = Array(watchlistMovies)
        
        // Separate movies with and without dates
        var moviesWithDates: [SavedMovie] = []
        var moviesWithoutDates: [SavedMovie] = []
        
        for movie in allMovies {
            if movie.nextRewatchDate != nil {
                moviesWithDates.append(movie)
            } else {
                moviesWithoutDates.append(movie)
            }
        }
        
        // Sort movies with dates
        moviesWithDates.sort { movie1, movie2 in
            guard let date1 = movie1.nextRewatchDate,
                  let date2 = movie2.nextRewatchDate else {
                return false
            }
            return date1 < date2
        }
        
        let result = moviesWithDates + moviesWithoutDates
        
        print("⚠️ SORTING DEBUG:")
        print("   Total watchlistMovies: \(watchlistMovies.count)")
        print("   Movies WITH dates: \(moviesWithDates.count)")
        print("   Movies WITHOUT dates: \(moviesWithoutDates.count)")
        print("   Combined total: \(result.count)")
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if sortedByNextWatch.isEmpty {
                    emptyStateView
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(sortedByNextWatch) { movie in
                            AgainMovieRow(movie: movie)
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
                            
                            if movie.id != sortedByNextWatch.last?.id {
                                Divider()
                                    .padding(.leading, 100)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Again!")
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    if !sortedByNextWatch.isEmpty {
                        ShareLink(
                            item: MovieListDocument(
                                content: generateShareableText(),
                                filename: "MoviesIMiss-AgainList-\(Date().formatted(date: .abbreviated, time: .omitted)).txt"
                            ),
                            preview: SharePreview(
                                "Again! Movies List",
                                image: Image(systemName: "film.stack")
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
            .onAppear {
                // First, check ALL movies in database
                debugAllMoviesInDatabase()
                
                print("\n=== AGAIN! MOVIES DEBUG ===")
                print("📊 Query Results:")
                print("   Total watchlistMovies count: \(watchlistMovies.count)")
                print("   Sorted movies count: \(sortedByNextWatch.count)")
                
                print("\n📋 All movies from query:")
                for (index, movie) in watchlistMovies.enumerated() {
                    print("\n[\(index + 1)] \(movie.title)")
                    print("    Status: \(movie.statusRawValue)")
                    print("    hasSeenBefore: \(movie.hasSeenBefore)")
                    print("    Rewatch Date: \(movie.nextRewatchDate?.formatted() ?? "nil")")
                    print("    lastWatched: \(movie.lastWatched?.formatted() ?? "nil")")
                }
                
                print("\n🔢 Sorted order for display/export:")
                for (index, movie) in sortedByNextWatch.enumerated() {
                    print("  \(index + 1). \(movie.title) - \(movie.nextRewatchDate?.formatted(date: .abbreviated, time: .omitted) ?? "No date")")
                }
                
                if watchlistMovies.count != sortedByNextWatch.count {
                    print("\n⚠️ WARNING: Movie count mismatch!")
                    print("   Query returned: \(watchlistMovies.count)")
                    print("   Sorted array has: \(sortedByNextWatch.count)")
                    print("   MOVIES LOST: \(watchlistMovies.count - sortedByNextWatch.count)")
                }
                
                print("========================\n")
            }
        }
    }
    
    private func deleteMovie(_ movie: SavedMovie) {
        modelContext.delete(movie)
        try? modelContext.save()
    }
    
    private func debugAllMoviesInDatabase() {
        // Fetch ALL movies regardless of filter
        let descriptor = FetchDescriptor<SavedMovie>()
        do {
            let allMovies = try modelContext.fetch(descriptor)
            print("\n🔍 === ALL MOVIES IN DATABASE ===")
            print("   Total count: \(allMovies.count)")
            for (index, movie) in allMovies.enumerated() {
                print("\n[\(index + 1)] \(movie.title)")
                print("    statusRawValue: '\(movie.statusRawValue)'")
                print("    hasSeenBefore: \(movie.hasSeenBefore)")
                print("    nextRewatchDate: \(movie.nextRewatchDate?.formatted() ?? "nil")")
                print("    lastWatched: \(movie.lastWatched?.formatted() ?? "nil")")
                
                // Check if it matches the filter
                let matchesStatus = movie.statusRawValue == "wantToWatch"
                let matchesSeenBefore = movie.hasSeenBefore == true
                let shouldAppear = matchesStatus && matchesSeenBefore
                
                print("    ✓ Status matches 'wantToWatch': \(matchesStatus)")
                print("    ✓ hasSeenBefore is true: \(matchesSeenBefore)")
                print("    → Should appear in 'Again!' list: \(shouldAppear ? "YES ✅" : "NO ❌")")
            }
            print("=================================\n")
        } catch {
            print("❌ Error fetching all movies: \(error)")
        }
    }
    
    private func generateShareableText() -> String {
        print("🎬 === GENERATING AGAIN LIST SHAREABLE TEXT ===")
        print("📊 Movies to export: \(sortedByNextWatch.count)")
        
        var text = "🎬 Movies to Watch Again!\n"
        text += "Generated on \(Date().formatted(date: .abbreviated, time: .omitted))\n\n"
        
        for (index, movie) in sortedByNextWatch.enumerated() {
            print("   [\(index + 1)] \(movie.title)")
            text += "\(index + 1). \(movie.title) (\(movie.year))\n"
            
            if let nextRewatch = movie.nextRewatchDate {
                text += "   📅 \(formatRewatchDate(nextRewatch))\n"
            } else {
                text += "   📅 No date set\n"
            }
            
            if let mood = movie.moodItHelpsWithString {
                text += "   ❤️ Helps with: \(mood)\n"
            }
            
            text += "\n"
        }
        
        text += "Total: \(sortedByNextWatch.count) movie\(sortedByNextWatch.count == 1 ? "" : "s")\n"
        text += "\nCreated with MoviesIMiss"
        
        print("📝 Generated text:")
        print(text)
        print("✅ Successfully exported \(sortedByNextWatch.count) movies")
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
        // For iOS, share the list instead since printing is more complex
        let printText = generateShareableText()
        let activityVC = UIActivityViewController(activityItems: [printText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
        #endif
    }
    
    private func formatRewatchDate(_ date: Date) -> String {
        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        
        if daysUntil < 0 {
            let daysOverdue = abs(daysUntil)
            if daysOverdue == 1 {
                return "1 day overdue"
            } else if daysOverdue < 7 {
                return "\(daysOverdue) days overdue"
            } else if daysOverdue < 30 {
                let weeks = daysOverdue / 7
                return "\(weeks) week\(weeks == 1 ? "" : "s") overdue"
            } else {
                let months = daysOverdue / 30
                return "\(months) month\(months == 1 ? "" : "s") overdue"
            }
        } else if daysUntil == 0 {
            return "Watch today!"
        } else if daysUntil == 1 {
            return "Watch tomorrow"
        } else if daysUntil < 7 {
            return "In \(daysUntil) days"
        } else if daysUntil < 30 {
            let weeks = daysUntil / 7
            return "In \(weeks) week\(weeks == 1 ? "" : "s")"
        } else if daysUntil < 365 {
            let months = daysUntil / 30
            return "In \(months) month\(months == 1 ? "" : "s")"
        } else {
            let years = daysUntil / 365
            return "In \(years) year\(years == 1 ? "" : "s")"
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Rewatch Schedule Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Movies with scheduled rewatch dates will appear here")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
        }
        .padding(.vertical, 60)
    }
}

struct AgainMovieRow: View {
    let movie: SavedMovie
    
    var urgencyColor: Color {
        guard let nextRewatch = movie.nextRewatchDate else { return .gray }
        
        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: nextRewatch).day ?? 0
        
        if daysUntil < 0 {
            return .red // Overdue
        } else if daysUntil <= 30 {
            return .orange // Soon
        } else {
            return .green // Later
        }
    }
    
    var urgencyIcon: String {
        guard let nextRewatch = movie.nextRewatchDate else { return "questionmark.circle" }
        
        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: nextRewatch).day ?? 0
        
        if daysUntil < 0 {
            return "exclamationmark.triangle.fill"
        } else if daysUntil <= 30 {
            return "clock.fill"
        } else {
            return "calendar"
        }
    }
    
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
                
                if let nextRewatch = movie.nextRewatchDate {
                    HStack(spacing: 6) {
                        Image(systemName: urgencyIcon)
                            .font(.caption)
                            .foregroundStyle(urgencyColor)
                        
                        Text(formatRewatchDate(nextRewatch))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(urgencyColor)
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "questionmark.circle")
                            .font(.caption)
                        Text("No date set")
                            .font(.caption)
                    }
                    .foregroundStyle(.gray)
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
    
    private func formatRewatchDate(_ date: Date) -> String {
        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        
        if daysUntil < 0 {
            let daysOverdue = abs(daysUntil)
            if daysOverdue == 1 {
                return "1 day overdue"
            } else if daysOverdue < 7 {
                return "\(daysOverdue) days overdue"
            } else if daysOverdue < 30 {
                let weeks = daysOverdue / 7
                return "\(weeks) week\(weeks == 1 ? "" : "s") overdue"
            } else {
                let months = daysOverdue / 30
                return "\(months) month\(months == 1 ? "" : "s") overdue"
            }
        } else if daysUntil == 0 {
            return "Watch today!"
        } else if daysUntil == 1 {
            return "Watch tomorrow"
        } else if daysUntil < 7 {
            return "In \(daysUntil) days"
        } else if daysUntil < 30 {
            let weeks = daysUntil / 7
            return "In \(weeks) week\(weeks == 1 ? "" : "s")"
        } else if daysUntil < 365 {
            let months = daysUntil / 30
            return "In \(months) month\(months == 1 ? "" : "s")"
        } else {
            let years = daysUntil / 365
            return "In \(years) year\(years == 1 ? "" : "s")"
        }
    }
}

#Preview {
    AgainListView()
        .modelContainer(for: SavedMovie.self, inMemory: true)
}

// MARK: - Movie List Document for File Export
struct MovieListDocument: Transferable {
    let content: String
    let filename: String
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .plainText) { document in
            print("\n📄 ========== CREATING FILE ==========")
            print("Filename: \(document.filename)")
            print("Content length: \(document.content.count) characters")
            print("\n📄 ========== FULL FILE CONTENT ==========")
            print(document.content)
            print("========== END OF FILE CONTENT ==========\n")
            
            let data = document.content.data(using: .utf8) ?? Data()
            print("💾 Data size: \(data.count) bytes")
            print("✅ Full content exported successfully\n")
            
            return data
        }
        .suggestedFileName { document in
            print("📂 Suggested filename: \(document.filename)")
            return document.filename
        }
    }
}


