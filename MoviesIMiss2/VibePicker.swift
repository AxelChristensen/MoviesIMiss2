//
//  VibePicker.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/21/26.
//

import SwiftUI

struct VibePicker: View {
    @Binding var selectedVibe: String?
    @Binding var vibeNotes: String
    
    let vibes = MovieVibe.allCases
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What's the vibe? ✨")
                .font(.headline)
            
            Text("Pick the feeling this movie gave you")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(vibes) { vibe in
                    VibeButton(
                        vibe: vibe,
                        isSelected: selectedVibe == vibe.rawValue
                    ) {
                        if selectedVibe == vibe.rawValue {
                            selectedVibe = nil
                        } else {
                            selectedVibe = vibe.rawValue
                        }
                    }
                }
            }
            
            // Optional notes field
            if selectedVibe != nil {
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
        .animation(.easeInOut, value: selectedVibe)
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

// View for displaying a vibe badge in lists
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

#Preview("Vibe Picker") {
    VibePicker(
        selectedVibe: .constant("Cozy"),
        vibeNotes: .constant("")
    )
    .padding()
}

#Preview("Vibe Badges") {
    VStack(spacing: 16) {
        VibeBadge(vibeString: "Cozy", size: .small)
        VibeBadge(vibeString: "Intense", size: .medium)
        VibeBadge(vibeString: "Uplifting", size: .large)
    }
    .padding()
}
