//
//  TMDBModels.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/15/26.
//

import Foundation

struct TMDBMovieResponse: Codable {
    let results: [TMDBMovie]
    let page: Int
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case results, page
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct TMDBMovie: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let releaseDate: String?
    let overview: String
    let posterPath: String?
    let voteAverage: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
    }
    
    var year: String {
        guard let releaseDate = releaseDate, releaseDate.count >= 4 else {
            return "Unknown"
        }
        return String(releaseDate.prefix(4))
    }
    
    func posterURL(size: TMDBImageSize = .w200) -> URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/\(size.rawValue)\(posterPath)")
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TMDBMovie, rhs: TMDBMovie) -> Bool {
        lhs.id == rhs.id
    }
}

enum TMDBImageSize: String {
    case w200 = "w200"
    case w500 = "w500"
    case original = "original"
}

// MARK: - Actor/Person Models

struct TMDBPersonResponse: Codable {
    let results: [TMDBPerson]
    let page: Int
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case results, page
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct TMDBPerson: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let knownForDepartment: String?
    let profilePath: String?
    let knownFor: [TMDBKnownForMovie]?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case knownForDepartment = "known_for_department"
        case profilePath = "profile_path"
        case knownFor = "known_for"
    }
    
    func profileURL(size: TMDBProfileImageSize = .w185) -> URL? {
        guard let profilePath = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/\(size.rawValue)\(profilePath)")
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TMDBPerson, rhs: TMDBPerson) -> Bool {
        lhs.id == rhs.id
    }
}

struct TMDBKnownForMovie: Codable, Hashable {
    let id: Int
    let title: String?
    let name: String? // For TV shows
    let mediaType: String
    let posterPath: String?
    let releaseDate: String?
    let overview: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, name, overview
        case mediaType = "media_type"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
    }
    
    var displayTitle: String {
        title ?? name ?? "Unknown"
    }
}

struct TMDBMovieCreditsResponse: Codable {
    let cast: [TMDBCastMember]
    let crew: [TMDBCrewMember]
}

struct TMDBCastMember: Codable, Identifiable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?
    let order: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, character, order
        case profilePath = "profile_path"
    }
}

struct TMDBCrewMember: Codable {
    let id: Int
    let name: String
    let job: String?
    let department: String?
    let profilePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, job, department
        case profilePath = "profile_path"
    }
}

enum TMDBProfileImageSize: String {
    case w45 = "w45"
    case w185 = "w185"
    case h632 = "h632"
    case original = "original"
}

// MARK: - Watch Provider Models
struct TMDBWatchProvidersResponse: Codable {
    let results: [String: TMDBCountryProviders]
    
    // Get watch providers for a specific country (e.g., "US")
    func providers(for countryCode: String) -> TMDBCountryProviders? {
        results[countryCode]
    }
}

struct TMDBCountryProviders: Codable {
    let link: String? // JustWatch link
    let flatrate: [TMDBProvider]? // Streaming services (Netflix, Disney+, etc.)
    let buy: [TMDBProvider]? // Purchase options (iTunes, Amazon, etc.)
    let rent: [TMDBProvider]? // Rental options
    let ads: [TMDBProvider]? // Free with ads (Tubi, Pluto TV, etc.)
}

struct TMDBProvider: Codable, Identifiable, Hashable {
    let providerId: Int
    let providerName: String
    let logoPath: String
    let displayPriority: Int
    
    enum CodingKeys: String, CodingKey {
        case providerId = "provider_id"
        case providerName = "provider_name"
        case logoPath = "logo_path"
        case displayPriority = "display_priority"
    }
    
    var id: Int { providerId }
    
    func logoURL(size: TMDBLogoSize = .w92) -> URL? {
        URL(string: "https://image.tmdb.org/t/p/\(size.rawValue)\(logoPath)")
    }
}

enum TMDBLogoSize: String {
    case w92 = "w92"
    case w154 = "w154"
    case w185 = "w185"
    case original = "original"
}


