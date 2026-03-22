# Product Requirements Document: TV Shows Again!

## Executive Summary

Adapt the "Again!" movie rewatch tracking application into a comprehensive TV show rewatch tracking system. This application will allow users to track TV shows they want to watch again, schedule episode or season rewatches, filter by vibes and streaming services, and share their rewatch lists.

---

## 1. Product Overview

### 1.1 Purpose
Create a TV show equivalent of the "Again!" movie tracking app that helps users:
- Track TV shows they've seen before and want to rewatch
- Schedule rewatches at episode, season, or series level
- Filter by vibes, streaming providers, and genres
- Share rewatch lists via email, messages, or social media

### 1.2 Target Users
- TV enthusiasts who rewatch favorite shows
- Users managing multiple streaming subscriptions
- People seeking comfort rewatches based on mood
- Binge-watchers who cycle through beloved series

---

## 2. Data Model

### 2.1 Core Model: SavedTVShow

```swift
@Model
final class SavedTVShow {
    // TMDB Integration
    var tmdbId: Int
    var title: String
    var firstAirYear: String
    var lastAirYear: String?  // nil if still ongoing
    var overview: String
    var posterPath: String?
    var backdropPath: String?
    
    // Series Metadata
    var numberOfSeasons: Int
    var numberOfEpisodes: Int
    var status: String  // "Ended", "Returning", "Canceled", "In Production"
    var genres: [String]
    var networks: [String]  // e.g., "HBO", "Netflix"
    
    // User Tracking
    var dateAdded: Date
    var hasSeenBefore: Bool
    var statusRawValue: String  // "wantToWatch", "watching", "completed"
    
    // Rewatch Information
    var approximateFirstWatchDate: Date?
    var lastRewatchDate: Date?
    var nextRewatchDate: Date?
    var rewatchCount: Int  // Number of complete rewatches
    
    // Vibes & Mood
    var personalVibes: [String]?  // Multiple vibes support
    var vibeNotes: String?
    var moodWhenWatched: String?
    var moodItHelpsWithString: String?
    
    // Watch Progress
    var seasons: [SavedSeason]?  // Relationship to seasons
    var totalRewatchProgress: Double  // 0.0 to 1.0 for current rewatch
    
    // Computed properties
    var status: ShowStatus { get set }
    var isComplete: Bool { status == "Ended" }
    var displayYears: String { 
        if let lastYear = lastAirYear {
            return "\(firstAirYear) - \(lastYear)"
        }
        return "\(firstAirYear) - Present"
    }
}
```

### 2.2 Season Model: SavedSeason

```swift
@Model
final class SavedSeason {
    var seasonNumber: Int
    var name: String  // e.g., "Season 1", "Part 1", "Book Two"
    var episodeCount: Int
    var airDate: Date?
    var overview: String?
    var posterPath: String?
    
    // Rewatch tracking
    var nextRewatchDate: Date?
    var lastWatchedDate: Date?
    var hasRewatchedThisSeason: Bool
    
    // Progress
    var episodes: [SavedEpisode]?
    var watchedEpisodeCount: Int
    
    // Relationship
    var tvShow: SavedTVShow?
}
```

### 2.3 Episode Model: SavedEpisode (Optional - for granular tracking)

```swift
@Model
final class SavedEpisode {
    var episodeNumber: Int
    var seasonNumber: Int
    var name: String
    var airDate: Date?
    var runtime: Int  // in minutes
    var overview: String?
    var stillPath: String?  // Episode screenshot
    
    // User tracking
    var hasWatched: Bool
    var watchedDate: Date?
    var nextRewatchDate: Date?
    var personalRating: Int?  // 1-5 stars
    var notes: String?
    
    // Relationship
    var season: SavedSeason?
}
```

### 2.4 Enums

```swift
enum ShowStatus: String, Codable {
    case wantToWatch = "wantToWatch"
    case currentlyWatching = "currentlyWatching"
    case completed = "completed"
    case onHold = "onHold"
}

enum RewatchGranularity: String, CaseIterable {
    case episode = "Episode by Episode"
    case season = "Season by Season"
    case series = "Entire Series"
}
```

---

## 3. User Interface

### 3.1 Main View: AgainTVShowListView

**Purpose**: Display all TV shows marked for rewatching, sorted by next rewatch date

**Key Components**:
- Navigation title: "Again! TV"
- Vibe filter pills (horizontal scroll)
- Streaming provider filter menu
- Genre filter (optional)
- Show status filter (Ended vs. Ongoing)
- List of TV show rows

**TV Show Row Display**:
```
[Poster] Title (Years)
         X Seasons • Y Episodes
         [Vibe badges]
         Next rewatch: [Date/Status] • S3E5
         Streaming: Netflix, Hulu
         Progress: ████░░░░ 45%
```

**Features**:
- Tap to open detailed view
- Swipe to delete
- Share list functionality
- Email export
- Print list (macOS)

### 3.2 Detail View: TVShowDetailView

**Sections**:

1. **Header**
   - Large backdrop image
   - Poster thumbnail overlay
   - Title, years, status
   - Genres and networks
   - Quick actions (Mark as watched, Schedule rewatch)

2. **Rewatch Settings**
   - Rewatch granularity selector (Episode/Season/Series)
   - Next rewatch date picker
   - Total rewatch count display
   - Last rewatch date

3. **Season Breakdown**
   - Expandable list of seasons
   - Each season shows:
     - Season number and name
     - Episode count and progress
     - Next rewatch date (if scheduled)
     - Quick "Start Season" button
   - Optional episode list (if granular tracking enabled)

4. **Vibes & Mood**
   - Vibe picker (multiple selection)
   - Vibe notes text field
   - Mood tracking (when watched, helps with)

5. **Watch Information**
   - First watch date (approximate)
   - Last rewatch date
   - Rewatch count
   - Streaming providers
   - Watch notes

6. **Overview**
   - Show description
   - Cast and crew (from TMDB)

### 3.3 Filtering & Sorting

**Filter Options**:
- Vibe filters (same as movie app)
- Streaming providers (with series-level availability)
- Show status (Ended, Ongoing, etc.)
- Genre filters
- Rewatch granularity
- Completion status

**Sort Options**:
- Next rewatch date (ascending/descending)
- Recently added
- Alphabetical
- Rewatch count
- First air date

### 3.4 Progress Tracking Views

**Season Progress Card**:
```
Season 2: The Adventure Continues
━━━━━━━━░░ 60% complete (12/20 episodes)
Next: S2E13 "The Turning Point"
Next rewatch: March 25, 2026
```

**Series Progress View** (Optional separate view):
- Visual grid of all seasons
- Heat map showing rewatch frequency
- Timeline of watch history

---

## 4. Feature Requirements

### 4.1 Core Features (Must Have)

1. **TV Show Search & Discovery**
   - Search TMDB TV database
   - Display show metadata (seasons, episodes, status)
   - Add to "Want to Rewatch" list
   - Mark if seen before

2. **Rewatch Scheduling**
   - Set next rewatch date at series, season, or episode level
   - Calculate urgency (overdue, soon, later)
   - Visual indicators for urgency
   - Notifications for upcoming rewatches (optional)

3. **Vibe Tracking**
   - Apply multiple vibes per show
   - Filter by vibe
   - Vibe notes field
   - Mood tracking

4. **Streaming Provider Integration**
   - Fetch watch providers from TMDB
   - Filter by streaming service
   - Show availability in row display
   - Cache provider data

5. **Progress Tracking**
   - Track seasons watched
   - Optional episode-level tracking
   - Progress percentage
   - Mark seasons as completed

6. **Sharing & Export**
   - Share via system share sheet
   - Email with HTML formatting
   - Print functionality (macOS)
   - Export format:
     ```
     Title, Streaming Services, Years, Progress
     Breaking Bad, Netflix, 2008-2013, S3E8 (45%)
     The Office, Peacock, 2005-2013, Completed
     ```

### 4.2 Enhanced Features (Should Have)

1. **Episode-Level Tracking**
   - Optional granular episode tracking
   - Episode ratings and notes
   - "Next episode" quick action
   - Episode-specific rewatch dates

2. **Binge Scheduling**
   - Suggest binge-watch schedule based on episode count
   - Calculate days needed for complete rewatch
   - "Weekend binge" vs. "Daily episode" modes

3. **Rewatch History**
   - Timeline view of all rewatches
   - Stats (total episodes rewatched, favorite show, etc.)
   - Heat map of viewing patterns

4. **Watch Groups**
   - Group shows into collections
   - "Comfort Shows", "Fall Vibes", "Animated", etc.
   - Custom groups

5. **Smart Recommendations**
   - "Ready to rewatch" based on time since last watch
   - Similar shows based on vibes
   - "Complete this first" suggestions

### 4.3 Nice to Have

1. **Widgets**
   - "Next to rewatch" widget
   - Progress widget
   - Overdue shows widget

2. **Live Activities**
   - Binge watch session tracker
   - Episodes remaining countdown

3. **Siri Integration**
   - "What should I watch again today?"
   - "Mark The Office season 3 as watched"

4. **iCloud Sync**
   - Sync across devices
   - Share lists with family

5. **Apple TV App**
   - Browse rewatch list on TV
   - Quick access to streaming apps

---

## 5. Technical Requirements

### 5.1 Data Source

**TMDB API**:
- `/tv/{tv_id}` - TV show details
- `/tv/{tv_id}/season/{season_number}` - Season details
- `/tv/{tv_id}/season/{season_number}/episode/{episode_number}` - Episode details
- `/tv/{tv_id}/watch/providers` - Streaming availability
- `/search/tv` - TV show search

**Required Fields from TMDB**:
- Show: name, first_air_date, last_air_date, number_of_seasons, number_of_episodes, status, genres, networks, overview, poster_path, backdrop_path
- Season: season_number, name, episode_count, air_date, overview, poster_path
- Episode: episode_number, name, air_date, runtime, overview, still_path

### 5.2 SwiftData Relationships

```swift
// One-to-many relationship
SavedTVShow -> [SavedSeason]

// One-to-many relationship (if episode tracking enabled)
SavedSeason -> [SavedEpisode]

// Fetch examples
@Query(filter: #Predicate<SavedTVShow> { show in
    show.statusRawValue == "wantToWatch" && show.hasSeenBefore == true
}) var rewatchShows: [SavedTVShow]

@Query(filter: #Predicate<SavedTVShow> { show in
    show.nextRewatchDate != nil && show.nextRewatchDate! <= Date()
}) var overdueShows: [SavedTVShow]
```

### 5.3 Caching Strategy

Same as movie app:
- Image caching with `CachedAsyncImage`
- Watch provider caching with `[Int: TMDBCountryProviders]`
- Batch loading for performance

### 5.4 Platform Support

- iOS 17+
- iPadOS 17+
- macOS 14+ (Catalyst or native)
- visionOS (optional)

---

## 6. User Flows

### 6.1 Adding a Show to Rewatch

1. User searches for TV show
2. Selects show from search results
3. Marks "I've seen this before"
4. App prompts:
   - Which season/episode to rewatch from?
   - Or "Entire series from beginning"?
5. User sets next rewatch date
6. User adds vibes
7. Show appears in "Again! TV" list

### 6.2 Tracking Rewatch Progress

1. User opens show detail
2. Views season list
3. Taps "Mark S2 as watched"
4. Progress updates
5. Next rewatch date auto-advances to next season (optional)

### 6.3 Finding Something to Rewatch

1. User opens "Again! TV" tab
2. Filters by vibe (e.g., "Cozy")
3. Filters by streaming provider (e.g., "Netflix")
4. Sees shows sorted by rewatch urgency
5. Selects show
6. Taps "Start Watching" → Opens streaming app (future enhancement)

---

## 7. Design Considerations

### 7.1 TV vs. Movie Differences

| Aspect | Movies | TV Shows |
|--------|--------|----------|
| Duration | Single sitting | Multiple episodes/seasons |
| Progress | Binary (watched/unwatched) | Percentage, season/episode tracking |
| Rewatch Frequency | Months/years | Can vary by season |
| Content Structure | Simple | Hierarchical (Show → Season → Episode) |
| Scheduling | Single date | Episode cadence, binge vs. daily |

### 7.2 UI Adaptations

**More Complex Row Display**:
- Shows need more information (seasons, episodes, progress)
- Row height may be taller than movie rows
- Consider expandable rows for season breakdown

**Progress Visualization**:
- Progress bars for current rewatch
- Season grid for completed seasons
- Color coding for watched/unwatched seasons

**Granularity Toggle**:
- Allow users to choose detail level
- Simple mode: Series-level tracking only
- Advanced mode: Episode-level tracking

### 7.3 Empty States

```
No TV Shows Scheduled for Rewatch

Add shows you've loved before and schedule when you want to revisit them.

[Browse Shows] button
```

### 7.4 Urgency Indicators

Same color scheme as movies:
- 🔴 Red: Overdue shows/episodes
- 🟠 Orange: Due within 30 days
- 🟢 Green: Scheduled for later

Additional indicator:
- 🔵 Blue: Currently binge-watching (in progress)

---

## 8. Sharing & Export

### 8.1 Shareable Text Format

```
Find your own shows at MoviesIMiss, meanwhile…
[Device Name] sent you a list of TV shows to watch again.

The Office, Peacock, 2005-2013, Season 5 (50% progress)
Breaking Bad, Netflix, 2008-2013, Entire series
Stranger Things, Netflix, 2016-Present, Season 3 onwards
Community, Hulu, 2009-2015, Completed
```

### 8.2 HTML Email Format

Similar to movie app but with structured table:
- Show title
- Streaming service
- Years aired
- Current progress or next episode
- Rewatch date

### 8.3 Print Format

Formatted list with:
- Show titles alphabetically or by date
- Season/episode information
- Dates and progress

---

## 9. Migration & Code Reuse

### 9.1 Reusable Components from Movie App

- `CachedAsyncImage` - Identical
- `VibesBadgeRow` - Identical
- `VibePicker` - Identical
- `MovieVibe` enum → Rename to `ContentVibe` for shared use
- `WatchProviderFilter` - Adapt for TV shows
- `TMDBService` - Extend with TV endpoints
- Email/sharing infrastructure - Minimal changes

### 9.2 New Components Needed

- `AgainTVShowListView` - Based on `AgainListView`
- `TVShowDetailView` - New (more complex than movies)
- `TVShowRow` - Based on `AgainMovieRow`
- `SeasonProgressView` - New
- `EpisodeListView` - New (optional)
- `RewatchScheduleBuilder` - New utility

### 9.3 Shared vs. Separate Apps

**Option A: Separate App**
- Pros: Focused experience, simpler codebase
- Cons: Code duplication, separate purchases

**Option B: Combined App with Tabs**
- Pros: Single purchase, shared components
- Cons: More complex navigation, larger app

**Recommendation**: Start with separate app, consider merge later if successful

---

## 10. Success Metrics

### 10.1 User Engagement
- Number of shows added
- Rewatch schedules created
- Filter usage (vibes, providers)
- Share/export frequency

### 10.2 Feature Adoption
- Episode-level vs. season-level tracking ratio
- Average shows per user
- Vibe usage statistics
- Streaming filter usage

### 10.3 Retention
- Daily/weekly active users
- Rewatch completion rate
- Return visits after rewatch completion

---

## 11. Future Enhancements

### 11.1 Phase 2 Features
- Watch party scheduling
- Social features (share progress with friends)
- Integration with TV Time, Trakt
- Watch history import
- Reminders/notifications

### 11.2 Phase 3 Features
- AI recommendations based on mood
- Watchlist sharing with friends
- Group rewatch coordination
- Stats dashboard (hours watched, favorite genres)
- Achievement system

---

## 12. Open Questions

1. **Episode Tracking Complexity**: Should episode-level tracking be MVP or Phase 2?
   - Recommendation: Start with season-level, add episodes in Phase 2

2. **Ongoing Shows**: How to handle shows still airing?
   - Track up to current episode
   - Auto-update when new seasons air
   - Separate "Catch up" vs. "Rewatch" modes

3. **Mini-Series**: How to categorize limited series?
   - Treat as single "season"
   - Different scheduling logic

4. **Anime**: Special considerations for anime?
   - Support for arcs/parts nomenclature
   - Support for multiple seasons with different titles

5. **Reality TV**: Include reality shows?
   - Different tracking model (highlights vs. all episodes)
   - Competition shows vs. lifestyle shows

---

## 13. Implementation Phases

### Phase 1: MVP (4-6 weeks)
- Core data models (Show, Season)
- TMDB integration for TV
- Basic rewatch scheduling (series and season level)
- Vibe filtering
- Streaming provider filtering
- List sharing

### Phase 2: Enhanced Features (4-6 weeks)
- Episode-level tracking
- Progress visualization
- Rewatch history
- Stats dashboard
- Watch groups

### Phase 3: Polish & Expansion (4-6 weeks)
- Widgets
- Apple TV app
- iCloud sync
- Advanced scheduling
- Notifications

---

## Appendix A: Example TMDB API Response

### TV Show Details
```json
{
  "id": 1396,
  "name": "Breaking Bad",
  "first_air_date": "2008-01-20",
  "last_air_date": "2013-09-29",
  "number_of_seasons": 5,
  "number_of_episodes": 62,
  "status": "Ended",
  "genres": [{"id": 18, "name": "Drama"}, {"id": 80, "name": "Crime"}],
  "networks": [{"id": 174, "name": "AMC"}],
  "overview": "Walter White, a struggling...",
  "poster_path": "/ggFHVNu6YYI5L9pCfOacjizRGt.jpg",
  "backdrop_path": "/tsRy63Mu5cu8etL1X7ZLyf7UP1M.jpg"
}
```

### Season Details
```json
{
  "season_number": 1,
  "name": "Season 1",
  "episode_count": 7,
  "air_date": "2008-01-20",
  "overview": "High school chemistry teacher...",
  "poster_path": "/1BP4xYv9ZG4ZVHkL7ocOziBbSYH.jpg"
}
```

---

## Appendix B: UI Mockup Descriptions

### Again TV Show List View
```
┌────────────────────────────────────┐
│  ← Again! TV          [Filter] ⋮  │
├────────────────────────────────────┤
│  [All] [Cozy] [Thrilling] ...     │
├────────────────────────────────────┤
│                                    │
│  ┌──┐ Breaking Bad (2008-2013)    │
│  │  │ 5 Seasons • 62 Episodes      │
│  │  │ [Drama] [Thrilling]          │
│  │  │ 🔴 2 days overdue • S3E1     │
│  │  │ Netflix, Prime                │
│  │  │ ████████░░ 78%                │
│  └──┘                               │
├────────────────────────────────────┤
│  ┌──┐ The Office (2005-2013)       │
│  │  │ 9 Seasons • 201 Episodes     │
│  │  │ [Cozy] [Feel-Good]           │
│  │  │ 🟢 In 2 weeks • S4E1         │
│  │  │ Peacock                       │
│  │  │ ██████░░░░ 56%                │
│  └──┘                               │
└────────────────────────────────────┘
```

### TV Show Detail View
```
┌────────────────────────────────────┐
│  [  Backdrop Image               ] │
│  ┌─┐                                │
│  │ │ Breaking Bad                   │
│  └─┘ 2008-2013 • Ended              │
│      Drama, Crime, Thriller         │
│      [▶ Start Rewatch]              │
├────────────────────────────────────┤
│  REWATCH SCHEDULE                  │
│  Next: Season 3, Episode 1         │
│  Date: March 23, 2026 (overdue)    │
│  Progress: ████████░░ 78%          │
│  Rewatched: 3 times                │
├────────────────────────────────────┤
│  SEASONS                            │
│  ✅ Season 1 (7 episodes)          │
│  ✅ Season 2 (13 episodes)         │
│  ⏸ Season 3 (13 episodes) ◀        │
│  ⬜ Season 4 (13 episodes)          │
│  ⬜ Season 5 (16 episodes)          │
├────────────────────────────────────┤
│  VIBES & MOOD                       │
│  [Thrilling] [Epic]                 │
│  Helps with: Need intensity        │
└────────────────────────────────────┘
```

---

## Conclusion

This PRD provides a comprehensive blueprint for adapting the "Again!" movie tracking app into a TV show rewatch tracker. The key differences revolve around handling episodic content, progress tracking, and more complex scheduling. By reusing core components (vibes, streaming filters, sharing) and adapting the data model for hierarchical content, this can be built efficiently while maintaining consistency with the original app's design philosophy.
