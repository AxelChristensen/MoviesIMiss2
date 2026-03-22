# CSV Export for Large Collections (4000+ Movies)

## Overview

The CSV export feature has been enhanced to handle large movie collections (4000+ movies) with progress tracking, rate limiting, and two export modes.

## Export Modes

### 1. Fast Mode (Default OFF)
- **Speed**: Instant (even for 4000 movies)
- **Data**: Only locally stored information
- **Use Case**: Quick exports, backups, data sharing
- **Columns**:
  - Title, Year, TMDB ID, Status
  - Date Added, Last Watched, Next Rewatch
  - Has Seen Before
  - Overview, Vibes, Vibe Notes
  - Mood When Watched, Mood It Helps With
  - Poster Path

### 2. Complete Mode (Default ON)
- **Speed**: ~20 movies/second (~3-4 minutes for 4000 movies)
- **Data**: Includes live TMDB API data
- **Use Case**: Complete data export with current streaming info
- **Additional Columns**:
  - Streaming Providers (from TMDB)
  - Related Movies (5 similar titles from TMDB)

## Features

### Progress Tracking
When using Complete Mode with API calls, the UI shows:
- Current progress (X of Y movies)
- Progress bar
- Estimated time remaining

### Rate Limiting
To avoid hitting TMDB API limits:
- Processes ~20 movies per second
- Pauses 1 second after every 20 movies (40 API calls)
- Yields to keep UI responsive every 5 movies
- TMDB allows 50 requests/second; we make 2 per movie (providers + similar)

### Error Handling
- Graceful handling of API failures (missing data shown as empty)
- Try/catch on individual API calls won't stop entire export
- MainActor integration for thread safety

## Usage

### From Debug Settings
1. Navigate to Settings → Debug Settings
2. Choose export mode:
   - Toggle "Include Streaming & Related Movies" ON for complete export
   - Toggle OFF for fast export
3. Optional: Enter custom filename
4. Tap "Export All Movies to CSV"
5. Watch progress (if using complete mode)
6. Share exported file

### Programmatic Usage

```swift
// Complete export with progress
let url = try await CSVLogger.shared.exportAllMovies(
    from: modelContext,
    filename: "my-movies",
    includeAPIData: true
) { current, total in
    print("Progress: \(current)/\(total)")
}

// Fast export (no progress needed)
let url = try await CSVLogger.shared.exportAllMovies(
    from: modelContext,
    filename: "my-movies",
    includeAPIData: false,
    progressHandler: nil
)
```

## Performance Estimates

| Movies | Fast Mode | Complete Mode |
|--------|-----------|---------------|
| 100    | Instant   | ~5 seconds    |
| 500    | Instant   | ~25 seconds   |
| 1000   | Instant   | ~50 seconds   |
| 4000   | Instant   | ~3.5 minutes  |

*Complete mode times include TMDB API rate limiting*

## Technical Details

### Rate Limiting Strategy
```swift
// Process 20 movies (40 API calls)
// Pause for 1 second
// Repeat

// This stays under TMDB's 50 requests/second limit
// With headroom for other app API calls
```

### API Calls Per Movie
1. `fetchWatchProviders(movieId:)` - Gets streaming availability
2. `fetchSimilarMovies(movieId:page:)` - Gets 5 related titles

### Memory Management
- Processes movies sequentially to avoid memory buildup
- Uses `Task.yield()` to prevent blocking main thread
- String concatenation optimized for large datasets

## Best Practices

### For Collections Under 1000 Movies
- Either mode works well
- Complete mode adds ~1 minute

### For Collections 1000-4000 Movies
- Use Complete mode when you need current streaming data
- Use Fast mode for quick backups or testing
- Export during times when you can wait 3-5 minutes

### For Collections Over 4000 Movies
- Consider Fast mode for regular exports
- Use Complete mode selectively when needed
- Estimated time: ~5 minutes for 6000 movies

## Troubleshooting

### Export Hangs at 0%
- Check network connection
- Verify TMDB API is accessible
- Try Fast mode to test if it's API-related

### Export Stops Partway
- May indicate TMDB rate limiting
- Wait 10 seconds and try again
- Check TMDB API status

### Slow Export Speed
- Normal: ~20 movies/second in Complete mode
- Slower than this may indicate network issues
- Switch to Fast mode for instant export

## File Locations

Exported files are saved to:
```
Documents/movies_export_YYYY-MM-DD_HHMMSS.csv
```

Or with custom filename:
```
Documents/your-filename.csv
```

## Future Enhancements

Potential improvements:
- Background export for very large collections
- Resume capability for interrupted exports
- Batch processing with multiple concurrent API calls
- Export to other formats (JSON, SQLite, etc.)
- Selective export (filtered by status, vibes, etc.)
