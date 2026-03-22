# CSV Logging - Visual Setup Guide

```
╔═══════════════════════════════════════════════════════════════╗
║              CSV LOGGING IS NOW ENABLED!                      ║
╚═══════════════════════════════════════════════════════════════╝


STEP 1: ADD FILES TO XCODE
═══════════════════════════════════════════════════════════════

In Xcode:
┌─────────────────────────────────────────────────────────────┐
│  📁 MoviesIMiss2                                            │
│    ├─ MoviesIMiss2App.swift                                 │
│    ├─ ContentView.swift                                     │
│    ├─ TMDBService.swift        ← Already updated!           │
│    ├─ ...                                                    │
│    │                                                         │
│    👉 RIGHT CLICK HERE → "Add Files to..."                 │
│                                                              │
│    Then select:                                              │
│    ✅ CSVLogger.swift                                       │
│    ✅ DebugSettingsView.swift                               │
└─────────────────────────────────────────────────────────────┘


STEP 2: BUILD YOUR PROJECT
═══════════════════════════════════════════════════════════════

Press ⌘B (or Product → Build)

Expected result:
┌─────────────────────────────────────────────────────────────┐
│  ✅ Build Succeeded                                         │
│                                                              │
│  CSVLogger.swift         - Compiled                          │
│  DebugSettingsView.swift - Compiled                          │
│  TMDBService.swift       - Compiled (with CSV logging!)      │
└─────────────────────────────────────────────────────────────┘


STEP 3: ADD DEBUG SETTINGS TO YOUR UI
═══════════════════════════════════════════════════════════════

Option A: Add to ContentView.swift
┌─────────────────────────────────────────────────────────────┐
│  struct ContentView: View {                                 │
│      var body: some View {                                   │
│          TabView {                                           │
│              // Your existing tabs...                        │
│                                                              │
│              #if DEBUG                                       │
│              NavigationStack {                               │
│                  DebugSettingsView()  ← Add this!           │
│              }                                               │
│              .tabItem {                                      │
│                  Label("Debug", systemImage: "ladybug")      │
│              }                                               │
│              #endif                                          │
│          }                                                   │
│      }                                                       │
│  }                                                           │
└─────────────────────────────────────────────────────────────┘


STEP 4: USE CSV LOGGING
═══════════════════════════════════════════════════════════════

Run your app (⌘R):

┌─────────────────────────────────────────────────────────────┐
│                                                              │
│   Movies    Discover    Again!    🐞 Debug                  │
│                                     ↑                        │
│                                     New tab!                 │
└─────────────────────────────────────────────────────────────┘

Tap Debug tab:

┌─────────────────────────────────────────────────────────────┐
│  ← Debug Settings                                           │
│  ════════════════════════════════════════════════════════   │
│                                                              │
│  CSV DATA LOGGING                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Enable CSV Logging               [    OFF    ]      │  │
│  │                                          ↑             │  │
│  │  When enabled, all movie data...    Tap here!         │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘

Toggle ON:

┌─────────────────────────────────────────────────────────────┐
│  ← Debug Settings                                           │
│  ════════════════════════════════════════════════════════   │
│                                                              │
│  CSV DATA LOGGING                                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Enable CSV Logging               [=====ON=====]     │  │
│  │  When enabled, all movie data...                     │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  LOG FILE STATISTICS                                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  File Size: (none yet)                               │  │
│  │  Total Entries: 0                                     │  │
│  │  [ Refresh Stats ]                                    │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ACTIONS                                                     │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  [ Export CSV File ]    (disabled - no data yet)     │  │
│  │  [ Clear Log File ]     (disabled - no data yet)     │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘


STEP 5: LOG SOME DATA
═══════════════════════════════════════════════════════════════

Go to Movies tab and search:

┌─────────────────────────────────────────────────────────────┐
│  🔍  fight club                                             │
│  ════════════════════════════════════════════════════════   │
│                                                              │
│  📽️  Fight Club (1999)                                      │
│  📽️  Fight Club 2 (2000)                                    │
│  📽️  Fighting (2009)                                        │
│  ...                                                         │
└─────────────────────────────────────────────────────────────┘

Behind the scenes:
┌─────────────────────────────────────────────────────────────┐
│  📊 CSV logging enabled                                     │
│  📝 Logged movie to CSV: Fight Club (1999) from Search...   │
│  📝 Logged movie to CSV: Fight Club 2 (2000) from Search... │
│  📝 Logged movie to CSV: Fighting (2009) from Search...     │
└─────────────────────────────────────────────────────────────┘


STEP 6: VIEW STATISTICS
═══════════════════════════════════════════════════════════════

Go back to Debug Settings:

┌─────────────────────────────────────────────────────────────┐
│  LOG FILE STATISTICS                                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  File Size: 1.2 KB               ← Data logged!      │  │
│  │  Total Entries: 20                                    │  │
│  │  [ Refresh Stats ]                                    │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ACTIONS                                                     │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  [ Export CSV File ]             ← Now enabled!       │  │
│  │  [ Clear Log File ]                                   │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘


STEP 7: EXPORT CSV FILE
═══════════════════════════════════════════════════════════════

Tap "Export CSV File":

┌─────────────────────────────────────────────────────────────┐
│  📤 Share                                                    │
│  ════════════════════════════════════════════════════════   │
│                                                              │
│  tmdb_movies_log.csv                                         │
│                                                              │
│  📧  Mail                                                    │
│  💬  Messages                                                │
│  📁  Save to Files                                           │
│  📋  Copy                                                    │
│  📊  Open in Numbers                                         │
│  ...                                                         │
└─────────────────────────────────────────────────────────────┘


STEP 8: VIEW IN SPREADSHEET
═══════════════════════════════════════════════════════════════

Open in Numbers or Excel:

┌───────────────────────────────────────────────────────────────────────────┐
│ Timestamp            │ ID  │ Title       │ Year │ ... │ Source            │
├───────────────────────────────────────────────────────────────────────────┤
│ 2026-03-22T10:30:45Z │ 550 │ Fight Club  │ 1999 │ ... │ Search: fight...  │
│ 2026-03-22T10:30:46Z │ 123 │ Fight Clu...│ 2000 │ ... │ Search: fight...  │
│ 2026-03-22T10:31:00Z │ 603 │ The Matrix  │ 1999 │ ... │ Search: matrix    │
│ ...                                                                        │
└───────────────────────────────────────────────────────────────────────────┘

Success! 🎉


═══════════════════════════════════════════════════════════════
                        DATA FLOW
═══════════════════════════════════════════════════════════════

User searches "matrix"
        ↓
TMDBService.searchMovies("matrix")
        ↓
Fetches from TMDB API
        ↓
Returns [TMDBMovie]
        ↓
CSVLogger.logMovies(movies, source: "Search: matrix")
        ↓
Check: isLoggingEnabled?  → YES
        ↓
Append to Documents/tmdb_movies_log.csv
        ↓
File updated! ✅


═══════════════════════════════════════════════════════════════
                    WHAT GETS LOGGED
═══════════════════════════════════════════════════════════════

Every TMDB API call logs:

ACTION                  → SOURCE IN CSV
────────────────────────────────────────────────────────────
Search "matrix"        → "Search: matrix"
Browse Top Rated       → "Top Rated (Page 1)"
View actor's movies    → "Actor Discovery (ID: 3223)"
Filter by Action       → "Genre ID: 28"
Browse 90s movies      → "Decade: 1990s"
Similar to Fight Club  → "Similar to Movie ID: 550"
High rated movies      → "Rating >= 8.0"


═══════════════════════════════════════════════════════════════
                    FILE LOCATION
═══════════════════════════════════════════════════════════════

Your app's Documents folder:

📱 Your Device
  └─ 📁 MoviesIMiss2 (App)
      └─ 📁 Documents
          └─ 📄 tmdb_movies_log.csv  ← Here!


═══════════════════════════════════════════════════════════════
                    PERFORMANCE
═══════════════════════════════════════════════════════════════

When DISABLED (default):
┌─────────────────────────────────────────────────────────────┐
│  CSVLogger.logMovies() called                               │
│  └─ isLoggingEnabled? NO                                    │
│     └─ return immediately  ⚡ (zero overhead)               │
└─────────────────────────────────────────────────────────────┘

When ENABLED:
┌─────────────────────────────────────────────────────────────┐
│  CSVLogger.logMovies() called                               │
│  └─ isLoggingEnabled? YES                                   │
│     └─ Task { ... }  (async, doesn't block)                 │
│        └─ Write to file in background                       │
│                                                              │
│  Returns immediately to caller ⚡                            │
└─────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════
                    CHECKLIST
═══════════════════════════════════════════════════════════════

Setup:
☐ Add CSVLogger.swift to Xcode
☐ Add DebugSettingsView.swift to Xcode
☐ Build succeeds (⌘B)
☐ Add Debug Settings to UI
☐ Run app (⌘R)

Usage:
☐ Navigate to Debug Settings
☐ Toggle "Enable CSV Logging" ON
☐ Search for movies
☐ Check stats updated
☐ Export CSV file
☐ Open in spreadsheet app

Verify:
☐ Data appears in CSV
☐ Timestamps are correct
☐ Source field shows search query
☐ All columns present
☐ File size increases with use

Success! ✅


═══════════════════════════════════════════════════════════════
                    TROUBLESHOOTING
═══════════════════════════════════════════════════════════════

Problem: Build fails with "Cannot find 'CSVLogger'"
Solution: Make sure both files are added to Xcode project

Problem: No data being logged
Solution: Check toggle is ON, verify searches are happening

Problem: Can't export file
Solution: Make sure entry count > 0, try refreshing stats

Problem: File too large
Solution: Export current data, then clear log file


═══════════════════════════════════════════════════════════════
                    YOU'RE READY!
═══════════════════════════════════════════════════════════════

✅ CSV logging code is active in TMDBService
✅ CSVLogger.swift handles all file operations
✅ DebugSettingsView provides the UI
✅ Documentation is complete
✅ Just add the files to Xcode!

🎉 ADD THE FILES AND START LOGGING! 🎉
```
