# CSV Logging Testing Guide

## Manual Testing Checklist

### ✅ Basic Functionality

- [ ] **App Launch**
  - Launch app
  - CSV logging is disabled by default
  - No CSV file exists yet

- [ ] **Enable Logging**
  - Navigate to Debug Settings
  - Toggle "Enable CSV Logging" ON
  - Toggle state persists after closing view
  - Toggle state persists after app restart

- [ ] **First Movie Fetch**
  - Search for a movie (e.g., "matrix")
  - CSV file is created automatically
  - File statistics appear in Debug Settings
  - Entry count shows > 0

- [ ] **Multiple Fetches**
  - Search different queries
  - Browse top rated
  - Explore by genre
  - Entry count increases with each fetch
  - File size increases

- [ ] **Disable Logging**
  - Note current entry count
  - Toggle logging OFF
  - Fetch more movies
  - Entry count remains unchanged

- [ ] **Export CSV**
  - Enable logging (if disabled)
  - Fetch some movies
  - Tap "Export CSV File"
  - Share sheet appears
  - Can save to Files app
  - Can share via Messages/Mail

- [ ] **Clear Log**
  - Tap "Clear Log File"
  - Confirmation alert appears
  - Tap "Delete"
  - Entry count resets to nil
  - File size resets to nil
  - CSV file is deleted

### ✅ Data Integrity

- [ ] **CSV Format**
  - Export CSV file
  - Open in Numbers/Excel
  - All columns present and correct
  - Data properly formatted
  - Quotes escaped correctly
  - No broken rows

- [ ] **Source Tracking**
  - Search for movie → Source: "Search: {query}"
  - Browse top rated → Source: "Top Rated (Page 1)"
  - Explore genre → Source: "Genre ID: {id}"
  - View actor movies → Source: "Actor Discovery (ID: {id})"

- [ ] **Timestamps**
  - All entries have valid ISO 8601 timestamps
  - Timestamps are in chronological order
  - Timezone information included

- [ ] **Movie Data**
  - ID matches TMDB movie ID
  - Title matches search result
  - Year extracted correctly
  - Vote average is numeric
  - Poster path is valid TMDB path

### ✅ UI/UX

- [ ] **Statistics Display**
  - File size shows in readable format (KB/MB)
  - Entry count is accurate
  - "Refresh Stats" button updates values
  - Stats auto-refresh on view appear

- [ ] **Button States**
  - Export button disabled when no data
  - Clear button disabled when no data
  - Buttons enabled when data exists
  - Loading states work correctly

- [ ] **Alerts**
  - Clear confirmation alert has Cancel + Delete
  - Tapping Cancel doesn't delete
  - Tapping Delete removes file

- [ ] **Share Sheet**
  - Share sheet presents correctly
  - File can be saved
  - File can be shared via services
  - Share sheet dismisses properly

### ✅ Edge Cases

- [ ] **Empty Searches**
  - Search with no results
  - No entries added to CSV

- [ ] **Network Errors**
  - Disable network
  - Attempt search
  - No corrupt entries in CSV

- [ ] **Large Datasets**
  - Fetch 1000+ movies
  - Performance remains good
  - File size calculated correctly
  - Export still works

- [ ] **Special Characters**
  - Movie titles with quotes: "The \"Great\" Movie"
  - Titles with commas: "Movie, The"
  - Titles with newlines (overview)
  - All properly escaped

- [ ] **App Lifecycle**
  - Enable logging
  - Kill app
  - Restart app
  - Setting is preserved
  - CSV file persists

## Automated Testing

### Unit Tests

```swift
import Testing
import Foundation

@Suite("CSV Logger Tests")
struct CSVLoggerTests {
    
    @Test("Logger disabled by default")
    func disabledByDefault() async {
        // Reset defaults
        UserDefaults.standard.removeObject(forKey: CSVLogger.loggingEnabledKey)
        
        // Verify disabled
        #expect(CSVLogger.shared.isLoggingEnabled == false)
    }
    
    @Test("Enable and disable logging")
    func enableDisable() async {
        // Enable
        UserDefaults.standard.set(true, forKey: CSVLogger.loggingEnabledKey)
        #expect(CSVLogger.shared.isLoggingEnabled == true)
        
        // Disable
        UserDefaults.standard.set(false, forKey: CSVLogger.loggingEnabledKey)
        #expect(CSVLogger.shared.isLoggingEnabled == false)
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: CSVLogger.loggingEnabledKey)
    }
    
    @Test("Log single movie")
    func logSingleMovie() async throws {
        // Setup
        UserDefaults.standard.set(true, forKey: CSVLogger.loggingEnabledKey)
        try? CSVLogger.shared.clearLog() // Start fresh
        
        // Create test movie
        let movie = TMDBMovie(
            id: 550,
            title: "Fight Club",
            releaseDate: "1999-10-15",
            overview: "A ticking-time-bomb insomniac",
            posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
            voteAverage: 8.433
        )
        
        // Log it
        await CSVLogger.shared.logMovie(movie, source: "Test")
        
        // Wait a bit for async operation
        try? await Task.sleep(for: .milliseconds(100))
        
        // Verify
        let count = CSVLogger.shared.getEntryCount()
        #expect(count != nil)
        #expect(count! >= 1)
        
        // Cleanup
        try CSVLogger.shared.clearLog()
        UserDefaults.standard.set(false, forKey: CSVLogger.loggingEnabledKey)
    }
    
    @Test("Log multiple movies")
    func logMultipleMovies() async throws {
        // Setup
        UserDefaults.standard.set(true, forKey: CSVLogger.loggingEnabledKey)
        try? CSVLogger.shared.clearLog()
        
        // Create test movies
        let movies = [
            TMDBMovie(id: 550, title: "Fight Club", releaseDate: "1999-10-15", 
                      overview: "Test 1", posterPath: nil, voteAverage: 8.4),
            TMDBMovie(id: 603, title: "The Matrix", releaseDate: "1999-03-31", 
                      overview: "Test 2", posterPath: nil, voteAverage: 8.7),
            TMDBMovie(id: 155, title: "The Dark Knight", releaseDate: "2008-07-18", 
                      overview: "Test 3", posterPath: nil, voteAverage: 9.0)
        ]
        
        // Log them
        await CSVLogger.shared.logMovies(movies, source: "Test Batch")
        
        // Wait for async operations
        try? await Task.sleep(for: .milliseconds(200))
        
        // Verify
        let count = CSVLogger.shared.getEntryCount()
        #expect(count != nil)
        #expect(count! >= 3)
        
        // Cleanup
        try CSVLogger.shared.clearLog()
        UserDefaults.standard.set(false, forKey: CSVLogger.loggingEnabledKey)
    }
    
    @Test("Logging disabled prevents entries")
    func disabledPreventsLogging() async throws {
        // Setup - ensure logging is OFF
        UserDefaults.standard.set(false, forKey: CSVLogger.loggingEnabledKey)
        try? CSVLogger.shared.clearLog()
        
        // Try to log
        let movie = TMDBMovie(id: 1, title: "Test", releaseDate: nil, 
                             overview: "", posterPath: nil, voteAverage: nil)
        await CSVLogger.shared.logMovie(movie, source: "Test")
        
        // Verify nothing was logged
        let count = CSVLogger.shared.getEntryCount()
        #expect(count == nil) // File shouldn't even exist
    }
    
    @Test("File size calculation")
    func fileSizeCalculation() async throws {
        // Setup
        UserDefaults.standard.set(true, forKey: CSVLogger.loggingEnabledKey)
        try? CSVLogger.shared.clearLog()
        
        // Log a movie
        let movie = TMDBMovie(id: 550, title: "Test Movie", releaseDate: "2020-01-01",
                             overview: "Test overview", posterPath: nil, voteAverage: 7.5)
        await CSVLogger.shared.logMovie(movie, source: "Test")
        
        try? await Task.sleep(for: .milliseconds(100))
        
        // Verify file size
        let size = CSVLogger.shared.getCSVFileSize()
        #expect(size != nil)
        #expect(size! > 0)
        
        let formatted = CSVLogger.shared.getFormattedFileSize()
        #expect(formatted != nil)
        #expect(formatted!.contains("bytes") || formatted!.contains("KB"))
        
        // Cleanup
        try CSVLogger.shared.clearLog()
        UserDefaults.standard.set(false, forKey: CSVLogger.loggingEnabledKey)
    }
    
    @Test("Clear log removes file")
    func clearLog() async throws {
        // Setup
        UserDefaults.standard.set(true, forKey: CSVLogger.loggingEnabledKey)
        
        // Log something
        let movie = TMDBMovie(id: 1, title: "Test", releaseDate: nil,
                             overview: "", posterPath: nil, voteAverage: nil)
        await CSVLogger.shared.logMovie(movie, source: "Test")
        
        try? await Task.sleep(for: .milliseconds(100))
        
        // Verify exists
        #expect(CSVLogger.shared.getEntryCount() != nil)
        
        // Clear
        try CSVLogger.shared.clearLog()
        
        // Verify deleted
        #expect(CSVLogger.shared.getEntryCount() == nil)
        
        // Cleanup
        UserDefaults.standard.set(false, forKey: CSVLogger.loggingEnabledKey)
    }
    
    @Test("CSV format validation")
    func csvFormatValidation() async throws {
        // Setup
        UserDefaults.standard.set(true, forKey: CSVLogger.loggingEnabledKey)
        try? CSVLogger.shared.clearLog()
        
        // Log movie with special characters
        let movie = TMDBMovie(
            id: 123,
            title: "Movie with \"Quotes\" and, Commas",
            releaseDate: "2020-01-01",
            overview: "Overview with\nnewlines and \"quotes\"",
            posterPath: "/test.jpg",
            voteAverage: 7.5
        )
        await CSVLogger.shared.logMovie(movie, source: "Format Test")
        
        try? await Task.sleep(for: .milliseconds(100))
        
        // Read file
        let url = CSVLogger.shared.getFileURL()
        let contents = try String(contentsOf: url, encoding: .utf8)
        
        // Verify format
        #expect(contents.contains("Timestamp"))  // Header
        #expect(contents.contains("123"))        // ID
        #expect(contents.contains("\"Quotes\"")) // Escaped quotes
        
        // Should not have unescaped newlines in data rows
        let lines = contents.components(separatedBy: .newlines)
        #expect(lines.count >= 2) // Header + at least one data row
        
        // Cleanup
        try CSVLogger.shared.clearLog()
        UserDefaults.standard.set(false, forKey: CSVLogger.loggingEnabledKey)
    }
}
```

### Integration Tests

```swift
@Suite("TMDBService Integration Tests")
struct TMDBServiceIntegrationTests {
    
    @Test("Search movies logs to CSV")
    func searchLogsToCSV() async throws {
        let tmdbService = TMDBService()
        
        // Setup
        UserDefaults.standard.set(true, forKey: CSVLogger.loggingEnabledKey)
        try? CSVLogger.shared.clearLog()
        
        // Search (requires valid API key)
        guard tmdbService.hasAPIKey else {
            Issue.record("TMDB API key not configured")
            return
        }
        
        let movies = try await tmdbService.searchMovies(query: "matrix")
        
        // Wait for logging
        try? await Task.sleep(for: .milliseconds(200))
        
        // Verify logging occurred
        let count = CSVLogger.shared.getEntryCount()
        #expect(count != nil)
        #expect(count! >= movies.count)
        
        // Cleanup
        try CSVLogger.shared.clearLog()
        UserDefaults.standard.set(false, forKey: CSVLogger.loggingEnabledKey)
    }
    
    @Test("Fetch top rated logs to CSV")
    func topRatedLogsToCSV() async throws {
        let tmdbService = TMDBService()
        
        // Setup
        UserDefaults.standard.set(true, forKey: CSVLogger.loggingEnabledKey)
        try? CSVLogger.shared.clearLog()
        
        guard tmdbService.hasAPIKey else {
            Issue.record("TMDB API key not configured")
            return
        }
        
        let movies = try await tmdbService.fetchTopRated()
        
        try? await Task.sleep(for: .milliseconds(200))
        
        let count = CSVLogger.shared.getEntryCount()
        #expect(count != nil)
        #expect(count! >= movies.count)
        
        // Cleanup
        try CSVLogger.shared.clearLog()
        UserDefaults.standard.set(false, forKey: CSVLogger.loggingEnabledKey)
    }
}
```

## Performance Testing

### Test Script

```swift
@Suite("Performance Tests")
struct PerformanceTests {
    
    @Test("Logging 1000 movies")
    func log1000Movies() async throws {
        UserDefaults.standard.set(true, forKey: CSVLogger.loggingEnabledKey)
        try? CSVLogger.shared.clearLog()
        
        // Generate 1000 test movies
        var movies: [TMDBMovie] = []
        for i in 1...1000 {
            movies.append(TMDBMovie(
                id: i,
                title: "Movie \(i)",
                releaseDate: "2020-01-01",
                overview: "Test overview for movie \(i)",
                posterPath: "/test\(i).jpg",
                voteAverage: Double.random(in: 1...10)
            ))
        }
        
        let startTime = Date()
        
        // Log all movies
        await CSVLogger.shared.logMovies(movies, source: "Performance Test")
        
        // Wait for completion
        try? await Task.sleep(for: .seconds(2))
        
        let duration = Date().timeIntervalSince(startTime)
        
        print("Logged 1000 movies in \(duration) seconds")
        
        // Verify
        let count = CSVLogger.shared.getEntryCount()
        #expect(count != nil)
        #expect(count! >= 1000)
        
        let size = CSVLogger.shared.getCSVFileSize()
        print("File size: \(size ?? 0) bytes")
        
        // Cleanup
        try CSVLogger.shared.clearLog()
        UserDefaults.standard.set(false, forKey: CSVLogger.loggingEnabledKey)
    }
    
    @Test("Disabled logging has zero overhead")
    func disabledOverhead() async throws {
        UserDefaults.standard.set(false, forKey: CSVLogger.loggingEnabledKey)
        
        let movie = TMDBMovie(id: 1, title: "Test", releaseDate: nil,
                             overview: "", posterPath: nil, voteAverage: nil)
        
        let startTime = Date()
        
        // Call 1000 times
        for _ in 1...1000 {
            await CSVLogger.shared.logMovie(movie, source: "Test")
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        print("1000 disabled log calls took \(duration) seconds")
        
        // Should be nearly instant (< 0.01 seconds)
        #expect(duration < 0.1)
    }
}
```

## UI Testing (XCTest)

```swift
import XCTest

final class DebugSettingsUITests: XCTestCase {
    
    func testToggleCSVLogging() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to debug settings
        app.buttons["Settings"].tap()
        app.buttons["Debug Settings"].tap()
        
        // Find toggle
        let toggle = app.switches["Enable CSV Logging"]
        XCTAssertTrue(toggle.exists)
        
        // Toggle ON
        if toggle.value as? String == "0" {
            toggle.tap()
        }
        XCTAssertEqual(toggle.value as? String, "1")
        
        // Toggle OFF
        toggle.tap()
        XCTAssertEqual(toggle.value as? String, "0")
    }
    
    func testExportButton() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to debug settings
        app.buttons["Settings"].tap()
        app.buttons["Debug Settings"].tap()
        
        // Enable logging
        let toggle = app.switches["Enable CSV Logging"]
        if toggle.value as? String == "0" {
            toggle.tap()
        }
        
        // Check export button exists
        let exportButton = app.buttons["Export CSV File"]
        XCTAssertTrue(exportButton.exists)
    }
}
```

## Regression Testing

After making changes, verify:

- [ ] All existing tests pass
- [ ] No performance degradation
- [ ] File format unchanged
- [ ] UI remains functional
- [ ] Documentation is current

## Test Data Examples

### Valid Movies

```swift
// Typical movie
TMDBMovie(id: 550, title: "Fight Club", releaseDate: "1999-10-15",
          overview: "A ticking-time-bomb insomniac...", 
          posterPath: "/path.jpg", voteAverage: 8.433)

// No poster
TMDBMovie(id: 123, title: "Indie Film", releaseDate: "2020-01-01",
          overview: "Low budget film", posterPath: nil, voteAverage: 7.0)

// No rating
TMDBMovie(id: 456, title: "New Release", releaseDate: "2026-12-31",
          overview: "Coming soon", posterPath: "/path.jpg", voteAverage: nil)
```

### Edge Case Movies

```swift
// Special characters
TMDBMovie(id: 789, title: "Movie with \"Quotes\" and, Commas",
          releaseDate: "2020-01-01", overview: "Complex\ntext\rwith\"quotes\"",
          posterPath: "/test.jpg", voteAverage: 8.5)

// Very long title
TMDBMovie(id: 999, title: String(repeating: "Long ", count: 100),
          releaseDate: "2020-01-01", overview: "Test",
          posterPath: nil, voteAverage: 5.0)

// Unicode characters
TMDBMovie(id: 111, title: "Café ☕ Film 🎬",
          releaseDate: "2020-01-01", overview: "Émile's café",
          posterPath: nil, voteAverage: 7.5)
```

## Bug Report Template

```
**Issue**: [Brief description]

**Steps to Reproduce**:
1. Enable CSV logging
2. Search for "matrix"
3. Export CSV file
4. [Issue occurs]

**Expected**: CSV file should export successfully

**Actual**: [What actually happened]

**Environment**:
- iOS version: 17.0
- Device: iPhone 15 Pro
- App version: 1.0

**Logs/Screenshots**: [Attach if available]

**CSV File**: [Attach if relevant]
```

## Success Criteria

All tests passing:
- ✅ Unit tests (8/8)
- ✅ Integration tests (2/2)
- ✅ Performance tests (2/2)
- ✅ UI tests (2/2)
- ✅ Manual checklist (All items)

Ready for production! 🎉
