# CSV Data Logging Feature

## Overview

The CSV logging feature allows you to capture all movie data fetched from TMDB into a CSV file stored locally on your device. This is useful for debugging, data analysis, or tracking what movies your app is discovering.

## Components

### 1. CSVLogger Service (`CSVLogger.swift`)

A singleton service that handles all CSV logging operations:

- **Main Actor**: All operations run on the main actor for thread safety
- **File Location**: `Documents/tmdb_movies_log.csv`
- **Toggle Control**: Uses `UserDefaults` with key `csv_logging_enabled`

#### Key Methods

```swift
// Check if logging is enabled
CSVLogger.shared.isLoggingEnabled

// Log a single movie
CSVLogger.shared.logMovie(movie, source: "Search")

// Log multiple movies
CSVLogger.shared.logMovies(movies, source: "Top Rated")

// Get file statistics
CSVLogger.shared.getFormattedFileSize()
CSVLogger.shared.getEntryCount()

// Export or clear the log
CSVLogger.shared.exportFile() // Returns URL
CSVLogger.shared.clearLog()
```

### 2. Debug Settings View (`DebugSettingsView.swift`)

A SwiftUI view for managing CSV logging:

**Features:**
- Toggle to enable/disable logging
- Display file size and entry count
- Export CSV file via share sheet
- Clear log file with confirmation
- Information about CSV format

**Usage:**

```swift
NavigationStack {
    DebugSettingsView()
}
```

### 3. TMDBService Integration

All movie fetch methods in `TMDBService` now log their results when CSV logging is enabled:

- `searchMovies()` - Logs with source "Search: {query}"
- `fetchTopRated()` - Logs with source "Top Rated (Page {page})"
- `fetchTrending()` - Logs with source "Trending/movie/week"
- `fetchPopular()` - Logs with source "Movie/popular"
- `fetchByGenre()` - Logs with source "Genre ID: {id}"
- `fetchByDecade()` - Logs with source "Decade: {decade}s"
- `fetchMoviesByActor()` - Logs with source "Actor Discovery (ID: {id})"
- `fetchSimilarMovies()` - Logs with source "Similar to Movie ID: {id}"
- And more...

## CSV File Format

The CSV file contains the following columns:

```
Timestamp, ID, Title, Year, Release Date, Vote Average, Overview, Poster Path, Source
```

**Example Row:**

```csv
2026-03-22T10:30:45Z,550,"Fight Club",1999,1999-10-15,8.433,"A ticking-time-bomb insomniac...","/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg","Search: fight club"
```

### Column Descriptions

- **Timestamp**: ISO 8601 formatted timestamp when the movie was logged
- **ID**: TMDB movie ID
- **Title**: Movie title (quoted to handle commas)
- **Year**: Extracted from release date (first 4 characters)
- **Release Date**: Full release date (YYYY-MM-DD)
- **Vote Average**: TMDB rating (0.0-10.0)
- **Overview**: Movie description (quoted, newlines removed)
- **Poster Path**: TMDB poster path
- **Source**: Description of how this movie was fetched

## How to Add to Your App

### Step 1: Add to Navigation

Add a link to the debug settings in your main settings or debug menu:

```swift
NavigationLink("Debug Settings") {
    DebugSettingsView()
}
```

Or create a dedicated debug screen with gesture:

```swift
.onLongPressGesture {
    showDebugSettings = true
}
.sheet(isPresented: $showDebugSettings) {
    NavigationStack {
        DebugSettingsView()
    }
}
```

### Step 2: Enable Logging

1. Navigate to Debug Settings
2. Toggle "Enable CSV Logging" on
3. Use the app normally - all movie fetches will be logged

### Step 3: Export Data

1. Open Debug Settings
2. Tap "Export CSV File"
3. Use the share sheet to save or send the file

## File Management

### Location

The CSV file is stored in the app's Documents directory:

```swift
FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("tmdb_movies_log.csv")
```

### Access via Files App

The CSV file is accessible through:
- Xcode → Devices and Simulators → Download Container
- Files app (if file sharing is enabled in Info.plist)

### Clearing Data

To reset the log:
1. Open Debug Settings
2. Tap "Clear Log File"
3. Confirm deletion

Or programmatically:

```swift
try? CSVLogger.shared.clearLog()
```

## Performance Considerations

### Minimal Impact

- Logging is disabled by default
- When disabled, no performance impact (early return)
- Logging is asynchronous (doesn't block network requests)
- File writes are append-only (efficient)

### File Size

The CSV file grows with usage:
- ~200-300 bytes per movie entry
- 1000 movies ≈ 200-300 KB
- 10,000 movies ≈ 2-3 MB

Monitor file size in Debug Settings and clear periodically.

## Use Cases

### 1. Debugging API Calls

Track exactly what data TMDB is returning:

```
// See what movies are returned for different searches
Search: "matrix" → 20 results
Search: "action" → 20 results
```

### 2. Data Analysis

Analyze patterns in your app usage:
- Most common searches
- Popular genres fetched
- Rating distributions
- Time-based usage patterns

### 3. Testing & QA

Verify that filters and discovery features work correctly:
- Check genre filters return correct movies
- Verify actor searches include all their films
- Validate decade filters

### 4. User Research

Understand how users explore movies:
- What do they search for?
- Which discovery methods are most popular?
- What time of day do they browse?

## Example Analysis Queries

Once you have CSV data, you can analyze it in spreadsheet apps:

### Most Logged Movies

```excel
=COUNTIF(B:B, "550") // Count how many times Fight Club (ID 550) was logged
```

### Average Rating of Logged Movies

```excel
=AVERAGE(F:F)
```

### Movies by Source

Use pivot tables to group by the "Source" column to see:
- How many movies from searches vs. recommendations
- Most popular genres
- Most queried actors

## Privacy Considerations

### Data Storage

- All data is stored locally
- No data is transmitted to servers
- CSV file remains on device until exported by user

### TMDB Data

The logged data comes from TMDB and includes:
- Movie titles and descriptions
- Release dates and ratings
- Poster paths (URLs, not images)

This data is public and available via TMDB API.

### User Searches

Search queries are logged in the "Source" field:
- `"Search: matrix"` reveals user searched for "matrix"
- Consider this when sharing CSV files

## Troubleshooting

### File Not Found

If the CSV file doesn't exist:
- Enable logging
- Fetch some movies (search, browse, etc.)
- File will be created automatically with headers

### No Data Being Logged

Check that:
1. CSV logging is enabled in Debug Settings
2. App has permission to write to Documents
3. Movies are actually being fetched (check network)

### File Too Large

If the file grows too large:
1. Export current data if needed
2. Clear the log file
3. Start fresh

### Cannot Open CSV

The CSV file uses standard formatting:
- UTF-8 encoding
- Comma-separated values
- Quoted strings for titles/overviews

Compatible with:
- Numbers (macOS/iOS)
- Excel (Microsoft)
- Google Sheets
- Any CSV viewer/editor

## Future Enhancements

Potential improvements:

1. **Automatic rotation**: Archive old logs when file reaches size limit
2. **Multiple formats**: JSON or SQLite export options
3. **Filtering**: Export only specific date ranges or sources
4. **Statistics**: Built-in analytics within the app
5. **iCloud sync**: Optional sync of logs across devices
6. **Compression**: Gzip large files before export

## Code Examples

### Manual Logging

If you want to log movies outside of TMDBService:

```swift
// Log a single movie
await CSVLogger.shared.logMovie(movie, source: "Custom Action")

// Log from search results
let results = try await tmdbService.searchMovies(query: "inception")
// Already logged by TMDBService, but you could log again with different source
```

### Check Before Expensive Operations

```swift
if CSVLogger.shared.isLoggingEnabled {
    // Maybe show warning about performance
    print("Note: CSV logging is enabled, file may grow large")
}
```

### Programmatic Toggle

```swift
// Enable logging
UserDefaults.standard.set(true, forKey: CSVLogger.loggingEnabledKey)

// Disable logging
UserDefaults.standard.set(false, forKey: CSVLogger.loggingEnabledKey)
```

## Testing

To test the CSV logging feature:

```swift
import Testing

@Suite("CSV Logger Tests")
struct CSVLoggerTests {
    
    @Test("Logging disabled by default")
    func loggingDisabledByDefault() async {
        #expect(CSVLogger.shared.isLoggingEnabled == false)
    }
    
    @Test("Enable and log movie")
    func enableAndLog() async throws {
        // Enable logging
        UserDefaults.standard.set(true, forKey: CSVLogger.loggingEnabledKey)
        
        // Create test movie
        let movie = TMDBMovie(
            id: 550,
            title: "Test Movie",
            releaseDate: "1999-10-15",
            overview: "Test overview",
            posterPath: "/test.jpg",
            voteAverage: 8.5
        )
        
        // Log it
        await CSVLogger.shared.logMovie(movie, source: "Test")
        
        // Verify
        let count = CSVLogger.shared.getEntryCount()
        #expect(count != nil)
        #expect(count! > 0)
        
        // Cleanup
        try CSVLogger.shared.clearLog()
        UserDefaults.standard.set(false, forKey: CSVLogger.loggingEnabledKey)
    }
}
```

## Summary

The CSV logging feature provides a powerful debugging and analysis tool with:

✅ Simple toggle control  
✅ Automatic logging of all TMDB fetches  
✅ Export and sharing capabilities  
✅ File statistics tracking  
✅ Minimal performance impact  
✅ Privacy-friendly (local only)  

Enable it when you need insights into your app's data fetching, and disable it for normal use.
