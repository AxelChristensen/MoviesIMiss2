# Fixed: Vibe Picker Missing in MovieDecisionView

## Problem Found
When adding movies from the **Browse tab's curated list** (not search results), you saw `MovieDecisionView` which was missing the vibe picker. It only asked about rewatch timing.

## Solution
Added the vibe picker (`VibePicker` component) to `MovieDecisionView` so it appears when "Have you seen this before?" is set to "Yes".

## Files Modified

### MovieDecisionView.swift

#### 1. Added State Variables
```swift
// Vibe fields
@State private var selectedVibe: String?
@State private var vibeNotes: String = ""
```

#### 2. Added VibePicker to UI (when hasSeenBefore = true)
```swift
if hasSeenBefore {
    VStack(alignment: .leading, spacing: 16) {
        // Vibe picker - NEW!
        VStack(alignment: .leading, spacing: 12) {
            Text("What's the vibe? ✨")
                .font(.headline)
                .padding(.horizontal)
            
            VibePicker(selectedVibe: $selectedVibe, vibeNotes: $vibeNotes)
                .padding(.horizontal)
        }
        
        // When to watch again selector
        // ... rest of the form
    }
}
```

#### 3. Updated Save Function
```swift
private func saveMovieWithStatus(_ status: MovieStatus) {
    movie.status = status
    
    if hasSeenBefore {
        movie.hasSeenBefore = true
        movie.lastWatched = Date()
        movie.moodWhenWatched = moodWhenWatched.isEmpty ? nil : moodWhenWatched
        movie.moodItHelpsWithString = moodItHelpsWithString.isEmpty ? nil : moodItHelpsWithString
        
        // Save vibe data - NEW!
        movie.personalVibe = selectedVibe
        movie.vibeNotes = vibeNotes.isEmpty ? nil : vibeNotes
        
        // Set next rewatch date if selected
        if let interval = selectedRewatchInterval {
            movie.nextRewatchDate = interval.calculateDate(from: Date())
        }
    }
    
    try? modelContext.save()
    dismiss()
}
```

## User Flow Now

### Adding Movie from Browse Curated List

**Before Fix:**
```
1. Tap movie from Browse list
2. See MovieDecisionView
3. Toggle "Have you seen this before?" → Yes
4. See: "When do you want to watch it again?"
5. ❌ NO vibe picker visible
6. Select rewatch interval
7. Movie saved without vibe
```

**After Fix:**
```
1. Tap movie from Browse list
2. See MovieDecisionView
3. Toggle "Have you seen this before?" → Yes
4. ✅ See vibe picker: "What's the vibe? ✨"
5. Select vibe (e.g., "Cozy 🔥")
6. (Optional) Add vibe notes
7. See: "When do you want to watch it again?"
8. Select rewatch interval
9. Movie saved WITH vibe!
```

## Now Vibe Picker Appears in ALL Add Flows

### 1. Browse Search Results → AddMovieSheet
- ✅ Vibe picker always visible

### 2. Browse Curated List → MovieDecisionView
- ✅ Vibe picker visible when "seen before" = Yes

### 3. Actor Search → AddMovieSheet
- ✅ Vibe picker always visible

### 4. Related Movies → AddMovieSheet
- ✅ Vibe picker always visible

## Visual Comparison

### BEFORE (Missing Vibe Picker)
```
┌─────────────────────────────────────┐
│  Review Movie                       │
├─────────────────────────────────────┤
│  [Movie Poster]                     │
│  The Grand Budapest Hotel           │
│  2014                               │
│  Overview text...                   │
├─────────────────────────────────────┤
│  Have you seen this before?         │
│  [Yes]  ← Selected                  │
├─────────────────────────────────────┤
│  When do you want to watch it again?│ ← Jumped straight here
│  [ ] In 1 Month                     │
│  [ ] In 6 Months                    │
│  [ ] In 1 Year                      │
│  [ ] In 2 Years                     │
│                                     │
│  What mood were you in?             │
│  [Text field]                       │
│                                     │
│  What mood does it help with?       │
│  [Text field]                       │
├─────────────────────────────────────┤
│  [Add to My Watchlist]              │
│  [Snooze for Later]                 │
│  [Remove from List]                 │
└─────────────────────────────────────┘

❌ No vibe picker!
```

### AFTER (With Vibe Picker)
```
┌─────────────────────────────────────┐
│  Review Movie                       │
├─────────────────────────────────────┤
│  [Movie Poster]                     │
│  The Grand Budapest Hotel           │
│  2014                               │
│  Overview text...                   │
├─────────────────────────────────────┤
│  Have you seen this before?         │
│  [Yes]  ← Selected                  │
├─────────────────────────────────────┤
│  What's the vibe? ✨                │ ← NEW!
│  Pick the feeling...                │
│  ┌─────┐ ┌─────┐ ┌─────┐          │
│  │ 🔥  │ │ ⚡  │ │ 💚  │          │
│  │Cozy │ │Intn.│ │Uplf.│          │
│  └─────┘ └─────┘ └─────┘          │
│  ... (all 10 vibes)                │
│                                     │
│  Add a note (optional)              │
│  [Text field if vibe selected]     │
├─────────────────────────────────────┤
│  When do you want to watch it again?│
│  [ ] In 1 Month                     │
│  [✓] In 6 Months                    │
│  [ ] In 1 Year                      │
│  [ ] In 2 Years                     │
│                                     │
│  What mood were you in?             │
│  [Text field]                       │
│                                     │
│  What mood does it help with?       │
│  [Text field]                       │
├─────────────────────────────────────┤
│  [Add to My Watchlist]              │
│  [Snooze for Later]                 │
│  [Remove from List]                 │
└─────────────────────────────────────┘

✅ Vibe picker now visible!
```

## Testing

### Test 1: Browse Curated List
1. Go to **Browse** tab
2. Tap any movie from the **list** (not search)
3. Toggle "Have you seen this before?" → **Yes**
4. **Should see vibe picker!** ✅
5. Select a vibe (e.g., "Cozy")
6. Select rewatch interval
7. Tap "Add to My Watchlist"
8. Check **Again!** tab → movie has vibe badge

### Test 2: Browse Search Results
1. Go to **Browse** tab
2. **Search** for a movie (e.g., "inception")
3. Tap a search result
4. **Should see vibe picker immediately!** ✅
5. Select a vibe
6. Add movie
7. Check tabs → movie has vibe badge

### Test 3: Actor Search
1. Go to **Actors** tab
2. Search for an actor
3. Tap a movie
4. **Should see vibe picker immediately!** ✅
5. Select a vibe
6. Add movie
7. Check tabs → movie has vibe badge

## Key Differences Between Two Add Flows

| Feature | AddMovieSheet | MovieDecisionView |
|---------|---------------|-------------------|
| **Used For** | Search results (Browse, Actor, Related) | Curated Browse list |
| **Toggle** | "I've seen this before" | "Have you seen this before?" |
| **Vibe Picker** | Always visible | Visible when "seen before" = Yes |
| **Action Buttons** | Cancel / Add | Add / Snooze / Remove |
| **Style** | Form-based | Scrollable card-based |

## What's Consistent Now

✅ **All add flows have vibe picker**  
✅ **Same VibePicker component used everywhere**  
✅ **Same data saved to SavedMovie model**  
✅ **Vibe filtering works across all sources**  

## Why It Was Missing

`MovieDecisionView` was created separately from `AddMovieSheet` for the Browse curated list. When vibes were added to `AddMovieSheet`, they weren't added to `MovieDecisionView`, causing the inconsistency.

Now both sheets have the full vibe functionality!

## Status

✅ **FIXED** - Vibe picker now appears in MovieDecisionView

**To test:**
1. Clean build (⇧⌘K)
2. Build (⌘B)
3. Run app
4. Add movie from Browse curated list
5. Toggle "seen before" → Yes
6. Vibe picker appears! 🎬✨
