# Streaming Provider Filtering in Watchlist Tabs

## Overview
Extended streaming provider filtering to work in the **Again!** and **New!** tabs, allowing users to filter their saved movies by where they can watch them.

## Implementation

### Files Updated

#### 1. AgainListView.swift
Added complete streaming provider filtering to the "Again!" tab:

**New State Properties:**
```swift
@State private var selectedStreamingProvider: StreamingProvider = .all
@State private var watchProviderCache: [Int: TMDBCountryProviders] = [:]
@State private var isLoadingProviders = false
private let tmdbService = TMDBService()
```

**Updated Computed Property:**
```swift
var sortedByNextWatch: [SavedMovie] {
    // Filters by vibe AND streaming provider
    // Only shows movies with confirmed provider availability
}
```

**New Toolbar Menu:**
- Same streaming provider menu as Browse tab
- 15 service options (Netflix, Prime, Disney+, AMC+, etc.)
- Positioned before Share/Email/Print buttons

**New Methods:**
- `streamingProviderMenu` - Toolbar menu component
- `providerButton(for:)` - Individual provider selection
- `loadWatchProviders()` - Batch loads provider data for watchlist movies

#### 2. NewMoviesView.swift
Added identical streaming provider filtering to the "New!" tab:

**New State Properties:**
```swift
@State private var selectedStreamingProvider: StreamingProvider = .all
@State private var watchProviderCache: [Int: TMDBCountryProviders] = [:]
@State private var isLoadingProviders = false
private let tmdbService = TMDBService()
```

**Updated Computed Property:**
```swift
var newMovies: [SavedMovie] {
    // Filters by lastWatched == nil AND streaming provider
}
```

**Same components as AgainListView:**
- Toolbar menu
- Provider selection
- Batch loading

## User Experience

### Again! Tab

**Before:**
- Shows all movies you've watched before
- Can filter by vibe
- No streaming service filtering

**After:**
- Shows all movies you've watched before ✅
- Can filter by vibe ✅
- **Can filter by streaming service** ⭐ NEW
- Example: "Show me only movies I can rewatch on AMC+"

**Use Cases:**
- "What movies in my Again! list can I watch on Netflix tonight?"
- "Show me my comfort movies that are on Amazon Prime (Free)"
- "Which movies can I rewatch on AMC+?" (like Donnie Brasco!)

### New! Tab

**Before:**
- Shows unwatched movies in watchlist
- No filtering beyond "not watched yet"

**After:**
- Shows unwatched movies in watchlist ✅
- **Can filter by streaming service** ⭐ NEW
- Example: "Show me new movies I can watch on Hulu"

**Use Cases:**
- "What new movies in my watchlist are on Disney+?"
- "Show me unwatched movies available on free services (Tubi, Pluto TV)"
- "Which new movies can I rent on Amazon?"

## How It Works

### 1. User Selects Streaming Service
User taps the service menu in toolbar and selects a service (e.g., "AMC+")

### 2. Provider Data Loads
```
🎬 Loading watch providers for 4 Again! movies...
✅ Loaded providers for 4 Again! movies
```

System batches API requests for all watchlist movies that don't have cached provider data.

### 3. Movies Filter
Only movies with confirmed availability on the selected service remain visible.

### 4. Caching
Provider data is cached in memory, so switching between services is instant.

## Technical Details

### Filtering Logic

**Again! Tab:**
```swift
// 1. Start with all rewatch movies
// 2. Filter by vibe (if selected)
// 3. Filter by streaming provider (if selected)
// 4. Sort by rewatch date
```

**New! Tab:**
```swift
// 1. Start with all watchlist movies
// 2. Filter lastWatched == nil
// 3. Filter by streaming provider (if selected)
// 4. Return filtered list
```

### Provider Data Loading

**Smart Loading:**
- Only loads data for movies without cached providers
- Batch loads all movies at once (concurrent requests)
- Reuses same cache across filter changes
- Separate caches for Browse, Again!, and New! tabs

**Performance:**
```swift
let movieIds = watchlistMovies
    .filter { watchProviderCache[$0.tmdbId] == nil }
    .map { $0.tmdbId }

let providers = await tmdbService.fetchWatchProvidersForMovies(movieIds: movieIds)
```

### Strict Filtering

Movies without provider data are **excluded**:
```swift
guard let providers = watchProviderCache[movie.tmdbId],
      let providerId = selectedStreamingProvider.providerId else {
    return false // Don't show if no provider data
}
```

This ensures you only see movies you can actually watch on the selected service.

## Example Scenarios

### Scenario 1: Finding Donnie Brasco on AMC+

**Problem:** User knows Donnie Brasco is in their "Again!" list and on AMC+, but can't find it.

**Solution:**
1. Open **Again!** tab
2. Tap streaming menu
3. Select **AMC+**
4. Donnie Brasco appears ✅

### Scenario 2: Tonight's Netflix Movie

**Problem:** User wants to rewatch something on Netflix from their list.

**Solution:**
1. Open **Again!** tab
2. Select **Netflix**
3. See all rewatchable movies on Netflix
4. Pick one and watch!

### Scenario 3: New Movies on Free Services

**Problem:** User wants to watch something new without paying.

**Solution:**
1. Open **New!** tab
2. Try **Tubi TV** or **Pluto TV**
3. See free options from watchlist
4. Watch for free!

### Scenario 4: Finding Prime-Included Movies

**Problem:** User has Prime but wants to avoid rentals.

**Solution:**
1. Open **Again!** or **New!** tab
2. Select **Amazon Prime (Free)**
3. See only Prime-included movies ✅
4. No rentals shown ❌

## Benefits

### For Users
✅ **Quick Discovery** - Find watchable movies fast
✅ **Service-Specific** - Filter by what you actually have
✅ **Avoid Rentals** - Separate Prime free vs paid
✅ **Save Time** - No manual checking of each movie
✅ **Better Decisions** - See options by service

### For Developer
✅ **Code Reuse** - Same logic as Browse filtering
✅ **Consistent UX** - Same menu across all tabs
✅ **Performance** - Smart caching prevents redundant API calls
✅ **Maintainable** - DRY principle with shared components

## Limitations

### Current Implementation
- ⚠️ Separate caches per tab (could be unified)
- ⚠️ No "loading" indicator in UI (only console logs)
- ⚠️ No empty state message when filter returns no results
- ⚠️ US region only (hardcoded "US")

### Future Enhancements

**1. Unified Cache**
Share provider cache across all tabs:
```swift
// In a shared manager or environment object
class WatchProviderManager: ObservableObject {
    @Published var cache: [Int: TMDBCountryProviders] = [:]
}
```

**2. Loading States**
Show progress when loading provider data:
```swift
if isLoadingProviders {
    ProgressView("Loading streaming data...")
}
```

**3. Empty State Messages**
```swift
if newMovies.isEmpty && selectedStreamingProvider != .all {
    Text("No movies found on \(selectedStreamingProvider.rawValue)")
}
```

**4. Country Selection**
Let users choose their region (US, UK, CA, etc.)

## Testing

### Test Cases

**Again! Tab:**
- [ ] Select AMC+ → Donnie Brasco appears
- [ ] Select Netflix → Shows Netflix movies
- [ ] Select "All Services" → Shows all movies
- [ ] Switch between services → Results update correctly
- [ ] Combine with vibe filter → Both filters work together

**New! Tab:**
- [ ] Select Prime (Free) → Shows Prime-included new movies
- [ ] Select Tubi → Shows free new movies
- [ ] No provider data → Movie doesn't appear
- [ ] Cache works → Second filter is instant

### Verification

1. Add "Donnie Brasco" to Again! list
2. Select AMC+ filter
3. Donnie Brasco should appear
4. Check console for provider data
5. Verify it shows AMC+ in "Where to Watch"

## Summary

Streaming provider filtering now works in **all three main tabs**:

1. **Browse** - Find new movies to add by service ✅
2. **Again!** - Filter rewatchable movies by service ✅ NEW
3. **New!** - Filter unwatched movies by service ✅ NEW

Users can now answer questions like:
- "What can I rewatch on AMC+ tonight?" → **Again! + AMC+**
- "What new movies are on Netflix?" → **New! + Netflix**
- "What's free on Prime?" → **Again!/New! + Prime (Free)**

The feature uses the same 15-service menu across all tabs for consistency! 🎉
