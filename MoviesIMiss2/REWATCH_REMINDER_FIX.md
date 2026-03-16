# Rewatch Reminder - "Seen Before" Fix

## Issue Fixed
The rewatch reminder section was only appearing when status was set to "Watched", but it should also appear when the "Seen Before" toggle is enabled, regardless of the status.

## The Problem

### Before:
```
Status: Want to Watch
☑ Seen Before

→ No rewatch reminder option shown ❌
```

This didn't make sense because if you've seen a movie before, you might want to watch it again!

## The Solution

### After:
```
Status: Want to Watch
☑ Seen Before

→ Rewatch reminder section appears! ✅
```

The rewatch reminder now appears in **either** of these scenarios:
1. Status is set to "Watched" 
2. "Seen Before" toggle is enabled

## Updated Logic

### Old Code:
```swift
if selectedStatus == .watched {
    Section("Watch Details") { ... }
    Section("Rewatch Reminder") { ... }
}
```

### New Code:
```swift
if selectedStatus == .watched || hasSeenBefore {
    if selectedStatus == .watched {
        Section("Watch Details") { ... }
    }
    
    Section("Rewatch Reminder") { ... }
}
```

## Use Cases Now Supported

### Scenario 1: Want to Watch + Seen Before
```
You loved a movie years ago and want to add it to rewatch:

1. Find the movie through actor search
2. Keep status as "Want to Watch" 
3. Toggle "Seen Before" ON
4. Rewatch Reminder section appears! ✅
5. Set reminder to "In 6 Months"
6. Add movie

Result: Movie added with reminder, even though you haven't 
watched it yet (in this session)
```

### Scenario 2: Watched + Current Session
```
You just watched a movie tonight:

1. Find the movie
2. Set status to "Watched"
3. Fill in watch details
4. Set rewatch reminder
5. Add movie

Result: Same as before, still works! ✅
```

### Scenario 3: Want to Watch + Seen Before + Future Plans
```
Adding a holiday classic in summer:

1. Find "Home Alone"
2. Status: "Want to Watch" (planning to watch at Christmas)
3. Toggle "Seen Before" (you've seen it many times)
4. Set rewatch reminder: Custom Date → December 15
5. Add "Mood it helps with: Holiday spirit"
6. Add movie

Result: Holiday movie scheduled for the right time! ✅
```

## Benefits

### More Flexible Workflow
- Don't need to mark as "Watched" just to set a reminder
- Better for movies you've seen in the past but haven't watched recently
- Matches real-world use cases better

### Clearer Intent
- "Want to Watch" can mean "want to watch AGAIN"
- "Seen Before" indicates familiarity
- Rewatch reminder indicates planning

### Better Organization
- Movies you've seen before can be scheduled properly
- No need to fake the status just to set a reminder
- More honest data in your collection

## Section Visibility Logic

| Status | Seen Before | Watch Details | Rewatch Reminder |
|--------|-------------|---------------|------------------|
| Want to Watch | ❌ No | ❌ Hidden | ❌ Hidden |
| Want to Watch | ✅ Yes | ❌ Hidden | ✅ Shown |
| Watched | ❌ No | ✅ Shown | ✅ Shown |
| Watched | ✅ Yes | ✅ Shown | ✅ Shown |

## Implementation Details

### Outer Condition
```swift
if selectedStatus == .watched || hasSeenBefore {
    // Show relevant sections
}
```

This shows rewatch-related sections when either:
- The movie is marked as watched in this session, OR
- The user has seen it before at some point

### Inner Condition
```swift
if selectedStatus == .watched {
    Section("Watch Details") { ... }
}
```

Watch details (mood when watched, approximate date) only appear if you're marking it as watched RIGHT NOW, since those are about the current watch session.

### Rewatch Reminder
```swift
Section("Rewatch Reminder") { ... }
```

This appears outside the inner condition, so it shows whenever the outer condition is true (watched OR seen before).

## Examples

### Example 1: Classic You Want to Rewatch
```
Movie: The Godfather
Status: Want to Watch
Seen Before: ✅ Yes

Sections shown:
✅ Status
✅ Rewatch Reminder  ← Now appears!
✅ Mood Info

NOT shown:
❌ Watch Details (you didn't just watch it)
```

### Example 2: Just Watched Tonight
```
Movie: Dune: Part Two
Status: Watched
Seen Before: ❌ No

Sections shown:
✅ Status
✅ Watch Details  ← For tonight's viewing
✅ Rewatch Reminder  ← Schedule next watch
✅ Mood Info
```

### Example 3: Rewatched an Old Favorite
```
Movie: The Princess Bride
Status: Watched
Seen Before: ✅ Yes

Sections shown:
✅ Status
✅ Watch Details  ← For tonight's rewatch
✅ Rewatch Reminder  ← Schedule next rewatch
✅ Mood Info
```

## Why This Makes Sense

### Real-World Use Case
When browsing Tom Hanks movies, you find "Forrest Gump":
- You saw it years ago (Seen Before ✅)
- You want to watch it again (Want to Watch)
- You want to schedule it for next month

**Before the fix**: You'd have to mark it as "Watched" just to set a reminder, which is confusing.

**After the fix**: You can honestly mark it as "Want to Watch", toggle "Seen Before", and set your reminder!

## Summary

This fix makes the AddMovieSheet more intuitive and flexible:

✅ **Before**: Rewatch reminders only for status = "Watched"  
✅ **After**: Rewatch reminders for "Watched" OR "Seen Before"  

✅ **Before**: Confusing to add movies you want to rewatch  
✅ **After**: Clear workflow for all scenarios  

✅ **Before**: Had to fake status to set reminders  
✅ **After**: Honest data, accurate planning  

The sheet now matches how you actually think about movies:
- "I've seen this before" → Toggle Seen Before
- "I want to watch it again" → Keep Want to Watch
- "I want to watch it in 6 months" → Set reminder

All three can be true at once! 🎬✨
