//
//
//  APIKeySetupView.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import SwiftUI

struct APIKeySetupView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "key.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("TMDB API Key Required")
                .font(.title)
                .fontWeight(.bold)
            
            Text("To use MoviesIMiss, you need a free API key from The Movie Database (TMDB).")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                SetupStep(number: 1, text: "Visit themoviedb.org and create a free account")
                SetupStep(number: 2, text: "Go to Settings → API and request an API key")
                SetupStep(number: 3, text: "Create a file named 'Secrets.plist' in your Xcode project")
                SetupStep(number: 4, text: "Add a key named 'TMDB_API_KEY' with your API key as the value")
                SetupStep(number: 5, text: "Relaunch the app")
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(12)
            .padding(.horizontal)
            
            Link(destination: URL(string: "https://www.themoviedb.org/settings/api")!) {
                Label("Open TMDB API Settings", systemImage: "arrow.up.right")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct SetupStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.blue))
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    APIKeySetupView()
}
