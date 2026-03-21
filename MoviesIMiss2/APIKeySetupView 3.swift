//
//  APIKeySetupView.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/19/26.
//

import SwiftUI

struct APIKeySetupView: View {
    @State private var apiKey: String = ""
    @State private var isValidating = false
    @State private var errorMessage: String?
    @State private var showingInstructions = false
    @State private var tmdbService = TMDBService()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Image(systemName: "film.stack")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue.gradient)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical)
                    
                    Text("Welcome to MoviesIMiss!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("To get started, you'll need a free API key from The Movie Database (TMDB).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom)
                } header: {
                    EmptyView()
                }
                .listRowBackground(Color.clear)
                
                Section {
                    TextField("Enter your TMDB API key", text: $apiKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.asciiCapable)
                        #endif
                    
                    if let errorMessage = errorMessage {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("API Key")
                } footer: {
                    Text("Your API key is stored securely in the Keychain and never shared.")
                }
                
                Section {
                    Button {
                        showingInstructions = true
                    } label: {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("How to get an API key")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Need Help?")
                }
                
                Section {
                    Button {
                        validateAndSaveAPIKey()
                    } label: {
                        HStack {
                            Spacer()
                            if isValidating {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                Text("Validating...")
                            } else {
                                Text("Continue")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(apiKey.isEmpty || isValidating)
                }
            }
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingInstructions) {
                APIKeyInstructionsView()
            }
        }
    }
    
    private func validateAndSaveAPIKey() {
        isValidating = true
        errorMessage = nil
        
        // Set the API key temporarily to test it
        tmdbService.setAPIKey(apiKey.trimmingCharacters(in: .whitespacesAndNewlines))
        
        Task {
            do {
                // Try to fetch a single movie to validate the key
                _ = try await tmdbService.fetchTopRated(page: 1)
                
                // If successful, the key is already saved by setAPIKey
                await MainActor.run {
                    isValidating = false
                    // Trigger ContentView to refresh
                    NotificationCenter.default.post(name: NSNotification.Name("APIKeyUpdated"), object: nil)
                }
            } catch {
                await MainActor.run {
                    isValidating = false
                    errorMessage = "Invalid API key. Please check and try again."
                    // Clear the invalid key
                    tmdbService.clearAPIKey()
                }
            }
        }
    }
}

struct APIKeyInstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    instructionStep(
                        number: "1",
                        title: "Create a TMDB Account",
                        description: "Visit themoviedb.org and sign up for a free account."
                    )
                    
                    instructionStep(
                        number: "2",
                        title: "Go to API Settings",
                        description: "Once logged in, go to your account Settings, then select 'API' from the left sidebar."
                    )
                    
                    instructionStep(
                        number: "3",
                        title: "Request an API Key",
                        description: "Click 'Request an API Key' and select 'Developer'. Fill out the simple form (you can use placeholder information for personal use)."
                    )
                    
                    instructionStep(
                        number: "4",
                        title: "Copy Your API Key",
                        description: "Once approved (usually instant), copy your API Key (v3 auth) and paste it into the app."
                    )
                    
                    Divider()
                        .padding(.vertical)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Label("It's completely free", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Label("Takes less than 2 minutes", systemImage: "clock.fill")
                            .foregroundStyle(.blue)
                        Label("Your key stays private", systemImage: "lock.fill")
                            .foregroundStyle(.purple)
                    }
                    .font(.subheadline)
                    
                    #if os(iOS)
                    Button {
                        if let url = URL(string: "https://www.themoviedb.org/signup") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Open TMDB Website")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.up.right")
                            Spacer()
                        }
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                    }
                    .padding(.top)
                    #else
                    Link(destination: URL(string: "https://www.themoviedb.org/signup")!) {
                        HStack {
                            Spacer()
                            Text("Open TMDB Website")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.up.right")
                            Spacer()
                        }
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                    }
                    .padding(.top)
                    #endif
                }
                .padding()
            }
            .navigationTitle("Get API Key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func instructionStep(number: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(number)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.blue.gradient)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(.blue.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview("Setup View") {
    APIKeySetupView()
}

#Preview("Instructions") {
    APIKeyInstructionsView()
}
