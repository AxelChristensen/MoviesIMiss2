//
//  ContentView.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var tmdbService = TMDBService()
    
    var body: some View {
        Group {
            if tmdbService.hasAPIKey {
                mainTabView
            } else {
                APIKeySetupView()
            }
        }
    }
    
    private var mainTabView: some View {
        TabView {
            MovieListView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
            
            AgainListView()
                .tabItem {
                    Label("Again!", systemImage: "arrow.triangle.2.circlepath")
                }
            
            NewMoviesView()
                .tabItem {
                    Label("New!", systemImage: "sparkles")
                }
            
            ActorSearchView()
                .tabItem {
                    Label("Actors", systemImage: "person.fill.viewfinder")
                }
            
            NotificationDebugView()
                .tabItem {
                    Label("Debug", systemImage: "hammer.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SavedMovie.self, inMemory: true)
}
