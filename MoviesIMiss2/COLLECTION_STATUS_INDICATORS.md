# Collection Status Indicators for Movie Cards

## Feature Overview

Added visual indicators to movie cards in Actor Search and Browse Search to show when a movie is already in your collection. This prevents accidentally adding duplicate movies and shows you what list they're in.

## What Was Added

### Visual Indicators

1. **Green Checkmark Badge** - Appears on poster corner
2. **Status Pill** - Shows which list the movie is in
3. **Icon Change** - Plus icon changes to checkmark when already added

### Status Messages

- **"In New! List"** - Movie is in your first-time watch queue
- **"In Again! List"** - Movie is in your rewatch queue  
- **"Snoozed"** - Movie was snoozed for later
- **"Previously Removed"** - You've removed this movie before

## Where It Appears

✅ **Actor Search** - MovieCard component  
✅ **Browse Search Results** - SearchMovieCard component  
✅ **Related Movies** - Uses same cards (automatic)  

## Visual Design

### Movie Not in Collection
```
┌────────────────────────────────────┐
│ ┌────┐  The Shawshank Redemption   │
│ │ 🎬 │  1994                        │
│ │    │  ⭐ 9.3                      │
│ └────┘  Overview text...            │
│                              [+]    │ ← Blue plus icon
└────────────────────────────────────┘
```

### Movie Already in Collection
```
┌────────────────────────────────────┐
│ ┌────┐✓ The Shawshank Redemption   │ ← Green checkmark
│ │ 🎬 │  [In Again! List]           │ ← Green status pill
│ │    │  1994                        │
│ └────┘  ⭐ 9.3                      │
│         Overview text...            │
│                              [✓]    │ ← Green checkmark icon
└────────────────────────────────────┘
```

## Technical Implementation

### Files Modified

1. **ActorSearchView.swift** - `MovieCard`
2. **MovieListView.swift** - `SearchMovieCard`

### Added Components

Both cards now include:

```swift
@Environment(\.modelContext) private var modelContext
@Query private var allMovies: [SavedMovie]

// Check if this movie is already saved
private var existingMovie: SavedMovie? {
    allMovies.first { $0.tmdbId == movie.id }
}

private var collectionStatus: String? {
    guard let existing = existingMovie else { return nil }
    
    switch existing.status {
    case .wantToWatch:
        if existing.hasSeenBefore {
            return "In Again! List"
        } else {
            return "In New! List"
        }
    case .snoozed:
        return "Snoozed"
    case .removed:
        return "Previously Removed"
    case .pending:
        return nil // Don't show for pending
    }
}
```

### Poster Badge Overlay

```swift
ZStack(alignment: .topTrailing) {
    // Poster image
    ...
    
    // Collection badge overlay
    if existingMovie != nil {
        Image(systemName: "checkmark.circle.fill")
            .font(.title3)
            .foregroundStyle(.white)
            .background(
                Circle()
                    .fill(.green)
                    .padding(-4)
            )
            .offset(x: 8, y: -8)
    }
}
```

### Status Pill

```swift
// Collection status badge
if let status = collectionStatus {
    HStack(spacing: 4) {
        Image(systemName: "checkmark.circle.fill")
            .font(.caption2)
        Text(status)
            .font(.caption)
            .fontWeight(.semibold)
    }
    .foregroundStyle(.white)
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(.green)
    .clipShape(Capsule())
}
```

### Action Icon Update

```swift
private var addIcon: some View {
    Image(systemName: existingMovie != nil ? "checkmark.circle.fill" : "plus.circle.fill")
        .font(.title2)
        .foregroundStyle(existingMovie != nil ? .green : .blue)
}
```

## User Flows

### Scenario 1: Searching for a Movie You've Already Added

```
1. Go to Actors tab
2. Search for "Tom Hanks"
3. Browse his movies
4. See "Forrest Gump" with:
   ✓ Green checkmark on poster
   ✓ "In Again! List" pill
   ✓ Green checkmark icon instead of plus
5. You know you've already added it!
```

### Scenario 2: Avoiding Duplicates

```
1. Friend recommends "Inception"
2. Search for it in Browse
3. See green checkmark + "In New! List"
4. Remember you already added it
5. No duplicate created!
```

### Scenario 3: Finding Movies You've Snoozed

```
1. Browsing actor filmography
2. See "Movie Title" with "Snoozed" badge
3. Remember you snoozed it before
4. Can decide to add it now or skip again
```

### Scenario 4: Previously Removed Movies

```
1. Search for a movie
2. See "Previously Removed" badge
3. Remember why you removed it
4. Can choose to add it again or skip
```

## Status Breakdown

| Movie Status | Badge Text | Icon | Color | Meaning |
|--------------|------------|------|-------|---------|
| New! (unwatched) | "In New! List" | ✓ | Green | Added to first-time watch queue |
| Again! (rewatch) | "In Again! List" | ✓ | Green | Added to rewatch queue |
| Snoozed | "Snoozed" | ✓ | Green | Postponed for later consideration |
| Removed | "Previously Removed" | ✓ | Green | You've explicitly removed this before |
| Pending | *(no badge)* | + | Blue | From Browse curated list, not decided yet |
| Not in collection | *(no badge)* | + | Blue | Never added to your collection |

## Visual Elements

### 1. Poster Corner Badge
- **Position:** Top-right corner, slightly offset
- **Design:** White checkmark on green circle
- **Size:** `.title3` font
- **Purpose:** Quick visual scan

### 2. Status Text Pill
- **Position:** Below title, inline with text
- **Design:** White text on green capsule background
- **Font:** `.caption` (semibold)
- **Purpose:** Specific status information

### 3. Action Icon
- **Position:** Right side of card
- **States:** 
  - Not added: Blue `plus.circle.fill`
  - Already added: Green `checkmark.circle.fill`
- **Size:** `.title2` font
- **Purpose:** Visual reinforcement

## Benefits

✅ **Prevent Duplicates** - See at a glance if you've added a movie  
✅ **Know the Context** - Understand which list it's in  
✅ **Quick Scanning** - Green checkmarks stand out  
✅ **Remember Decisions** - See if you snoozed or removed it  
✅ **Better UX** - No confusion about what's in your collection  
✅ **Informed Choices** - Can still tap to view/modify  

## Edge Cases Handled

✅ **Pending Movies** - Don't show badges (not decided yet)  
✅ **Movies in Multiple States** - Shows current status only  
✅ **Removed Movies** - Shows "Previously Removed" to remind you  
✅ **Snoozed Movies** - Lets you know you postponed it  
✅ **Database Queries** - Efficient lookup with @Query  

## Performance

- **Query Optimization:** Uses @Query with automatic updates
- **Lightweight Logic:** Simple first() lookup by tmdbId
- **No Extra API Calls:** Uses existing database
- **Real-time Updates:** SwiftData automatically refreshes when collection changes

## Testing

### Test 1: Actor Search - Already Added Movie
```
1. Add "Inception" to New! list (via Browse or Actor)
2. Go to Actors tab
3. Search for "Christopher Nolan"
4. Find "Inception" in results
5. Should show:
   ✓ Green checkmark on poster
   ✓ "In New! List" pill
   ✓ Green checkmark icon
```

### Test 2: Browse Search - Rewatch Movie
```
1. Add "The Grand Budapest Hotel" to Again! list
2. Go to Browse tab
3. Search "grand budapest"
4. Should show:
   ✓ Green checkmark on poster
   ✓ "In Again! List" pill
   ✓ Green checkmark icon
```

### Test 3: Snoozed Movie
```
1. Browse curated list, snooze a movie
2. Later, search for that actor
3. Find the snoozed movie
4. Should show:
   ✓ Green checkmark on poster
   ✓ "Snoozed" pill
   ✓ Green checkmark icon
```

### Test 4: Movie Not in Collection
```
1. Search for any actor
2. Find a movie you haven't added
3. Should show:
   ✗ No checkmark on poster
   ✗ No status pill
   ✓ Blue plus icon
```

### Test 5: Real-time Updates
```
1. Search for a movie (not added)
2. Blue plus icon shows
3. Tap to add it to New! list
4. Go back to search
5. Green checkmark should now appear!
```

## Design Rationale

### Why Green?
- Universal "success" / "done" color
- Stands out against movie posters
- Consistent with iOS design language
- Positive association

### Why Show Status Text?
- "In New! List" vs "In Again! List" helps memory
- "Snoozed" reminds you of previous decision
- "Previously Removed" prevents re-adding unwanted movies
- More informative than just a checkmark

### Why Multiple Indicators?
- **Poster badge** - Quick scanning while scrolling
- **Status pill** - Detailed info when reading
- **Icon change** - Reinforcement at action point
- Redundancy ensures you notice

### Why Allow Tapping?
- You can still view the movie details
- Might want to see your notes/vibe
- Can modify the entry
- Can see rewatch date
- Not blocking any functionality

## Accessibility

- Clear visual indicators (checkmark + color)
- Text labels for status (not just color-coded)
- VoiceOver will read status pills
- Icon changes are semantic (plus vs checkmark)
- Sufficient contrast (white on green)

## Future Enhancements

### Possible Additions:
- Show vibe badge on cards if movie has one
- Show rewatch date if coming up soon
- Different colors for different statuses
- Tap checkmark to go directly to movie detail
- "View in [List Name]" button
- Filter to hide already-added movies

### Advanced Features:
- "Add Anyway" option for intentional duplicates
- Compare with existing entry before re-adding
- Merge duplicate entries
- "Already watched this?" prompt

## Comparison: Before vs After

### Before
```
Problem: No way to know if movie already added
Result: Potential duplicates, confusion
User: "Did I already add this?"
```

### After
```
Solution: Clear visual indicators
Result: Instant recognition, no duplicates
User: "Oh, I already have this in my Again! list!"
```

## Integration

Works seamlessly with:
- ✅ Actor Search
- ✅ Browse Search  
- ✅ Related Movies (similar/recommended)
- ✅ Director Search
- ✅ All discovery features using TMDBMovie cards

## Status

✅ **FULLY IMPLEMENTED** - Collection indicators live!

**To test:**
1. Add some movies to your lists
2. Search for those actors or movies
3. See green checkmarks and status pills
4. Notice plus icons change to checkmarks
5. No more duplicate additions!

---

**Now you'll always know what's already in your collection!** 🎬✨
