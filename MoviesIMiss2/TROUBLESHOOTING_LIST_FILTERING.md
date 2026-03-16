# Troubleshooting: Movies Appearing in Both Lists

## The Issue
Movies are still appearing in both "New!" and "Again!" lists even after the filtering fix.

## Root Causes

### 1. Old Data in Database
Movies added BEFORE the fix might have inconsistent data. The queries are now correct, but old data doesn't match the new logic.

### 2. Duplicate Files Still Present
If `NewMoviesView 2.swift` is still in your project, Xcode might be using the wrong file.

### 3. Build Cache
Xcode's build cache might contain old code even after changes.

## Solution Steps

### Step 1: Delete Duplicate Files
1. In Xcode's Project Navigator (left sidebar)
2. Look for **`NewMoviesView 2.swift`**
3. Right-click → **Delete**
4. Choose **"Move to Trash"** (NOT "Remove Reference")

### Step 2: Clean Build
1. In Xcode menu: **Product** → **Clean Build Folder** (⇧⌘K)
2. Wait for it to complete
3. Close Xcode completely
4. Reopen Xcode

### Step 3: Delete All Test Data
Since old data might be corrupted, delete all movies from your app:

**Option A: Through the App**
- Go through each tab (New!, Again!, Browse)
- Swipe to delete all movies
- Start fresh

**Option B: Reset App Data**
1. Delete the app from your device/simulator
2. Clean build folder in Xcode
3. Rebuild and run
4. Fresh database!

### Step 4: Verify Queries

Check that these files have the correct queries:

**NewMoviesView.swift** (or NewMoviesView 2.swift if that's your active one):
```swift
@Query(filter: #Predicate<SavedMovie> { movie in
    movie.statusRawValue == "wantToWatch" && movie.hasSeenBefore == false
}, sort: \SavedMovie.dateAdded) private var newMovies: [SavedMovie]
```

**AgainListView.swift**:
```swift
@Query(filter: #Predicate<SavedMovie> { movie in
    movie.statusRawValue == "wantToWatch" && movie.hasSeenBefore == true
}, sort: \SavedMovie.nextRewatchDate) private var watchlistMovies: [SavedMovie]
```

### Step 5: Test with Fresh Data

Add test movies with SPECIFIC settings:

**Test 1: New Movie (Should appear in "New!" ONLY)**
```
1. Go to Browse or Actors tab
2. Search for "Inception"
3. Add movie:
   - Status: "Want to Watch"
   - Seen Before: OFF (unchecked) ← KEY!
4. Check tabs:
   - New! → Should appear ✅
   - Again! → Should NOT appear ❌
```

**Test 2: Rewatch Movie (Should appear in "Again!" ONLY)**
```
1. Go to Browse or Actors tab
2. Search for "The Matrix"
3. Add movie:
   - Status: "Want to Watch"
   - Seen Before: ON (checked) ← KEY!
4. Check tabs:
   - New! → Should NOT appear ❌
   - Again! → Should appear ✅
```

**Test 3: Just Watched (Should appear in NEITHER)**
```
1. Go to Browse or Actors tab
2. Search for "Dune"
3. Add movie:
   - Status: "Watched" ← KEY!
   - Fill in watch details
4. Check tabs:
   - New! → Should NOT appear ❌
   - Again! → Should NOT appear ❌
```

## Expected Behavior Table

| Status | Seen Before | Should Show in New! | Should Show in Again! |
|--------|-------------|---------------------|----------------------|
| Want to Watch | false | ✅ YES | ❌ NO |
| Want to Watch | true | ❌ NO | ✅ YES |
| Watched | false | ❌ NO | ❌ NO |
| Watched | true | ❌ NO | ❌ NO |

## Debugging: Check Actual Data

If movies still appear in both lists, add debug logging:

### NewMoviesView.swift
Add this to the `body` view:
```swift
.onAppear {
    print("=== NEW MOVIES DEBUG ===")
    print("Count: \(newMovies.count)")
    for movie in newMovies {
        print("- \(movie.title)")
        print("  Status: \(movie.statusRawValue)")
        print("  Seen Before: \(movie.hasSeenBefore)")
    }
}
```

### AgainListView.swift
Add this to the `body` view:
```swift
.onAppear {
    print("=== AGAIN MOVIES DEBUG ===")
    print("Count: \(watchlistMovies.count)")
    for movie in watchlistMovies {
        print("- \(movie.title)")
        print("  Status: \(movie.statusRawValue)")
        print("  Seen Before: \(movie.hasSeenBefore)")
    }
}
```

Run the app and check Xcode's console. If a movie appears in BOTH lists, you'll see it printed twice with its actual data.

## Common Issues and Solutions

### Issue: "Movies I added are still in both lists"
**Solution**: Those are old movies. Delete them and add fresh ones with correct settings.

### Issue: "New movies go to both lists immediately"
**Solution**: 
1. Verify you deleted `NewMoviesView 2.swift`
2. Clean build folder
3. Restart Xcode
4. The query code might not be updated

### Issue: "I don't see NewMoviesView 2.swift"
**Solution**: It might be hidden. In Project Navigator:
1. Make sure file filter is set to show all files
2. Search for "NewMoviesView" in the search bar
3. You should see only ONE result

### Issue: "Queries look correct but behavior is wrong"
**Solution**: The app might be using a cached version:
1. Delete app from device/simulator
2. Clean build folder
3. Quit Xcode completely
4. Reopen and rebuild

## Verify Which File Is Active

To know which `NewMoviesView` file Xcode is using:

1. Add a unique debug print to each file
2. Check which one prints in console

In NewMoviesView.swift:
```swift
.navigationTitle("New!")
.onAppear {
    print("Using ORIGINAL NewMoviesView.swift")
}
```

In NewMoviesView 2.swift (if it exists):
```swift
.navigationTitle("New!")
.onAppear {
    print("Using DUPLICATE NewMoviesView 2.swift")
}
```

Run the app, tap "New!" tab, check console to see which prints.

## Nuclear Option: Start Fresh

If nothing works:

1. **Backup your TMDB API key** (from Secrets.plist)
2. Delete the app from device/simulator
3. In Xcode: Product → Clean Build Folder
4. Close Xcode
5. Delete DerivedData folder:
   - Xcode → Settings → Locations
   - Click arrow next to DerivedData path
   - Delete the folder for your project
6. Reopen Xcode
7. Build and run
8. Add API key back
9. Test with fresh data

## Final Checklist

Before declaring it broken, verify:

- [ ] Deleted `NewMoviesView 2.swift` if it exists
- [ ] Cleaned build folder (⇧⌘K)
- [ ] Restarted Xcode completely
- [ ] Deleted all old test data from app
- [ ] Added NEW test data with correct settings
- [ ] Verified queries match the correct code
- [ ] Checked console logs for debug info
- [ ] Tested on clean install

## Quick Reference: Correct Queries

```swift
// NEW! List - Movies you've NEVER seen
@Query(filter: #Predicate<SavedMovie> { movie in
    movie.statusRawValue == "wantToWatch" && movie.hasSeenBefore == false
}, sort: \SavedMovie.dateAdded) private var newMovies: [SavedMovie]

// AGAIN! List - Movies you HAVE seen before
@Query(filter: #Predicate<SavedMovie> { movie in
    movie.statusRawValue == "wantToWatch" && movie.hasSeenBefore == true
}, sort: \SavedMovie.nextRewatchDate) private var watchlistMovies: [SavedMovie]
```

Both must have the `hasSeenBefore` filter for lists to be mutually exclusive!

## If Still Broken

If after all these steps movies STILL appear in both lists:

1. Check if you're using a physical device with old app data
2. Verify the app target is using the right SwiftData model
3. Check if there are any other views loading the same data
4. Share the debug console output showing movie data

The queries ARE correct now. The issue is almost certainly:
- Old cached data
- Duplicate files
- Build cache
- Not actually running the updated code

A clean build + fresh data should fix it! 🎬
