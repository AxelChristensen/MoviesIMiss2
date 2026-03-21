//
//  ContentView.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import SwiftUI
import SwiftData

#if os(iOS)
import UIKit
#endif

struct ContentView: View {
    @State private var tmdbService = TMDBService()
    @State private var apiKeyUpdated = false
    
    var body: some View {
        Group {
            if tmdbService.hasAPIKey {
                mainTabView
            } else {
                APIKeySetupView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("APIKeyUpdated"))) { _ in
            // Force reload of tmdbService to check for new API key
            tmdbService = TMDBService()
            apiKeyUpdated.toggle() // Trigger view update
        }
    }
    
    private var mainTabView: some View {
        #if os(iOS)
        // On iPad, prefer sidebar navigation; on iPhone, use tabs
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                sidebarNavigation
            } else {
                tabNavigation
            }
        }
        #else
        sidebarNavigation
        #endif
    }
    
    private var tabNavigation: some View {
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
    
    private var sidebarNavigation: some View {
        NavigationSplitView {
            List {
                NavigationLink {
                    MovieListView()
                } label: {
                    Label("Browse", systemImage: "magnifyingglass")
                }
                
                NavigationLink {
                    AgainListView()
                } label: {
                    Label("Again!", systemImage: "arrow.triangle.2.circlepath")
                }
                
                NavigationLink {
                    NewMoviesView()
                } label: {
                    Label("New!", systemImage: "sparkles")
                }
                
                NavigationLink {
                    ActorSearchView()
                } label: {
                    Label("Actors", systemImage: "person.fill.viewfinder")
                }
                
                Section("Developer") {
                    NavigationLink {
                        NotificationDebugView()
                    } label: {
                        Label("Debug", systemImage: "hammer.fill")
                    }
                }
            }
            .navigationTitle("MoviesIMiss")
        } detail: {
            ContentUnavailableView(
                "Select a Section",
                systemImage: "film",
                description: Text("Choose a category from the sidebar to get started")
            )
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SavedMovie.self, inMemory: true)
}
