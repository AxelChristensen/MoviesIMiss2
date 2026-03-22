# CSV Logging Quick Reference

## Enable Logging

```swift
// In Debug Settings UI
Toggle "Enable CSV Logging"

// Programmatically
UserDefaults.standard.set(true, forKey: CSVLogger.loggingEnabledKey)
```

## Log Movies

```swift
// Automatic (already integrated in TMDBService)
let movies = try await tmdbService.searchMovies(query: "matrix")
// ✅ Automatically logged with source "Search: matrix"

// Manual logging
await CSVLogger.shared.logMovie(movie, source: "Custom")
await CSVLogger.shared.logMovies(movies, source: "Batch Import")
```

## Check Status

```swift
// Is logging enabled?
if CSVLogger.shared.isLoggingEnabled {
    print("Logging is ON")
}

// Get file stats
let size = CSVLogger.shared.getFormattedFileSize() // "1.2 MB"
let count = CSVLogger.shared.getEntryCount() // 1523
```

## Export & Clear

```swift
// Export (returns URL for sharing)
if let url = CSVLogger.shared.exportFile() {
    // Share via UIActivityViewController
}

// Clear all data
try CSVLogger.shared.clearLog()
```

## File Location

```
Documents/tmdb_movies_log.csv
```

## CSV Format

```csv
Timestamp,ID,Title,Year,Release Date,Vote Average,Overview,Poster Path,Source
2026-03-22T10:30:45Z,550,"Fight Club",1999,1999-10-15,8.433,"Description","/path.jpg","Search: fight"
```

## Sources Logged

| Method | Source String |
|--------|---------------|
| `searchMovies()` | `"Search: {query}"` |
| `fetchTopRated()` | `"Top Rated (Page {page})"` |
| `fetchTrending()` | `"Trending/movie/week"` |
| `fetchPopular()` | `"Movie/popular"` |
| `fetchByGenre()` | `"Genre ID: {id}"` |
| `fetchByDecade()` | `"Decade: {decade}s"` |
| `fetchMoviesByActor()` | `"Actor Discovery (ID: {id})"` |
| `fetchSimilarMovies()` | `"Similar to Movie ID: {id}"` |

## Integration

```swift
// Add to settings
NavigationLink("CSV Logging") {
    DebugSettingsView()
}
```

## Testing

```swift
// 1. Enable logging
UserDefaults.standard.set(true, forKey: CSVLogger.loggingEnabledKey)

// 2. Fetch movies
let movies = try await tmdbService.searchMovies(query: "test")

// 3. Verify
#expect(CSVLogger.shared.getEntryCount() ?? 0 > 0)
```

## Performance

- **Disabled**: Zero overhead ✅
- **Enabled**: ~200-300 bytes per movie
- **Async**: Doesn't block network requests ✅

## Common Commands

```swift
// Check if file exists
FileManager.default.fileExists(atPath: CSVLogger.shared.getFileURL().path)

// Get file URL
let url = CSVLogger.shared.getFileURL()

// Enable/Disable
UserDefaults.standard.set(true, forKey: CSVLogger.loggingEnabledKey)
UserDefaults.standard.set(false, forKey: CSVLogger.loggingEnabledKey)
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| File not created | Fetch movies after enabling |
| No data logged | Check toggle is enabled |
| Can't open CSV | Use UTF-8 compatible app |
| File too large | Export then clear |

## Analysis Examples

### In Spreadsheet

```
// Count movies by source
=COUNTIF(I:I, "*Search*")

// Average rating
=AVERAGE(F:F)

// Movies from specific date
=FILTER(A:I, A:A >= DATE(2026,3,1))
```

### In Terminal

```bash
# Count entries
wc -l tmdb_movies_log.csv

# View sources
cut -d',' -f9 tmdb_movies_log.csv | sort | uniq -c

# Filter by rating
awk -F',' '$6 >= 8.0' tmdb_movies_log.csv
```

---

**Documentation**: See `CSV_LOGGING_FEATURE.md` for complete guide
