# CSV Logging System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          USER INTERFACE LAYER                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │              DebugSettingsView.swift                       │    │
│  ├────────────────────────────────────────────────────────────┤    │
│  │  @AppStorage(csv_logging_enabled)                          │    │
│  │                                                             │    │
│  │  ┌──────────────────────────────────────────────────┐     │    │
│  │  │  Toggle: "Enable CSV Logging"                     │     │    │
│  │  └──────────────────────────────────────────────────┘     │    │
│  │                                                             │    │
│  │  ┌──────────────────────────────────────────────────┐     │    │
│  │  │  Statistics:                                      │     │    │
│  │  │  • File Size: 1.2 MB                             │     │    │
│  │  │  • Entries: 1,523 movies                         │     │    │
│  │  └──────────────────────────────────────────────────┘     │    │
│  │                                                             │    │
│  │  ┌──────────────────────────────────────────────────┐     │    │
│  │  │  [Export CSV File]  [Clear Log File]            │     │    │
│  │  └──────────────────────────────────────────────────┘     │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              │ User toggles ON                       │
│                              ▼                                       │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                          STORAGE LAYER                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │              UserDefaults                                   │    │
│  ├────────────────────────────────────────────────────────────┤    │
│  │  Key: "csv_logging_enabled"                                │    │
│  │  Value: true / false                                        │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              │ Reads setting
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          SERVICE LAYER                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │              CSVLogger.swift (@MainActor)                   │    │
│  ├────────────────────────────────────────────────────────────┤    │
│  │                                                             │    │
│  │  var isLoggingEnabled: Bool {                              │    │
│  │    UserDefaults.standard.bool(forKey: loggingEnabledKey)   │    │
│  │  }                                                          │    │
│  │                                                             │    │
│  │  func logMovie(_ movie: TMDBMovie, source: String) {       │    │
│  │    guard isLoggingEnabled else { return } // ⚡ Fast       │    │
│  │    Task {                                                   │    │
│  │      // Append to CSV asynchronously                       │    │
│  │    }                                                        │    │
│  │  }                                                          │    │
│  │                                                             │    │
│  │  func logMovies(_ movies: [TMDBMovie], source: String)     │    │
│  │  func getFormattedFileSize() -> String?                    │    │
│  │  func getEntryCount() -> Int?                              │    │
│  │  func exportFile() -> URL?                                 │    │
│  │  func clearLog()                                           │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              │ Writes CSV data                       │
│                              ▼                                       │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                          FILE SYSTEM                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  📁 Documents/                                                       │
│     └── 📄 tmdb_movies_log.csv                                      │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Timestamp,ID,Title,Year,Release Date,Vote Avg,Overview... │    │
│  │  2026-03-22T10:30:45Z,550,"Fight Club",1999,1999-10-15...  │    │
│  │  2026-03-22T10:31:12Z,603,"The Matrix",1999,1999-03-31...  │    │
│  │  2026-03-22T10:32:03Z,155,"The Dark Knight",2008,...       │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
                              ▲
                              │ Logs movies
                              │
┌─────────────────────────────────────────────────────────────────────┐
│                          API LAYER                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │              TMDBService.swift                              │    │
│  ├────────────────────────────────────────────────────────────┤    │
│  │                                                             │    │
│  │  func searchMovies(query: String) async throws {           │    │
│  │    let movies = // fetch from TMDB                         │    │
│  │    await CSVLogger.shared.logMovies(movies, source: query) │◄───┤
│  │    return movies                                            │    │
│  │  }                                                          │    │
│  │                                                             │    │
│  │  func fetchTopRated() async throws {                       │    │
│  │    let movies = // fetch from TMDB                         │    │
│  │    await CSVLogger.shared.logMovies(movies, ...)          │◄───┤
│  │    return movies                                            │    │
│  │  }                                                          │    │
│  │                                                             │    │
│  │  // 11+ other methods with logging...                      │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              ▲                                       │
│                              │ User action                           │
│                              │                                       │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                          APP LAYER                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  User searches "fight club" → TMDBService.searchMovies()            │
│  User browses top rated    → TMDBService.fetchTopRated()            │
│  User explores by actor    → TMDBService.fetchMoviesByActor()       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════
                         DATA FLOW DIAGRAM
═══════════════════════════════════════════════════════════════════════

User Action
    │
    ├─► Enable Logging
    │       │
    │       └─► UserDefaults.set(true) ───┐
    │                                      │
    └─► Search Movies                     │
            │                              │
            └─► TMDBService               │
                    │                      │
                    ├─► Fetch from TMDB   │
                    │       └─► [TMDBMovie] returned
                    │                      │
                    └─► CSVLogger         │
                            │              │
                            ├─► Check enabled? ◄┘
                            │       │
                            │       └─► if true:
                            │             │
                            └─────────────┴─► Append to CSV
                                                    │
                                                    └─► File updated


═══════════════════════════════════════════════════════════════════════
                         COMPONENT RELATIONSHIPS
═══════════════════════════════════════════════════════════════════════

┌────────────────────┐
│  DebugSettingsView │ ──── reads/writes ──→ ┌──────────────┐
└────────────────────┘                        │ UserDefaults │
         │                                    └──────────────┘
         │ calls                                     │
         ▼                                           │ reads
┌────────────────────┐                              │
│    CSVLogger       │ ◄──────────────────────────── ┘
└────────────────────┘
         │
         │ writes to
         ▼
┌────────────────────┐
│  CSV File          │
└────────────────────┘
         ▲
         │ appends data
         │
┌────────────────────┐
│   TMDBService      │ ──── calls ────→ CSVLogger
└────────────────────┘


═══════════════════════════════════════════════════════════════════════
                         PERFORMANCE FLOW
═══════════════════════════════════════════════════════════════════════

Logging DISABLED (default):
═══════════════════════════

TMDBService.searchMovies()
    │
    ├─► Fetch from TMDB (network request)
    │
    └─► CSVLogger.logMovies()
            │
            └─► Check isLoggingEnabled → false
                    │
                    └─► return immediately ⚡ (no overhead)


Logging ENABLED:
═══════════════

TMDBService.searchMovies()
    │
    ├─► Fetch from TMDB (network request)
    │       └─► Returns [TMDBMovie]
    │
    └─► CSVLogger.logMovies()
            │
            ├─► Check isLoggingEnabled → true
            │
            └─► Task { // Asynchronous
                    │
                    ├─► Format CSV rows
                    │
                    ├─► Append to file (background)
                    │
                    └─► Done (doesn't block caller)
                }
    │
    └─► Return movies to caller immediately ⚡


═══════════════════════════════════════════════════════════════════════
                         INTEGRATION POINTS
═══════════════════════════════════════════════════════════════════════

┌──────────────────────────────────────────────────────────────────────┐
│                          Your App                                     │
│                                                                       │
│  ┌─────────────────┐                                                │
│  │  Settings Tab   │ ────┐                                          │
│  └─────────────────┘     │                                          │
│                           │                                          │
│  ┌─────────────────┐     │    ┌────────────────────────────┐       │
│  │  Debug Menu     │ ────┼───→│   DebugSettingsView        │       │
│  └─────────────────┘     │    └────────────────────────────┘       │
│                           │                                          │
│  ┌─────────────────┐     │                                          │
│  │  Triple Tap     │ ────┘                                          │
│  └─────────────────┘                                                │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════
                         FILE STRUCTURE
═══════════════════════════════════════════════════════════════════════

MoviesIMiss2/
├── Services/
│   ├── TMDBService.swift         ✅ Modified (11 methods)
│   └── CSVLogger.swift            ✅ New
│
├── Views/
│   └── DebugSettingsView.swift   ✅ New
│
├── Documentation/
│   ├── CSV_LOGGING_FEATURE.md          ✅ New (Complete guide)
│   ├── CSV_LOGGING_SUMMARY.md          ✅ New (Implementation)
│   ├── CSV_LOGGING_QUICK_REFERENCE.md  ✅ New (Cheat sheet)
│   ├── CSV_LOGGING_ARCHITECTURE.md     ✅ New (This file)
│   └── INTEGRATION_EXAMPLES.swift       ✅ New (Code examples)


═══════════════════════════════════════════════════════════════════════
```
