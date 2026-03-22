# Watch Providers Feature Implementation

## Overview
Added "Where to Watch" functionality to movie details, showing streaming availability, rental options, purchase options, and free ad-supported platforms.

## Implementation Details

### 1. Data Models (TMDBModels.swift)
Added new models to handle watch provider data from TMDB API:

- **TMDBWatchProvidersResponse**: Response wrapper containing providers by country code
- **TMDBCountryProviders**: Provider data for a specific country (streaming, rental, purchase, ads)
- **TMDBProvider**: Individual provider details (Netflix, Disney+, etc.)
- **TMDBLogoSize**: Image size options for provider logos

### 2. API Service (TMDBService.swift)
Added `fetchWatchProviders(movieId:)` method that:
- Calls TMDB's `/movie/{id}/watch/providers` endpoint
- Returns streaming availability data by country
- Handles errors consistently with existing error handling

### 3. UI Implementation

Added watch providers to both movie detail views:

#### MovieDetailView.swift (Used in "Again" list)

#### New State Properties
- `watchProviders`: Stores provider data for the current movie
- `isLoadingProviders`: Loading state indicator
- `tmdbService`: Service instance for API calls

#### New UI Components

**whereToWatchSection**
- Main section displaying all watch options
- Shows different provider categories:
  - Stream (Netflix, Disney+, Hulu, etc.)
  - Free with ads (Tubi, Pluto TV, etc.)
  - Rent (iTunes, Amazon, Vudu, etc.)
  - Buy (iTunes, Amazon, etc.)
- Includes link to JustWatch for complete information
- Shows appropriate message when no providers available

**ProviderGroup**
- Reusable component for each provider category
- Color-coded icons for easy identification:
  - Blue for streaming
  - Green for free with ads
  - Orange for rental
  - Purple for purchase
- Horizontal scrollable list of provider logos
- Providers sorted by display priority

**ProviderLogo**
- Individual provider logo display
- Shows provider logo from TMDB
- Includes provider name below logo
- Graceful fallback for missing images

#### Data Loading
- Uses `.task` modifier to load providers when view appears
- Currently configured for US region ("US")
- Can be easily modified to support user's locale or country selection

#### MovieDecisionView.swift (Used in "Browse" section)

Same implementation as MovieDetailView:
- Added `watchProviders` and `isLoadingProviders` state properties
- Added `whereToWatchSection` view
- Added `loadWatchProviders()` method
- Uses `.task` modifier to load providers automatically

**Note:** Both views now show streaming availability, so users can see where to watch movies whether they're browsing new options or reviewing their saved list.

## API Endpoint Used

```
GET /movie/{movie_id}/watch/providers
```

**Response includes:**
- Streaming services (flatrate)
- Rental options (rent)
- Purchase options (buy)
- Free ad-supported options (ads)
- JustWatch link for more details

## User Experience

1. When viewing movie details, providers load automatically
2. Shows clear categories: Stream, Free (with ads), Rent, Buy
3. Visual provider logos for easy recognition
4. Link to JustWatch for comprehensive viewing options
5. Graceful handling when no providers are available

## Future Enhancements

### Country/Region Selection
Currently hardcoded to "US". Could add:
```swift
@AppStorage("preferredCountry") private var preferredCountry = "US"
```

Then allow users to select their country in settings.

### Deep Links
Could add deep links to open apps directly:
- Netflix: `netflix://`
- Disney+: `disneyplus://`
- Hulu: `hulu://`
- etc.

### Price Information
TMDB API doesn't include pricing, but could:
- Link to provider websites
- Show "HD/SD/4K" availability if added to API response
- Cache provider availability for offline viewing

### Availability Notifications
Could add feature to notify when a movie becomes available on user's preferred streaming service.

## Testing Notes

- Requires valid TMDB API key
- Not all movies have provider data available
- Provider availability varies by country
- Provider logos load asynchronously
- Works offline with cached data (AsyncImage caching)

## Code Example Usage

The feature integrates seamlessly into the existing detail view:

```swift
MovieDetailView(movie: savedMovie)
    // Automatically loads and displays watch providers
```

No additional configuration needed - it just works!

## Resources

- [TMDB Watch Providers API Documentation](https://developers.themoviedb.org/3/movies/get-movie-watch-providers)
- [JustWatch](https://www.justwatch.com) - Comprehensive streaming availability
- Provider logos provided by TMDB
## Related Features

See `WATCH_PROVIDER_FILTERING_FEATURE.md` for details on:
- Filtering the Browse tab by streaming service
- "Free Only" filtering for Prime Video and other services
- Batch provider loading and caching


