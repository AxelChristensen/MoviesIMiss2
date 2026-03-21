//
//  MovieVibe.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/21/26.
//

import SwiftUI

enum MovieVibe: String, CaseIterable, Identifiable {
    case cozy = "Cozy"
    case intense = "Intense"
    case uplifting = "Uplifting"
    case nostalgic = "Nostalgic"
    case thoughtProvoking = "Thought-Provoking"
    case emotional = "Emotional"
    case fun = "Fun"
    case dark = "Dark"
    case inspiring = "Inspiring"
    case relaxing = "Relaxing"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .cozy: return "flame.fill"
        case .intense: return "bolt.fill"
        case .uplifting: return "arrow.up.heart.fill"
        case .nostalgic: return "clock.arrow.circlepath"
        case .thoughtProvoking: return "brain.head.profile"
        case .emotional: return "heart.fill"
        case .fun: return "star.fill"
        case .dark: return "moon.fill"
        case .inspiring: return "sparkles"
        case .relaxing: return "leaf.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .cozy: return .orange
        case .intense: return .red
        case .uplifting: return .green
        case .nostalgic: return .purple
        case .thoughtProvoking: return .blue
        case .emotional: return .pink
        case .fun: return .yellow
        case .dark: return .indigo
        case .inspiring: return .cyan
        case .relaxing: return .mint
        }
    }
    
    var description: String {
        switch self {
        case .cozy: return "Perfect for a comfy night in"
        case .intense: return "High energy and gripping"
        case .uplifting: return "Feel-good and heartwarming"
        case .nostalgic: return "Takes you back in time"
        case .thoughtProvoking: return "Makes you think deeply"
        case .emotional: return "Touches your heart"
        case .fun: return "Pure entertainment"
        case .dark: return "Moody and atmospheric"
        case .inspiring: return "Motivates and encourages"
        case .relaxing: return "Calm and soothing"
        }
    }
}
