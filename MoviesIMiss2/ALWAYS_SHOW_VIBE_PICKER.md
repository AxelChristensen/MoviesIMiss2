# Always Show Vibe Picker in AddMovieSheet

## Change Summary

Modified `AddMovieSheet` to **always show the vibe picker**, regardless of whether "I've seen this before" is toggled.

## What Changed

### Before
```swift
// Vibe picker only showed when hasSeenBefore = true
if hasSeenBefore {
    vibeSection
    rewatchReminderSection
}
```

### After
```swift
// Vibe picker ALWAYS shows
vibeSection

// Only rewatch reminder requires hasSeenBefore = true
if hasSeenBefore {
    rewatchReminderSection
}
```

## User Experience

### OLD Flow (Conditional Vibe Picker)
```
1. Tap movie to add
2. See AddMovieSheet
3. Toggle "I've seen this before" → ON
4. Vibe picker appears ← Extra step!
5. Select vibe
6. Set rewatch reminder
7. Add movie
```

### NEW Flow (Always Visible)
```
1. Tap movie to add
2. See AddMovieSheet
3. Vibe picker is already visible! ← No extra step
4. Select vibe immediately
5. (Optional) Toggle "I've seen this before" for rewatch reminder
6. Add movie
```

## Benefits

✅ **Immediate Access** - Vibe picker visible right away  
✅ **Consistent UI** - Same fields visible every time  
✅ **Less Friction** - No need to toggle to see vibe options  
✅ **Better for Discovery** - Can tag movies you haven't seen yet  
✅ **Flexible** - Tag "want to watch" movies with expected vibes  

## New Use Cases

### Tag Movies You WANT to Watch
```
Before: Could only tag movies you'd seen
Now: Can tag movies with EXPECTED vibes!

Example:
1. Search for "Paddington"
2. See vibe picker
3. Tag as "Fun ⭐" (you expect it to be fun)
4. Add as "Want to Watch"
5. When you watch it, you can confirm/change the vibe!
```

### Organize Your Watchlist by Mood
```
Build themed watchlists:

1. Add "The Grand Budapest Hotel"
   → Tag as "Cozy 🔥"
   → "Want to Watch"

2. Add "Mad Max: Fury Road"
   → Tag as "Intense ⚡"
   → "Want to Watch"

3. Add "Paddington"
   → Tag as "Fun ⭐"
   → "Want to Watch"

Result: Watchlist organized by expected vibes!
```

## Form Structure Now

```
┌─────────────────────────────────────┐
│  Add Movie                          │
├─────────────────────────────────────┤
│  Movie Information                  │
│  [Poster] [Title, Year, Rating]     │
│  [Overview]                         │
├─────────────────────────────────────┤
│  ☐ I've seen this before            │
├─────────────────────────────────────┤
│  What's the vibe? ✨                │ ← ALWAYS VISIBLE
│  Pick the feeling...                │
│  [Grid of vibe buttons]             │
│  [Optional notes field]             │
├─────────────────────────────────────┤
│  Rewatch Reminder                   │ ← Only if seen before
│  (only when toggled)                │
├─────────────────────────────────────┤
│  Mood it helps with                 │
│  [Text field]                       │
├─────────────────────────────────────┤
│       [Cancel]      [Add]           │
└─────────────────────────────────────┘
```

## Logical Flow

### For Movies You've Seen
```
1. Movie info
2. Toggle "I've seen this before" ✓
3. Pick vibe (how it made you feel)
4. Set rewatch reminder
5. Add mood it helps with
```

### For Movies You Want to Watch
```
1. Movie info
2. Keep "I've seen this before" unchecked
3. Pick vibe (how you expect it to feel)
4. Add mood you hope it helps with
5. No rewatch reminder (haven't seen it yet)
```

## Files Modified

✅ **ActorSearchView.swift** - Modified `AddMovieSheet.body`
  - Moved `vibeSection` outside the `if hasSeenBefore` condition
  - Kept `rewatchReminderSection` inside the condition

## Testing

### Test 1: Add Unseen Movie with Vibe
```
1. Browse or Actor search for a movie
2. Tap to add
3. DON'T toggle "I've seen this before"
4. Vibe picker should be visible
5. Select a vibe (e.g., "Fun")
6. Add movie
7. Check New! tab → movie should have vibe badge
```

### Test 2: Add Seen Movie with Vibe
```
1. Search for a movie
2. Tap to add
3. Toggle "I've seen this before" ✓
4. Vibe picker visible
5. Select vibe
6. Rewatch reminder section appears
7. Set reminder
8. Add movie
9. Check Again! tab → movie has vibe badge + rewatch date
```

### Test 3: Vibe Filter Cross-Reference
```
1. Add "Inception" with "Intense" vibe (not seen)
2. Go to Browse tab
3. Search "inception"
4. Tap "Intense" filter
5. Should show Inception in results!
6. Confirms filtering works for unseen movies too
```

## Expected Behavior

### Vibe Tagging
- ✅ Can tag "Want to Watch" movies
- ✅ Can tag "Watched" movies
- ✅ Vibe optional (can skip if desired)
- ✅ Can change vibe later (in movie detail)

### Rewatch Reminders
- ✅ Only available for "I've seen this before"
- ✅ Not shown for "Want to Watch" movies
- ✅ Logical: can't rewatch what you haven't watched

### Filtering
- ✅ Browse vibe filter includes all saved movies
- ✅ Again! vibe filter includes rewatch movies
- ✅ Both work with this change

## Philosophy

### Previous Design
- Vibes tied to movies you've **already seen**
- Vibe = memory of how it made you feel
- Rewatch reminder + vibe go together

### New Design
- Vibes for **all movies** (seen and unseen)
- Vibe = how it made you feel OR how you expect it to feel
- Organize watchlist by mood
- More flexible and proactive

## User Stories

### Story 1: Mood-Based Watchlist Planning
```
"I want to build a cozy movie watchlist for winter"

Actions:
1. Search for cozy-looking movies
2. Add each with "Cozy 🔥" vibe
3. Keep as "Want to Watch"
4. When winter comes, filter by "Cozy"
5. Perfect queue ready!
```

### Story 2: Genre-Mood Matching
```
"I know this horror movie will be intense"

Actions:
1. Add "Hereditary"
2. Tag with "Intense ⚡"
3. Tag with "Dark 🌙"
4. Add to "Want to Watch"
5. When feeling brave, find it via vibe filter
```

### Story 3: Friend Recommendations
```
"My friend said this is super uplifting"

Actions:
1. Add recommended movie
2. Tag with "Uplifting 💚"
3. Add note: "Sarah recommended"
4. Watch later
5. Confirm or change vibe after watching
```

## Design Rationale

### Why Always Show?

**Reduces Friction**
- No need to toggle to see vibes
- Faster to tag movies
- Cleaner workflow

**Enables New Workflows**
- Pre-tag expected vibes
- Organize "Want to Watch" by mood
- Plan themed movie nights

**Consistent UI**
- Same fields always visible
- Predictable form structure
- Less cognitive load

**Better Discovery**
- Tag movies before watching
- Build mood-based queues
- Proactive organization

### Why Keep Rewatch Reminder Conditional?

**Logical Consistency**
- Can't "rewatch" something you haven't watched
- Reminder only makes sense after first viewing
- Clear separation of concerns

**Simpler Form for New Movies**
- Less clutter for "Want to Watch"
- Focus on vibe + mood expectation
- Cleaner experience

## Backwards Compatibility

✅ **Existing movies unaffected** - Already saved vibes remain  
✅ **Filter logic unchanged** - All filters still work  
✅ **Data model unchanged** - Same `personalVibe` field  
✅ **No migration needed** - Purely UI change  

## Status

✅ **IMPLEMENTED** - Vibe picker now always visible in AddMovieSheet

Build and test:
1. Add movies from Browse or Actor search
2. Vibe picker appears immediately
3. No need to toggle anything
4. More flexible and user-friendly!

---

**Now you can tag movies with vibes whether you've seen them or not!** 🎬✨
