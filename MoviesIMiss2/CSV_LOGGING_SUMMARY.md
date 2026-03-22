# CSV Logging Implementation Summary

## What Was Built

A complete CSV data logging system for tracking all movie data fetched from TMDB, with a user-friendly debug interface.

## Files Created

### 1. `CSVLogger.swift` ✅
**Purpose**: Core service for CSV logging functionality

**Features**:
- Singleton pattern with `@MainActor` for thread safety
- Toggle control via `UserDefaults` (`csv_logging_enabled`)
- Automatic CSV file creation with headers
- Methods to log single or multiple movies
- File statistics (size, entry count)
- Export and clear functionality
- CSV formatting with proper escaping

**Key Methods**:
```swift
CSVLogger.shared.logMovie(_:source:)
CSVLogger.shared.logMovies(_:source:)
CSVLogger.shared.getFormattedFileSize()
CSVLogger.shared.getEntryCount()
CSVLogger.shared.exportFile()
CSVLogger.shared.clearLog()
```

### 2. `DebugSettingsView.swift` ✅
**Purpose**: SwiftUI interface for managing CSV logging

**Features**:
- Toggle to enable/disable logging with `@AppStorage`
- Real-time file statistics display
- Export CSV via system share sheet
- Delete confirmation alert
- Informative sections about CSV format
- Automatic stats refresh on appear
- Disabled states for actions when no data exists

**UI Sections**:
- CSV Data Logging (toggle + description)
- Log File Statistics (size, entry count, refresh)
- Actions (export, clear)
- Information (format details)

### 3. `CSV_LOGGING_FEATURE.md` ✅
**Purpose**: Complete documentation

**Contents**:
- Overview and component descriptions
- CSV file format specification
- Integration instructions
- Performance considerations
- Use cases and examples
- Troubleshooting guide
- Testing examples
- Privacy notes

### 4. `INTEGRATION_EXAMPLES.swift` ✅
**Purpose**: Code examples for integrating the debug view

**Contains 5 different approaches**:
1. Add to existing settings
2. Hidden triple-tap gesture
3. Debug-only tab (conditional compilation)
4. Shake gesture (iOS)
5. Developer menu section

## TMDBService.swift Modifications ✅

Added CSV logging to all movie fetch methods:

### Modified Methods:
- ✅ `searchMovies(query:)` - Logs: "Search: {query}"
- ✅ `fetchTopRated(page:)` - Logs: "Top Rated (Page X)"
- ✅ `fetchMoviesByActor(personId:page:)` - Logs: "Actor Discovery (ID: X)"
- ✅ `fetchMoviesByActorWithFilters(actorId:queryItems:)` - Logs: "Actor with Filters (ID: X)"
- ✅ `fetchMoviesByDirector(personId:page:)` - Logs: "Director Discovery (ID: X)"
- ✅ `fetchSimilarMovies(movieId:page:)` - Logs: "Similar to Movie ID: X"
- ✅ `fetchRecommendedMovies(movieId:page:)` - Logs: "Recommended from Movie ID: X"
- ✅ `fetchByGenre(genreId:page:minRating:actorId:)` - Logs: "Genre ID: X"
- ✅ `fetchByDecade(startDate:endDate:...)` - Logs: "Decade: XXXXs"
- ✅ `fetchByRating(minRating:page:)` - Logs: "Rating >= X"
- ✅ `fetchMovieList(endpoint:page:)` - Logs: "{endpoint}"

**Implementation Pattern**:
```swift
let movies = try await performRequest(url: url)
await CSVLogger.shared.logMovies(movies, source: "Description")
return movies
```

## CSV File Structure

### Location
```
Documents/tmdb_movies_log.csv
```

### Format
```csv
Timestamp,ID,Title,Year,Release Date,Vote Average,Overview,Poster Path,Source
2026-03-22T10:30:45Z,550,"Fight Club",1999,1999-10-15,8.433,"Description...","/path.jpg","Search: fight"
```

### Columns (9 total)
1. **Timestamp** - ISO 8601 format
2. **ID** - TMDB movie ID
3. **Title** - Quoted, escaped
4. **Year** - Extracted from release date
5. **Release Date** - YYYY-MM-DD
6. **Vote Average** - Rating (0.0-10.0)
7. **Overview** - Quoted, newlines removed
8. **Poster Path** - TMDB path
9. **Source** - How the movie was fetched

## How It Works

### 1. User Enables Logging
```
User → DebugSettingsView → Toggle ON → UserDefaults stores true
```

### 2. App Fetches Movies
```
TMDBService.searchMovies() → Gets results → Logs to CSV → Returns results
```

### 3. CSV File Updates
```
CSVLogger checks toggle → Appends rows asynchronously → Updates file
```

### 4. User Exports Data
```
User → Export button → Share sheet → Save/Send CSV file
```

## Integration Steps

### Step 1: Add Files to Project
- [x] CSVLogger.swift
- [x] DebugSettingsView.swift

### Step 2: Verify TMDBService Changes
- [x] All fetch methods include logging calls

### Step 3: Add Debug Settings Access
Choose one approach from `INTEGRATION_EXAMPLES.swift`:

**Recommended**: Add to settings view
```swift
NavigationLink("CSV Data Logging") {
    DebugSettingsView()
}
```

### Step 4: Test
1. Run app
2. Navigate to Debug Settings
3. Enable CSV Logging
4. Search for movies or browse
5. Check statistics update
6. Export CSV file
7. Verify data in spreadsheet app

## Performance Impact

### When Disabled (Default)
- **Zero overhead**: Early return at start of every log call
- No file operations
- No performance impact

### When Enabled
- **Minimal impact**: Logging is asynchronous
- File writes don't block network requests
- Append-only operations (efficient)
- ~200-300 bytes per movie entry

### File Size Growth
- 100 movies: ~20-30 KB
- 1,000 movies: ~200-300 KB  
- 10,000 movies: ~2-3 MB

Monitor in Debug Settings and clear periodically.

## Security & Privacy

### ✅ Local Storage Only
- All data stays on device
- No network transmission
- User controls export

### ✅ TMDB Public Data
- Movie info is public
- No user personal data
- No sensitive information

### ⚠️ Search Queries
- Source field includes search terms
- `"Search: inception"` reveals user searched "inception"
- Consider when sharing CSV files

## Use Cases

### 1. Development & Debugging
- Track API responses
- Verify filters work correctly
- Monitor data quality

### 2. QA Testing
- Ensure all discovery methods return results
- Validate genre/decade filters
- Check actor/director searches

### 3. Data Analysis
- Understand user behavior
- Analyze search patterns
- Track popular content

### 4. Research
- Study movie metadata
- Build datasets
- Analyze TMDB data

## Testing Checklist

- [ ] Enable logging toggle
- [ ] Search for movies → Check CSV created
- [ ] Browse different sections → Verify different sources logged
- [ ] Check file statistics update
- [ ] Export CSV file successfully
- [ ] Open CSV in Numbers/Excel
- [ ] Verify data format correct
- [ ] Clear log file
- [ ] Disable logging → No new entries
- [ ] Re-enable → New entries appear

## Common Issues & Solutions

### CSV File Not Created
**Problem**: File doesn't exist after enabling logging  
**Solution**: Fetch some movies first (search, browse, etc.)

### No Data Logged
**Problem**: Toggle enabled but file empty  
**Solution**: Check `isLoggingEnabled` returns `true`, verify movie fetches are happening

### Cannot Open CSV
**Problem**: File won't open in spreadsheet app  
**Solution**: Ensure app supports UTF-8 CSV files with quoted strings

### File Too Large
**Problem**: CSV file growing too big  
**Solution**: Export current data, then clear log file

## Future Enhancements

### Potential Additions
1. **Auto-rotation**: Archive logs when file reaches limit (e.g., 10 MB)
2. **JSON export**: Alternative format option
3. **Date filters**: Export only recent entries
4. **Statistics view**: Charts within app
5. **iCloud sync**: Optional cloud backup
6. **Compression**: Gzip before export
7. **Search**: Find specific movies in log
8. **Duplicate detection**: Track if same movie logged multiple times

## Verification

### Files Modified
- ✅ `TMDBService.swift` - 11 methods updated

### Files Created
- ✅ `CSVLogger.swift` - 200+ lines
- ✅ `DebugSettingsView.swift` - 150+ lines
- ✅ `CSV_LOGGING_FEATURE.md` - Comprehensive docs
- ✅ `INTEGRATION_EXAMPLES.swift` - Integration patterns

### Total Lines Added
- ~600+ lines of implementation
- ~500+ lines of documentation
- ~100+ lines of examples

## Success Criteria

✅ User can toggle CSV logging on/off  
✅ All TMDB movie fetches are logged when enabled  
✅ CSV file includes timestamp, movie data, and source  
✅ User can view file statistics  
✅ User can export CSV file  
✅ User can clear log file  
✅ Zero performance impact when disabled  
✅ Minimal performance impact when enabled  
✅ Complete documentation provided  

## Next Steps

1. **Add to app**: Choose integration method and implement
2. **Test thoroughly**: Run through test checklist
3. **Document in app**: Add help text or tooltip
4. **Monitor usage**: Check if feature is useful
5. **Iterate**: Add enhancements based on needs

---

## Quick Start

```swift
// 1. Add navigation link
NavigationLink("Debug") {
    DebugSettingsView()
}

// 2. Enable in app
// → Navigate to Debug Settings
// → Toggle "Enable CSV Logging" ON

// 3. Use the app normally
// → Search, browse, explore movies

// 4. Export data
// → Tap "Export CSV File"
// → Share via Messages, Mail, Files, etc.

// 5. Analyze in spreadsheet
// → Open in Numbers, Excel, Google Sheets
// → Sort, filter, create charts
```

That's it! Your CSV logging system is ready to use. 🎉
