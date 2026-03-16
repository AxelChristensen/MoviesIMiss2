//
//  MovieStatus.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import Foundation

enum MovieStatus: String, Codable {
    case pending = "pending"           // In the list to review
    case wantToWatch = "wantToWatch"   // User wants to add it
    case watched = "watched"           // User has watched it
    case snoozed = "snoozed"           // Snoozed for later
    case removed = "removed"           // Removed from list
}
