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
    
    // Watch provider filtering
    @State private var selectedStreamingProvider: StreamingProvider = .all
    @State private var watchProviderCache: [Int: TMDBCountryProviders] = [:]
    @State private var isLoadingProviders = false
    private let tmdbService = TMDBService()
    
    // Filter to show only movies without a last watched date (never watched) and by streaming provider
    var newMovies: [SavedMovie] {
        var movies = watchlistMovies.filter { $0.lastWatched == nil }
        
        // Filter by streaming provider if one is selected
        if selectedStreamingProvider != .all {
            movies = movies.filter { movie in
                guard let providers = watchProviderCache[movie.tmdbId] else {
                    // If provider data isn't loaded yet, exclude the movie
                    // (it will appear once data loads)
                    print("⚠️ No provider data cached for \(movie.title)")
                    return false
                }
                
                let providerIds = selectedStreamingProvider.providerIds
                guard !providerIds.isEmpty else {
                    return false
                }
                
                // Check if movie has ANY of the provider IDs for this service
                let hasProvider = providers.hasAnyProvider(
                    ids: providerIds,
                    freeOnly: selectedStreamingProvider.isFreeOnly,
                    rentalOnly: selectedStreamingProvider.isRentalOnly
                )
                
                if !hasProvider {
                    print("❌ \(movie.title) doesn't have \(selectedStreamingProvider.rawValue)")
                } else {
                    print("✅ \(movie.title) HAS \(selectedStreamingProvider.rawValue)")
                }
                
                return hasProvider
            }
        }
        
        return movies
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
                // Streaming provider filter
                streamingProviderMenu
                
                ToolbarItemGroup(placement: .automatic) {
                    if !newMovies.isEmpty {
                        ShareLink(
                            item: generateShareableText(),
                            preview: SharePreview(
                                "New Movies List",
                                image: Image(systemName: "sparkles")
                            )
                        ) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            shareViaActivityController()
                        } label: {
                            Label("Email", systemImage: "envelope")
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
            .task {
                // Load providers when view appears
                await loadWatchProviders()
            }
            .onChange(of: selectedStreamingProvider) { _, _ in
                // Reload providers when filter changes
                Task {
                    await loadWatchProviders()
                }
            }
        }
    }
    
    // MARK: - Streaming Provider Menu
    
    private var streamingProviderMenu: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Menu {
                Section("All Services") {
                    providerButton(for: .all)
                }
                
                Section("Subscription Services") {
                    providerButton(for: .netflix)
                    providerButton(for: .disneyPlus)
                    providerButton(for: .hulu)
                    providerButton(for: .hboMax)
                    providerButton(for: .appleTV)
                    providerButton(for: .peacock)
                    providerButton(for: .paramountPlus)
                    providerButton(for: .amcPlus)
                    providerButton(for: .youtubeTv)
                }
                
                Section("Amazon Prime Video") {
                    providerButton(for: .amazonPrimeFree)
                    providerButton(for: .amazonPrimeRental)
                }
                
                Section("Free (Ad-Supported)") {
                    providerButton(for: .tubi)
                    providerButton(for: .plutoTV)
                }
            } label: {
                Label(selectedStreamingProvider.rawValue, 
                      systemImage: selectedStreamingProvider.icon)
            }
        }
    }
    
    private func providerButton(for provider: StreamingProvider) -> some View {
        Button {
            selectedStreamingProvider = provider
            // onChange handler will trigger the reload
        } label: {
            if selectedStreamingProvider == provider {
                Label(provider.rawValue, systemImage: provider.icon)
                Image(systemName: "checkmark")
            } else {
                Label(provider.rawValue, systemImage: provider.icon)
            }
        }
    }
    
    private func loadWatchProviders() async {
        guard selectedStreamingProvider != .all else {
            return
        }
        
        isLoadingProviders = true
        defer { isLoadingProviders = false }
        
        // Get all movie IDs that we don't have cached yet
        let movieIds = watchlistMovies
            .filter { $0.lastWatched == nil && watchProviderCache[$0.tmdbId] == nil }
            .map { $0.tmdbId }
        
        guard !movieIds.isEmpty else {
            print("✅ All provider data already cached for New! list")
            
            // Still show which movies match even if cached
            let providerIds = selectedStreamingProvider.providerIds
            if !providerIds.isEmpty {
                let matchingMovies = newMovies.filter { movie in
                    guard let movieProviders = watchProviderCache[movie.tmdbId] else { return false }
                    return movieProviders.hasAnyProvider(
                        ids: providerIds,
                        freeOnly: selectedStreamingProvider.isFreeOnly,
                        rentalOnly: selectedStreamingProvider.isRentalOnly
                    )
                }
                
                print("🎯 NEW! Movies matching \(selectedStreamingProvider.rawValue): \(matchingMovies.count)")
                if !matchingMovies.isEmpty {
                    print("✨ Matching NEW! movies:")
                    for movie in matchingMovies {
                        print("   ✅ \(movie.title)")
                    }
                }
            }
            
            return
        }
        
        print("🎬 Loading watch providers for \(movieIds.count) New! movies...")
        
        // Batch load providers
        let providers = await tmdbService.fetchWatchProvidersForMovies(movieIds: movieIds)
        
        // Update cache
        for (movieId, provider) in providers {
            watchProviderCache[movieId] = provider
            
            // Debug: Print provider info for each movie
            if let movie = watchlistMovies.first(where: { $0.tmdbId == movieId }) {
                print("📺 \(movie.title): \(provider.debugDescription)")
            }
        }
        
        print("✅ Loaded providers for \(providers.count) New! movies")
        
        // Show which movies match the current filter
        let providerIds = selectedStreamingProvider.providerIds
        if !providerIds.isEmpty {
            let matchingMovies = newMovies.filter { movie in
                guard let movieProviders = watchProviderCache[movie.tmdbId] else { return false }
                return movieProviders.hasAnyProvider(
                    ids: providerIds,
                    freeOnly: selectedStreamingProvider.isFreeOnly,
                    rentalOnly: selectedStreamingProvider.isRentalOnly
                )
            }
            
            print("\n🎯 NEW! Movies matching \(selectedStreamingProvider.rawValue): \(matchingMovies.count)")
            if !matchingMovies.isEmpty {
                print("\n✨ Matching NEW! movies:")
                for movie in matchingMovies {
                    print("   ✅ \(movie.title)")
                }
            }
        }
    }
    
    private func deleteMovie(_ movie: SavedMovie) {
        modelContext.delete(movie)
        try? modelContext.save()
    }
    
    private func generateShareableText() -> String {
        print("🎬 === GENERATING SHAREABLE TEXT ===")
        
        let deviceName = UIDevice.current.name
        
        var text = "✨ NEW MOVIES TO WATCH\r\n"
        text += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\r\n\r\n"
        text += "Shared by: \(deviceName)\r\n"
        text += "Date: \(Date().formatted(date: .long, time: .omitted))\r\n"
        text += "Total Movies: \(newMovies.count)\r\n\r\n"
        text += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\r\n\r\n"
        
        for (index, movie) in newMovies.enumerated() {
            text += "\(index + 1). \(movie.title.uppercased())\r\n"
            text += "   Year: \(movie.year)\r\n"
            
            if let mood = movie.moodItHelpsWithString {
                text += "   Mood: \(mood)\r\n"
            }
            
            if !movie.overview.isEmpty {
                let shortOverview = movie.overview.prefix(120)
                text += "   About: \(shortOverview)\(movie.overview.count > 120 ? "..." : "")\r\n"
            }
            
            text += "\r\n"
        }
        
        text += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\r\n"
        text += "Created with MoviesIMiss 🎬\r\n\r\n"
        text += "Find your own movies with the MIM app in the iOS App Store!\r\n"
        
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
        shareViaActivityController()
        #endif
    }
    
    #if os(iOS)
    private func shareViaActivityController() {
        let printText = generateShareableText()
        let activityVC = UIActivityViewController(activityItems: [printText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    #else
    private func shareViaActivityController() {
        // Not available on macOS
    }
    #endif
    
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
            // Small poster with caching
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
            
            // Movie info
            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(movie.year)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // Vibe badges
                if let vibes = movie.personalVibes, !vibes.isEmpty {
                    VibesBadgeRow(vibeStrings: vibes, size: .small)
                }
                
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

