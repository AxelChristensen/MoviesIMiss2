# Aggressive Movie Loading for Streaming Filters

## Problem
When filtering by streaming services (Netflix, Paramount+, etc.), many movies weren't showing up because the Browse tab only loaded 10 pages (200 movies) initially. Popular movies like "Casino", "Mission Impossible", etc. weren't in that initial batch.

## Solution - Load Way More Movies

### Changes Made:

#### 1. Increased Maximum Pages
**Before:** 10 pages (200 movies max)
**After:** 25 pages (500 movies max)

```swift
private let maxPages = 25 // Increased from 10
```

#### 2. Aggressive Auto-Loading for Streaming Filters
When a streaming filter is selected, automatically load many more pages:

- **No filters:** Load 1 page (20 movies)
- **Streaming filter active:** Load up to 15 pages (300+ movies)
- **Rating filter:** Load 5-10 pages (100-200 movies)
- **Target:** At least 100 movies when streaming filter is active

#### 3. Smart Reloading
When you switch from "All Services" to a specific service (like Netflix), if there are fewer than 100 movies, it automatically triggers a reload to fetch more.

```swift
if wasAll && provider != .all && pendingMovies.count < 100 {
    await loadCuratedMovies() // Reload with more pages
}
```

### How It Works:

1. **Initial Load:** Opens Browse tab → Loads 20 movies
2. **Select Netflix:** Detects you want to filter → Automatically loads 15 more pages (300 movies total)
3. **Provider Data:** Fetches streaming info for all 300 movies
4. **Filter:** Shows only movies available on Netflix

### Why This Helps:

**Before (200 movies max):**
- Filter by Netflix → Maybe 30-50 movies
- Many popular movies missing
- Casino, Mission Impossible, etc. not in list

**After (500 movies max, auto-loads 300+):**
- Filter by Netflix → 100-200+ movies
- Much better coverage of popular titles
- Casino, Mission Impossible, etc. more likely to appear

### Performance Considerations:

1. **Lazy Loading:** Movies load progressively, not all at once
2. **Caching:** Provider data is cached, so switching filters is fast
3. **Brief Delay:** 100ms delay between page loads to avoid API throttling
4. **Smart Loading:** Only loads extra pages when filters are active

### Expected Behavior:

1. Go to Browse tab
2. Select "Well-Reviewed (7.0+)" or "Hidden Gems (6.5+)"
3. Select Netflix filter
4. See message: `🎬 Streaming filter active - loading extra pages for better coverage`
5. Wait a few seconds for loading
6. See: `✅ Final count: 300 movies loaded`
7. Much better Netflix selection!

### Console Output:

```
🎬 Streaming filter active - loading extra pages for better coverage
🔄 Auto-loading up to 15 more pages (target: 100 movies)
📦 Fetched 20 movies from API
📦 Fetched 20 movies from API
...
✅ Final count: 320 movies loaded
🎬 Loading watch providers for 320 movies...
✅ Loaded providers for 298 movies
🎯 Movies matching Netflix: 142
```

## Trade-offs:

### Pros:
- ✅ Much better streaming service coverage
- ✅ More likely to find specific movies
- ✅ Better user experience overall

### Cons:
- ⏱️ Takes 5-10 seconds to load when streaming filter first selected
- 💾 Uses more memory (300-500 movies vs 200)
- 🌐 More API calls to TMDB

The trade-off is worth it for much better streaming filter functionality!

## Recommendations:

For best results:
1. **Use "Well-Reviewed (7.0+)" or "Hidden Gems (6.5+)"** - These have the most movies
2. **Wait for initial load** - Let it fetch 300+ movies first
3. **Then filter by streaming service** - You'll see way more results
4. **Keep scrolling** - Lazy loading continues to load more if needed

## Future Improvements:

Possible enhancements:
- Add progress indicator during bulk loading
- Make max pages configurable by user
- Pre-load provider data in background
- Cache provider data longer term
