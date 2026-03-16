# Related Movies Discovery Feature

## Overview
The Related Movies Discovery feature allows users to discover similar and recommended movies based on any movie in their collection. This helps users find new content that matches their interests and expand their watchlist organically.

## Files Created

### 1. RelatedMoviesView.swift
Main UI for the related movies discovery feature:
- **RelatedMoviesView**: Main view with segmented control for Similar/Recommended
- **RelatedMovieCard**: Card-based display for each related movie
- **RelatedMoviesTab**: Enum for tab selection (Similar vs Recommended)

## Files Modified

### 1. TMDBService.swift
Added two new methods for fetching related movies:
- `fetchSimilarMovies(movieId:page:)`: Get movies similar to a specific movie (based on genres, keywords, etc.)
- `fetchRecommendedMovies(movieId:page:)`: Get TMDB's algorithmic recommendations based on a movie

### 2. MovieDetailView.swift
Added:
- `@State private var showingRelatedMovies = false`: State for showing the sheet
- "Discover Related Movies" button between mood info and delete button
- `.sheet(isPresented: $showingRelatedMovies)` modifier to present RelatedMoviesView

## Features

### Discover Similar Movies
Movies that share similar characteristics with the selected movie:
- Same or similar genres
- Similar themes and keywords
- Comparable production companies or time periods
- Similar tone and style

### Discover Recommended Movies
TMDB's algorithmic recommendations based on:
- User viewing patterns on TMDB
- Movies frequently watched together
- Critical acclaim and popularity metrics
- Advanced machine learning recommendations

### Quick Add to Collection
- Tap any related movie card to open the add sheet
- All standard movie adding features available (status, mood tracking, etc.)
- Seamlessly integrates with existing collection

## User Flow

```
Movie Detail View → "Discover Related Movies" button → Related Movies View
                                                         ├─ Similar Tab
                                                         └─ Recommended Tab
                                                              └─ Tap movie → Add to Collection
```

## API Usage

The feature uses these TMDB API endpoints:
- `/movie/{movieId}/similar` - Get similar movies
- `/movie/{movieId}/recommendations` - Get recommended movies

Both endpoints support pagination (defaulting to page 1).

## Design Decisions

### 1. **Segmented Control Tabs**
Uses a segmented picker to switch between Similar and Recommended movies, allowing users to explore both discovery methods without leaving the view.

### 2. **Parallel Loading**
Fetches both similar and recommended movies simultaneously using Swift Concurrency (`async let`), improving perceived performance.

### 3. **Card-Based Layout**
- Shows poster, title, year, rating, and overview snippet
- Plus icon indicates movies can be added to collection
- Consistent with other movie browsing views in the app

### 4. **Modal Presentation**
Opens as a sheet from Movie Detail View, maintaining context while exploring related content.

### 5. **Empty State Handling**
Gracefully handles cases where no related movies are available with appropriate messaging.

## Technical Implementation

### Swift Concurrency
```swift
async let similar = tmdbService.fetchSimilarMovies(movieId: movie.tmdbId)
async let recommended = tmdbService.fetchRecommendedMovies(movieId: movie.tmdbId)

let (similarResults, recommendedResults) = try await (similar, recommended)
```

### State Management
- Uses `@State` for tab selection and loading states
- Leverages `@Environment(\.modelContext)` for adding movies
- Passes movie via initializer parameter

## UI Components

### Button in MovieDetailView
- Label: "Discover Related Movies"
- Icon: `film.stack.fill`
- Style: Blue tinted background with rounded corners
- Placement: Above the delete button

### Segmented Picker
- **Similar**: `film.stack` icon
- **Recommended**: `sparkles` icon

### Movie Cards
- 80x120 poster thumbnail
- Movie title (2 line limit)
- Release year
- Star rating (if available)
- Overview snippet (3 line limit)
- Plus icon for adding

## Error Handling

Handles common errors:
- Missing API key
- Network failures
- Empty results
- API errors
- Invalid movie IDs

All errors display user-friendly messages using `ContentUnavailableView`.

## Future Enhancements

Potential improvements:
- Show which movies are already in your collection
- Filter out movies you've already added
- Sort options (by rating, year, popularity)
- Pagination for large result sets
- Save related movies as a "discovery queue"
- Show relationship reason ("Similar because of genre X")
- Cross-reference with actor filmography

## Integration Notes

- Seamlessly works with existing `AddMovieSheet`
- Uses same `TMDBMovie` model as other discovery features
- Consistent error handling and loading states
- Follows app's design patterns and conventions
- Works with existing SwiftData `SavedMovie` model

## Accessibility

- Proper labels for all interactive elements
- System icons for visual clarity
- Readable text with appropriate hierarchy
- Error states with clear messaging
- Supports Dynamic Type

## Performance Considerations

1. **Parallel API Calls**: Fetches both similar and recommended movies simultaneously
2. **Lazy Loading**: Uses `LazyVStack` for efficient scrolling
3. **Image Caching**: Relies on URLSession's built-in caching for images
4. **Async/Await**: Modern concurrency prevents blocking the main thread

## Testing Recommendations

Test with:
- Popular movies (lots of results)
- Obscure movies (few/no results)
- Very new movies (limited data)
- Classic movies (extensive similar/recommended lists)
- Different genres to verify variety
- Network error conditions
- Missing API key scenarios
