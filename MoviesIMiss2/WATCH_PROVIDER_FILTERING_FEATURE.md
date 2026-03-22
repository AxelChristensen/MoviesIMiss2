# Watch Provider Filtering Feature

## Overview
Added comprehensive filtering capabilities to the Browse tab, allowing users to filter movies by streaming service and whether they're available for free (included with subscription or ad-supported).

## Features

### 1. Filter by Streaming Service
Users can filter the Browse list to show only movies available on specific services:

**Subscription Services:**
- Netflix
- Amazon Prime Video
- Disney+
- Hulu
- Max (HBO Max)
- Apple TV+
- Peacock
- Paramount+

**Free (Ad-Supported):**
- Tubi TV
- Pluto TV

### 2. Free to Watch Filter
A dedicated "Free Only" toggle that filters movies to show only those available:
- As part of a streaming subscription (flatrate)
- Free with ads
- **Excludes** rental and purchase-only options

### 3. Amazon Prime Example
When filtering by Amazon Prime Video with "Free Only" enabled:
- ✅ Shows movies included with Prime membership
- ❌ Hides movies only available to rent/buy on Prime Video

## Implementation Details

### New Files

#### WatchProviderFilter.swift
- `WatchProviderFilter`: Struct managing filter state
- `StreamingProvider`: Enum of popular streaming services with TMDB provider IDs
- Extension on `TMDBCountryProviders` for provider matching

**Key Methods:**
```swift
// Check if provider has a specific service
func hasProvider(id: Int, freeOnly: Bool = false) -> Bool

// Check if any free options are available
var hasFreeOptions: Bool
```

### Updated Files

#### TMDBService.swift
Added batch provider fetching for better performance:

```swift
func fetchWatchProvidersForMovies(movieIds: [Int], countryCode: String = "US") async -> [Int: TMDBCountryProviders]
```

This method fetches watch providers for multiple movies concurrently using structured concurrency.

#### MovieListView.swift
Added complete filtering integration:

**New State Variables:**
```swift
@State private var selectedStreamingProvider: StreamingProvider = .all
@State private var onlyShowFreeToWatch = false
@State private var watchProviderCache: [Int: TMDBCountryProviders] = [:]
@State private var isLoadingProviders = false
```

**New Computed Properties:**
- `filteredPendingMovies`: Filters movies based on watch provider selection
- Updated `hasActiveFilters` to include provider filters

**New UI Components:**
- `streamingProviderMenu`: Dropdown menu for selecting streaming service
- `freeOnlyToggle`: Toggle button for free-only filtering
- `providerButton(for:)`: Individual provider selection buttons

**Provider Loading:**
- `loadWatchProviders()`: Batch loads provider data for all pending movies
- Smart caching prevents redundant API calls
- Concurrent loading for better performance

### Filtering Logic

#### Basic Filtering
When a user selects a streaming service:
1. Provider data is loaded for all pending movies (if not cached)
2. Movies are filtered to show only those available on that service
3. Results include all availability types (stream, rent, buy, ads)

#### Free-Only Filtering
When "Free Only" is enabled:
1. If a specific service is selected:
   - Shows only movies available on that service **for free**
   - Example: Prime Video - shows included titles, hides rentals
2. If "All Services" is selected:
   - Shows movies available for free on **any** service
   - Includes both subscription and ad-supported options

### Performance Optimizations

1. **Caching**: Provider data is cached to avoid repeated API calls
2. **Batch Loading**: Uses concurrent task groups to fetch multiple providers simultaneously
3. **Lazy Loading**: Providers only loaded when filters are applied
4. **Smart Updates**: Cache is cleared when filters are reset

## User Experience

### Filter Workflow

1. **Browse movies** normally
2. **Tap streaming service menu** in toolbar
3. **Select a service** (e.g., "Amazon Prime Video")
4. **Toggle "Free Only"** if you only want included content
5. List filters to show matching movies only
6. **Reset filters** to see all movies again

### Visual Indicators

- **Service icon** appears in toolbar when selected
- **"Free Only ✓"** shows when free filtering is active
- **Filter count** reflected in "Reset Filters" availability

### Edge Cases Handled

- Movies without provider data are included (optimistic filtering)
- Empty results show appropriate message
- Filters work alongside existing filters (decade, rating, actor)
- Cache clears when switching categories or resetting filters

## Technical Notes

### TMDB Provider IDs (US Region)

These IDs are hardcoded for the US region. To support other countries:

```swift
// Current implementation
watchProviders = response.providers(for: "US")

// Multi-country support
@AppStorage("preferredCountry") private var country = "US"
watchProviders = response.providers(for: country)
```

### Provider ID Mapping

```swift
Netflix: 8
Amazon Prime Video: 9
Disney+: 337
Hulu: 15
Max: 1899
Apple TV+: 350
Peacock: 386
Paramount+: 531
Tubi: 283
Pluto TV: 300
```

### API Response Structure

TMDB returns providers in four categories:
- `flatrate`: Subscription streaming (Netflix, Prime Video, etc.)
- `ads`: Free with ads (Tubi, Pluto TV, etc.)
- `rent`: Rental options
- `buy`: Purchase options

The "Free Only" filter includes `flatrate` and `ads`, excluding `rent` and `buy`.

## Future Enhancements

### Multi-Service Filtering
Allow users to select multiple services:
```swift
@State private var selectedProviders: Set<Int> = []
```

### Country Selection
Add settings to choose user's country:
- US
- UK
- Canada
- Australia
- etc.

### Saved Filter Preferences
Remember user's preferred service:
```swift
@AppStorage("preferredStreamingService") private var preferredService: String
```

### Provider Availability Badges
Show provider logos on movie rows to see at a glance where each movie is available.

### Price Range Filtering
If TMDB adds pricing data, could filter by:
- Free
- Under $5 rental
- Under $15 purchase
- etc.

### Availability Alerts
Notify when a movie from watchlist becomes available on user's preferred service.

## Testing

### Test Scenarios

1. **Select Netflix** → Should show only Netflix movies
2. **Select Prime + Free Only** → Should show Prime included titles, hide rentals
3. **Enable Free Only alone** → Should show movies free on any service
4. **Combine with other filters** → Should work with decade/rating/actor filters
5. **Reset filters** → Should clear provider selections and cache

### Known Limitations

- Provider data may not be available for all movies
- Availability varies by country (currently US-only)
- Some movies may have incomplete provider information
- API rate limits apply to batch provider fetching

## Resources

- [TMDB Watch Providers API](https://developers.themoviedb.org/3/movies/get-movie-watch-providers)
- [JustWatch](https://www.justwatch.com) - Source of TMDB provider data
- [TMDB Provider IDs](https://developers.themoviedb.org/3/watch-providers/get-available-regions)

## Code Example

### Basic Usage
```swift
// User selects Amazon Prime Video from menu
selectedStreamingProvider = .amazonPrime

// Toggle free-only filtering
onlyShowFreeToWatch = true

// Providers are loaded automatically
await loadWatchProviders()

// Movies are filtered automatically via computed property
// filteredPendingMovies now shows only Prime included titles
```

### Provider Checking
```swift
// Check if movie has specific provider
if let providers = watchProviderCache[movie.tmdbId] {
    let hasPrime = providers.hasProvider(id: 9, freeOnly: true)
    // hasPrime is true only if movie is included with Prime (not rental)
}
```

### Adding New Provider
```swift
enum StreamingProvider {
    // ...existing cases...
    case newService = "New Service Name"
    
    var providerId: Int? {
        switch self {
        // ...existing cases...
        case .newService: return 123 // TMDB provider ID
        }
    }
}
```

## Summary

This feature gives users powerful control over movie browsing by filtering based on where they can watch. The "Free Only" option is particularly useful for Prime Video users who want to distinguish between included and rental content, solving a common pain point with streaming services.
