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
    @State private var showingAbout = false
    
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
        .sheet(isPresented: $showingAbout) {
            AboutView()
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
            MovieListView(showingAbout: $showingAbout)
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
                
                Section {
                    Button {
                        showingAbout = true
                    } label: {
                        Label("About", systemImage: "info.circle")
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

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .center, spacing: 12) {
                        Image(systemName: "film.stack.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                        
                        Text("MoviesIMiss")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                .listRowBackground(Color.clear)
                
                Section("Attribution") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            // TMDB Logo placeholder (blue background with white text)
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 0.01, green: 0.83, blue: 0.84)) // TMDB teal color
                                    .frame(width: 60, height: 60)
                                
                                VStack(spacing: 2) {
                                    Text("TMDB")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.white)
                                    Text("API")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(.white.opacity(0.9))
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TMDB")
                                    .font(.headline)
                                Text("The Movie Database")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.bottom, 8)
                        
                        Text("This product uses the TMDB API but is not endorsed or certified by TMDB.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Developer") {
                    HStack {
                        Text("Created by")
                        Spacer()
                        Text("Axel Christensen")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Year")
                        Spacer()
                        Text("2026")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("About")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SavedMovie.self, inMemory: true)
}
