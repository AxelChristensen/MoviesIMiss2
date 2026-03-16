//
//  SavedMovie.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import Foundation
import SwiftData

@Model
final class SavedMovie {
    var tmdbId: Int
    var title: String
    var year: String
    var overview: String
    var posterPath: String?
    var lastWatched: Date?
    var dateAdded: Date
    
    // Additional fields from PRD requirements
    var hasSeenBefore: Bool
    var moodWhenWatched: String?
    var moodItHelpsWithString: String?
    var approximateWatchDate: Date?
    var nextRewatchDate: Date?
    
    // Store status as String for SwiftData compatibility
    var statusRawValue: String
    
    // Computed property for type-safe access
    var status: MovieStatus {
        get {
            MovieStatus(rawValue: statusRawValue) ?? .pending
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
    init(
        tmdbId: Int,
        title: String,
        year: String,
        overview: String,
        posterPath: String? = nil,
        lastWatched: Date? = nil,
        hasSeenBefore: Bool = false,
        moodWhenWatched: String? = nil,
        moodItHelpsWithString: String? = nil,
        approximateWatchDate: Date? = nil,
        status: MovieStatus = .pending
    ) {
        self.tmdbId = tmdbId
        self.title = title
        self.year = year
        self.overview = overview
        self.posterPath = posterPath
        self.lastWatched = lastWatched
        self.dateAdded = Date()
        self.hasSeenBefore = hasSeenBefore
        self.moodWhenWatched = moodWhenWatched
        self.moodItHelpsWithString = moodItHelpsWithString
        self.approximateWatchDate = approximateWatchDate
        self.statusRawValue = status.rawValue
    }
}

