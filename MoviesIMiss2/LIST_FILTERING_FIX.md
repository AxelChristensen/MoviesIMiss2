# List Filtering Fix - New! vs Again!

## Issue Fixed
Movies were appearing in both "New!" and "Again!" lists because the "Again!" list wasn't filtering by `hasSeenBefore`.

## The Problem

### Before Fix:
**New! Query:**
```swift
movie.statusRawValue == "wantToWatch" && movie.hasSeenBefore == false
```
✅ Correct - Only new movies you want to watch

**Again! Query:**
```swift
movie.statusRawValue == "wantToWatch"
```
❌ Wrong - Shows ALL movies you want to watch, including new ones!

### Result:
Movies with:
- Status: "Want to Watch"
- Seen Before: true

Were appearing in **BOTH** lists! ❌

## The Solution

### After Fix:
**New! Query:**
```swift
movie.statusRawValue == "wantToWatch" && movie.hasSeenBefore == false
```
✅ Movies you've NEVER seen before

**Again! Query:**
```swift
movie.statusRawValue == "wantToWatch" && movie.hasSeenBefore == true
```
✅ Movies you HAVE seen before (rewatches)

### Result:
Lists are now **mutually exclusive**! ✅

## Correct List Distribution

### New! Tab ✨
**Purpose**: First-time watches
**Shows**:
- Status = "Want to Watch"
- Seen Before = **false**

**Example**: Movies you discovered and never watched

### Again! Tab 🔄
**Purpose**: Rewatches
**Shows**:
- Status = "Want to Watch"
- Seen Before = **true**

**Example**: Movies you loved before and want to rewatch

## Complete Filtering Logic

| Status | Seen Before | Appears In |
|--------|-------------|------------|
| Want to Watch | false | ✨ New! |
| Want to Watch | true | 🔄 Again! |
| Watched | false | (None - recently watched) |
| Watched | true | (None - recently watched) |

Movies with status "Watched" don't appear in either list because you just watched them. They would need their status changed back to "Want to Watch" to appear again.

## Use Cases Now Working

### Use Case 1: Add New Discovery
```
Find "Inception" through actor search:
1. Add with status "Want to Watch"
2. Keep "Seen Before" OFF (unchecked)

Result: 
✅ Appears in "New!" tab
❌ Does NOT appear in "Again!" tab
```

### Use Case 2: Add Movie to Rewatch
```
Find "The Godfather" (you've seen it before):
1. Add with status "Want to Watch"
2. Toggle "Seen Before" ON (checked)
3. Set rewatch reminder

Result:
❌ Does NOT appear in "New!" tab
✅ Appears in "Again!" tab
```

### Use Case 3: Mark Movie as Watched
```
After watching a movie:
1. Change status to "Watched"
2. Set watch date

Result:
❌ Does NOT appear in "New!" tab
❌ Does NOT appear in "Again!" tab
(It's been watched, not queued)
```

## List Purposes Clarified

### 🔍 Browse
**Purpose**: Discover movies
- Search by name
- Browse curated lists
- Review and decide to add

### 🔄 Again!
**Purpose**: Rewatch queue
- Movies you've seen before
- Want to watch again
- Sorted by rewatch date

### ✨ New!
**Purpose**: First-time watch queue
- Movies you've never seen
- Want to watch for the first time
- Fresh discoveries

### 👤 Actors
**Purpose**: Actor-based discovery
- Find movies by actor
- Add to appropriate list

## Verification Steps

### Test 1: Add New Movie (Never Seen)
```
1. Search for a movie you've never seen
2. Add with "Want to Watch" status
3. Leave "Seen Before" OFF
4. Check tabs:
   - New! → Should appear ✅
   - Again! → Should NOT appear ❌
```

### Test 2: Add Rewatch Movie (Seen Before)
```
1. Search for a movie you've seen
2. Add with "Want to Watch" status
3. Toggle "Seen Before" ON
4. Check tabs:
   - New! → Should NOT appear ❌
   - Again! → Should appear ✅
```

### Test 3: Mark as Watched
```
1. Find any movie in New! or Again!
2. Open it and change status to "Watched"
3. Check tabs:
   - New! → Should NOT appear ❌
   - Again! → Should NOT appear ❌
```

## Why This Matters

### Before Fix: Confusion
- Same movies in multiple lists
- Unclear which list to use
- Duplicate content everywhere
- "New!" and "Again!" meant the same thing

### After Fix: Clarity
- Each movie in ONE list
- Clear separation of purpose
- "New!" = never seen
- "Again!" = want to rewatch
- No duplicates, no confusion

## Complete App Flow

### Discovery → Decision → Queue

**Discovery** (Browse/Actors):
↓
**Decision** (Add with correct settings):
- Never seen? → "Want to Watch" + Seen Before OFF
- Want to rewatch? → "Want to Watch" + Seen Before ON
- Just watched? → "Watched" + Fill details

↓
**Queue** (Automatic):
- New movie → Goes to "New!" ✨
- Rewatch → Goes to "Again!" 🔄
- Watched → Not queued (already done)

## Summary

The fix ensures:
1. ✅ "New!" shows only movies you've **never seen**
2. ✅ "Again!" shows only movies you've **seen before**
3. ✅ No movie appears in both lists
4. ✅ Clear, logical organization
5. ✅ Mutually exclusive categories

### Changed Code:
```swift
// AgainListView.swift - Line 18
@Query(filter: #Predicate<SavedMovie> { movie in
    movie.statusRawValue == "wantToWatch" && movie.hasSeenBefore == true
}, sort: \SavedMovie.nextRewatchDate) private var watchlistMovies: [SavedMovie]
```

Added `&& movie.hasSeenBefore == true` to the Again! list query.

Now your lists work exactly as intended! 🎬✨
