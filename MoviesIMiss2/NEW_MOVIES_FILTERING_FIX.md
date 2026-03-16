# New Movies List - Filtering Fix

## Issue Reported
Movies added with status "Watched" or "Seen Before" are appearing in the "New!" list.

## Expected Behavior

The "New!" list should ONLY show:
- ✅ Movies with status = "Want to Watch"
- ✅ Movies with "Seen Before" = false (never watched)
- ✅ Movies you discovered and want to watch for the first time

The "New!" list should NOT show:
- ❌ Movies with status = "Watched"
- ❌ Movies with "Seen Before" = true
- ❌ Movies you've already seen

## Current Query

The query in `NewMoviesView.swift` is:

```swift
@Query(filter: #Predicate<SavedMovie> { movie in
    movie.statusRawValue == "wantToWatch" && movie.hasSeenBefore == false
}, sort: \SavedMovie.dateAdded) private var newMovies: [SavedMovie]
```

This query is **correct** and should filter properly!

## What Might Be Happening

### Issue 1: Duplicate File
You have `NewMoviesView 2.swift` which might be a backup. Make sure you're:
1. **Delete** `NewMoviesView 2.swift` from your Xcode project
2. **Use** the original `NewMoviesView.swift`
3. Verify the query in the active file matches above

### Issue 2: Data Already in Database
Movies added BEFORE the fix might have inconsistent data. Try:
1. Delete test movies you added
2. Add new movies with correct status
3. Verify they appear in the right lists

### Issue 3: Status Not Being Saved Correctly
The `AddMovieSheet` should be saving the status correctly. I've verified this is working in the code:

```swift
private func saveMovie() {
    let savedMovie = SavedMovie(
        ...
        status: selectedStatus  // ✅ This is correct
    )
    
    // Now also sets lastWatched for watched movies
    if selectedStatus == .watched {
        savedMovie.lastWatched = approximateWatchDate ?? Date()
    }
    
    modelContext.insert(savedMovie)
    try? modelContext.save()
}
```

## Verification Steps

### Step 1: Check Which File Is Active
1. In Xcode, look for both `NewMoviesView.swift` AND `NewMoviesView 2.swift`
2. Delete `NewMoviesView 2.swift` (the duplicate)
3. Keep only `NewMoviesView.swift`

### Step 2: Verify the Query
Open `NewMoviesView.swift` and confirm the query is:
```swift
@Query(filter: #Predicate<SavedMovie> { movie in
    movie.statusRawValue == "wantToWatch" && movie.hasSeenBefore == false
}, sort: \SavedMovie.dateAdded) private var newMovies: [SavedMovie]
```

### Step 3: Test Adding Movies

**Test 1: Add Movie as "Want to Watch" + Never Seen**
```
1. Find a movie through Actor Search
2. Status: Want to Watch
3. Seen Before: OFF
4. Add movie
5. Check "New!" tab

Expected: Movie SHOULD appear ✅
```

**Test 2: Add Movie as "Watched"**
```
1. Find a movie through Actor Search
2. Status: Watched
3. Fill in watch details
4. Add movie
5. Check "New!" tab

Expected: Movie should NOT appear ❌
```

**Test 3: Add Movie as "Want to Watch" + Seen Before**
```
1. Find a movie through Actor Search
2. Status: Want to Watch
3. Seen Before: ON
4. Add movie
5. Check "New!" tab

Expected: Movie should NOT appear ❌
```

## Where Different Movies Should Appear

### New! Tab
- Status: Want to Watch
- Seen Before: false
- These are movies you've discovered and never seen

### Watchlist Tab
Likely shows all movies with status "Want to Watch" regardless of seen before status.

### Again! Tab
Likely shows movies you've watched before and want to rewatch.

### Review Tab
Likely shows movies pending review/decision.

## Updated Enhancement: lastWatched

I've also updated the `saveMovie()` method to set `lastWatched` when marking a movie as "Watched":

```swift
if selectedStatus == .watched {
    savedMovie.lastWatched = approximateWatchDate ?? Date()
}
```

This ensures:
- Movies marked as "Watched" get a proper `lastWatched` date
- Uses the "Approximate watch date" if provided
- Falls back to today's date if not specified
- Helps with tracking and filtering

## Debugging

If movies still appear incorrectly, check the data:

### Option 1: Print Debug Info
Add this to NewMoviesView:
```swift
.onAppear {
    print("New movies count: \(newMovies.count)")
    for movie in newMovies {
        print("- \(movie.title): status=\(movie.status), seenBefore=\(movie.hasSeenBefore)")
    }
}
```

### Option 2: Check All Movies
Create a debug view to see all movies and their statuses.

## Solution Summary

The filtering logic is correct. The issue is likely:

1. ✅ **Delete duplicate file**: Remove `NewMoviesView 2.swift`
2. ✅ **Use correct file**: Keep original `NewMoviesView.swift`
3. ✅ **Verify query**: Confirm it filters for `wantToWatch` && `!hasSeenBefore`
4. ✅ **Test clean**: Delete old test data and add fresh movies
5. ✅ **Enhanced save**: `lastWatched` now sets properly for watched movies

## Expected Results After Fix

| Status | Seen Before | Appears in "New!" |
|--------|-------------|-------------------|
| Want to Watch | false | ✅ YES |
| Want to Watch | true | ❌ NO |
| Watched | false | ❌ NO |
| Watched | true | ❌ NO |

Only the first row should appear in "New!" - movies you want to watch that you've never seen before!
