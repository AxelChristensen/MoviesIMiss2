//
//  WatchProviderFilter.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/21/26.
//

import Foundation

/// Filter options for streaming providers
struct WatchProviderFilter {
    var selectedProviders: Set<Int> = [] // Provider IDs
    var onlyFreeToWatch: Bool = false // Only show flatrate/ads, exclude rent/buy
    var countryCode: String = "US"
    
    var isActive: Bool {
        !selectedProviders.isEmpty || onlyFreeToWatch
    }
}

/// Common streaming providers for quick filtering
enum StreamingProvider: String, CaseIterable, Identifiable {
    case all = "All Services"
    case netflix = "Netflix"
    case amazonPrimeFree = "Amazon Prime (Free)"
    case amazonPrimeRental = "Amazon Prime (Rental/Buy)"
    case disneyPlus = "Disney Plus"
    case hulu = "Hulu"
    case hboMax = "Max"
    case appleTV = "Apple TV Plus"
    case peacock = "Peacock"
    case paramountPlus = "Paramount Plus"
    case amcPlus = "AMC+"
    case youtubeTv = "YouTube TV"
    case tubi = "Tubi TV"
    case plutoTV = "Pluto TV"
    
    var id: String { rawValue }
    
    /// TMDB provider ID (US region)
    /// Note: Returns primary ID for backward compatibility. Use providerIds for complete list.
    var providerId: Int? {
        providerIds.first
    }
    
    /// All TMDB provider IDs for this service (some services have multiple IDs)
    var providerIds: [Int] {
        switch self {
        case .all: return []
        case .netflix: return [8]
        case .amazonPrimeFree: return [9] // Prime Video flatrate (free streaming)
        case .amazonPrimeRental: return [10] // Amazon Video rent/buy (different ID!)
        case .disneyPlus: return [337]
        case .hulu: return [15, 2953] // 15 = Hulu, 2953 = Hulu (No Ads)
        case .hboMax: return [1899, 1825, 384] // 1899 = Max, 1825 = HBO Max Amazon Channel, 384 = HBO Now (legacy)
        case .appleTV: return [350, 2552] // 350 = Apple TV+, 2552 = Apple TV+ Amazon Channel
        case .peacock: return [386, 3353] // 386 = Peacock Premium, 3353 = Peacock Premium Plus
        case .paramountPlus: return [531, 1853, 582] // 531 = Main, 1853 = Apple TV Channel, 582 = Amazon Channel
        case .amcPlus: return [528, 635, 526] // 528 = Amazon Channel, 635 = Roku Channel, 526 = AMC
        case .youtubeTv: return [2528] // YouTube TV
        case .tubi: return [283]
        case .plutoTV: return [300]
        }
    }
    
    /// Whether this filter should only show free content
    var isFreeOnly: Bool {
        switch self {
        case .amazonPrimeFree, .tubi, .plutoTV:
            return true
        case .amazonPrimeRental:
            return false
        default:
            return false // Other services show all availability types
        }
    }
    
    /// Whether this is a rental/purchase only filter
    var isRentalOnly: Bool {
        self == .amazonPrimeRental
    }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .netflix: return "play.tv.fill"
        case .amazonPrimeFree: return "cart.fill.badge.plus"
        case .amazonPrimeRental: return "cart.fill"
        case .disneyPlus: return "sparkles"
        case .hulu: return "play.rectangle.fill"
        case .hboMax: return "tv.fill"
        case .appleTV: return "applelogo"
        case .peacock: return "bird.fill"
        case .paramountPlus: return "mountain.2.fill"
        case .amcPlus: return "film.stack.fill"
        case .youtubeTv: return "play.rectangle.on.rectangle.fill"
        case .tubi: return "tv.circle.fill"
        case .plutoTV: return "antenna.radiowaves.left.and.right"
        }
    }
    
    var color: String {
        switch self {
        case .all: return "blue"
        case .netflix: return "red"
        case .amazonPrimeFree: return "blue"
        case .amazonPrimeRental: return "orange"
        case .disneyPlus: return "blue"
        case .hulu: return "green"
        case .hboMax: return "purple"
        case .appleTV: return "gray"
        case .peacock: return "yellow"
        case .paramountPlus: return "blue"
        case .amcPlus: return "orange"
        case .youtubeTv: return "red"
        case .tubi: return "orange"
        case .plutoTV: return "yellow"
        }
    }
}

extension TMDBCountryProviders {
    /// Check if any of the streaming options include a specific provider
    func hasProvider(id: Int, freeOnly: Bool = false, rentalOnly: Bool = false) -> Bool {
        if rentalOnly {
            // Only check rent and buy options
            let rentMatch = rent?.contains(where: { $0.providerId == id }) ?? false
            let buyMatch = buy?.contains(where: { $0.providerId == id }) ?? false
            let result = rentMatch || buyMatch
            
            #if DEBUG
            if result {
                print("  🔍 Rental/Buy match for provider \(id)")
                if rentMatch { print("    - Found in rent") }
                if buyMatch { print("    - Found in buy") }
            }
            #endif
            
            return result
        } else if freeOnly {
            // Only check flatrate (subscription streaming) and ads (free with ads)
            let flatrateMatch = flatrate?.contains(where: { $0.providerId == id }) ?? false
            let adsMatch = ads?.contains(where: { $0.providerId == id }) ?? false
            let result = flatrateMatch || adsMatch
            
            #if DEBUG
            if result {
                print("  ✅ Free match for provider \(id)")
                if flatrateMatch { print("    - Found in flatrate (free with subscription)") }
                if adsMatch { print("    - Found in ads (free with ads)") }
            }
            #endif
            
            return result
        } else {
            // Check all provider types
            let flatrateMatch = flatrate?.contains(where: { $0.providerId == id }) ?? false
            let adsMatch = ads?.contains(where: { $0.providerId == id }) ?? false
            let rentMatch = rent?.contains(where: { $0.providerId == id }) ?? false
            let buyMatch = buy?.contains(where: { $0.providerId == id }) ?? false
            return flatrateMatch || adsMatch || rentMatch || buyMatch
        }
    }
    
    /// Check if any of the streaming options include ANY of the specified provider IDs
    func hasAnyProvider(ids: [Int], freeOnly: Bool = false, rentalOnly: Bool = false) -> Bool {
        for id in ids {
            if hasProvider(id: id, freeOnly: freeOnly, rentalOnly: rentalOnly) {
                return true
            }
        }
        return false
    }
    
    /// Check if the movie is available for free (either subscription or ad-supported)
    var hasFreeOptions: Bool {
        let hasFlatrate = flatrate?.isEmpty == false
        let hasAds = ads?.isEmpty == false
        return hasFlatrate || hasAds
    }
    
    /// Get all provider IDs from all categories
    var allProviderIds: Set<Int> {
        var ids = Set<Int>()
        flatrate?.forEach { ids.insert($0.providerId) }
        ads?.forEach { ids.insert($0.providerId) }
        rent?.forEach { ids.insert($0.providerId) }
        buy?.forEach { ids.insert($0.providerId) }
        return ids
    }
    
    /// Debug description of providers
    var debugDescription: String {
        var desc = "Providers: "
        if let flatrate = flatrate, !flatrate.isEmpty {
            desc += "flatrate[\(flatrate.map { "\($0.providerName) (ID:\($0.providerId))" }.joined(separator: ", "))] "
        }
        if let ads = ads, !ads.isEmpty {
            desc += "ads[\(ads.map { "\($0.providerName) (ID:\($0.providerId))" }.joined(separator: ", "))] "
        }
        if let rent = rent, !rent.isEmpty {
            desc += "rent[\(rent.map { "\($0.providerName) (ID:\($0.providerId))" }.joined(separator: ", "))] "
        }
        if let buy = buy, !buy.isEmpty {
            desc += "buy[\(buy.map { "\($0.providerName) (ID:\($0.providerId))" }.joined(separator: ", "))] "
        }
        return desc.isEmpty ? "No providers" : desc
    }
}
