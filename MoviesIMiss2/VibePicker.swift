//
//  VibePicker.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/21/26.
//

import SwiftUI

struct VibePicker: View {
    @Binding var selectedVibes: [String]  // Changed to array
    @Binding var vibeNotes: String
    
    let vibes = MovieVibe.allCases
    
    private func isSelected(_ vibe: MovieVibe) -> Bool {
        selectedVibes.contains(vibe.rawValue)
    }
    
    private func toggleVibe(_ vibe: MovieVibe) {
        if let index = selectedVibes.firstIndex(of: vibe.rawValue) {
            selectedVibes.remove(at: index)
        } else {
            selectedVibes.append(vibe.rawValue)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("What's the vibe? ✨")
                    .font(.headline)
                
                Text("Pick all the feelings this movie gave you")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(vibes) { vibe in
                    VibeButton(
                        vibe: vibe,
                        isSelected: isSelected(vibe)
                    ) {
                        toggleVibe(vibe)
                    }
                }
            }
            
            // Optional notes field
            if !selectedVibes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add a note (optional)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    TextField("What made it feel this way?", text: $vibeNotes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: selectedVibes)
    }
}

struct VibeButton: View {
    let vibe: MovieVibe
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: vibe.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? vibe.color : .secondary)
                
                Text(vibe.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(isSelected ? vibe.color : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? vibe.color.opacity(0.15) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? vibe.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// View for displaying vibe badges in lists
struct VibeBadge: View {
    let vibeString: String
    let size: BadgeSize
    
    enum BadgeSize {
        case small, medium, large
        
        var fontSize: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }
        
        var iconSize: Font {
            switch self {
            case .small: return .caption
            case .medium: return .body
            case .large: return .title3
            }
        }
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .medium: return EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
            case .large: return EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            }
        }
    }
    
    var vibe: MovieVibe? {
        MovieVibe(rawValue: vibeString)
    }
    
    var body: some View {
        if let vibe = vibe {
            HStack(spacing: 4) {
                Image(systemName: vibe.icon)
                    .font(size.iconSize)
                Text(vibe.rawValue)
                    .font(size.fontSize)
                    .fontWeight(.medium)
            }
            .foregroundStyle(vibe.color)
            .padding(size.padding)
            .background(vibe.color.opacity(0.15))
            .clipShape(Capsule())
        }
    }
}

// View for displaying multiple vibes
struct VibesBadgeRow: View {
    let vibeStrings: [String]
    let size: VibeBadge.BadgeSize
    
    var body: some View {
        if !vibeStrings.isEmpty {
            HStack(spacing: 6) {
                ForEach(vibeStrings, id: \.self) { vibeString in
                    VibeBadge(vibeString: vibeString, size: size)
                }
            }
        }
    }
}

#Preview("Vibe Picker") {
    VibePicker(
        selectedVibes: .constant(["Cozy", "Uplifting"]),
        vibeNotes: .constant("")
    )
    .padding()
}

#Preview("Vibe Badges") {
    VStack(spacing: 16) {
        VibeBadge(vibeString: "Cozy", size: .small)
        VibeBadge(vibeString: "Intense", size: .medium)
        VibeBadge(vibeString: "Uplifting", size: .large)
        
        Divider()
        
        VibesBadgeRow(vibeStrings: ["Cozy", "Fun", "Uplifting"], size: .small)
    }
    .padding()
}
