# MoviesIMiss2

A personal multiplatform app for macOS, iOS, and iPadOS to track movies you've seen and want to watch again, with mood tracking and watch history.

## Setup Instructions

### 1. Get a TMDB API Key

1. Visit [The Movie Database](https://www.themoviedb.org/) and create a free account
2. Go to your account Settings → API
3. Request an API key (choose "Developer" option)
4. Copy your API key

### 2. Configure the App

1. In Xcode, right-click on the `MoviesIMiss2` folder in the Project Navigator
2. Select "New File..."
3. Choose "Property List" and name it `Secrets.plist`
4. Add a new key:
   - Key: `TMDB_API_KEY` (String)
   - Value: Your TMDB API key
5. Save the file

**Important:** The `Secrets.plist` file is already in `.gitignore` and will not be committed to version control.

### 3. Run the App

1. Select a target device or simulator (iOS 17+ required)
2. Press Cmd+R to build and run
3. The app will load a curated list of top-rated movies from TMDB

## Features

### Review Screen
- Displays a curated list of movies from TMDB
- Tap any movie to review it
- For each movie, you can:
  - Add it to your watchlist
  - Snooze it for later
  - Remove it from the list
  - Indicate if you've seen it before
  - Record when you watched it
  - Track what mood you were in
  - Note what mood it helps with

### My Watchlist
- Shows all movies you've added to your watchlist
- Sort by:
  - Most overdue (longest since last watched)
  - Recently watched
  - Recently added
  - Title (alphabetical)
- Tap any movie to see details or log a new viewing
- Swipe left to delete from watchlist

### Movie Details
- View full movie information
- Log when you watched it
- Quick "Log Watched Today" button
- View mood information you've recorded
- Remove from watchlist

## Architecture

### Data Model
- **SwiftData** for local persistence
- `SavedMovie` model with properties:
  - TMDB metadata (title, year, overview, poster)
  - Status (pending, want to watch, snoozed, removed)
  - Watch tracking (last watched, approximate watch date)
  - Mood tracking (mood when watched, mood it helps with)

### API Integration
- Uses TMDB API v3
- Endpoints:
  - Top Rated movies (for curated list)
  - Movie search (future feature)
- Poster images at w200 and w500 sizes

### UI Framework
- **SwiftUI** for all UI
- Tab-based navigation
- Modal sheets for movie decisions and details
- Native `AsyncImage` for poster loading
- Date pickers for watch tracking

## Requirements

- **macOS 14.0** (Sonoma) or later
- **iOS 17.0** or later
- **iPadOS 17.0** or later
- Xcode 15.0 or later
- Swift 5.9 or later
- TMDB API key (free)

## Privacy

- All data stored locally on device
- No user accounts required
- No iCloud sync (v1)
- API calls to TMDB only for movie metadata

## Future Enhancements (Not in v1)

- iCloud sync
- Search functionality
- Recommendations
- Streaming availability
- Push notifications
- Apple Watch companion app
- iPad-optimized layout

## License

This is a learning project based on the PRD for MoviesIMiss.
