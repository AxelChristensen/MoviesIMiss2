# Rewatch Reminder in AddMovieSheet

## Overview
The AddMovieSheet now supports setting a rewatch reminder when adding a movie with "Watched" status. This allows you to schedule when you'd like to watch the movie again, right at the moment you're adding it to your collection.

## New Feature

### When Available
The rewatch reminder section appears when:
- You're adding a new movie (from Actor Search, Related Movies, etc.)
- You select "Watched" as the status
- You've already seen the movie before

### How It Works

1. **Set Status to "Watched"**
   - Toggle the segmented control to "Watched"
   - Fill in watch details (mood when watched, approximate watch date)

2. **Set Rewatch Reminder**
   - Tap "Set Reminder" in the "Rewatch Reminder" section
   - Choose from preset intervals:
     - **No Reminder** 🔕 - Don't set a reminder
     - **In 1 Month** 📅 - Watch again in 30 days
     - **In 6 Months** 📅 - Watch again in 6 months
     - **In 1 Year** 📅 - Watch again in 1 year
     - **In 2 Years** 📅 - Watch again in 2 years
     - **Custom Date** 📆 - Pick your own date

3. **Custom Date Picker**
   - If you choose "Custom Date", a date picker appears
   - Select any future date
   - The picker only allows dates from today forward

4. **Clear Reminder**
   - If you set a reminder and change your mind
   - Tap "Clear Reminder" to remove it

## Visual Layout

```
┌─────────────────────────────────────┐
│  Add Movie                          │
├─────────────────────────────────────┤
│  [Poster]  Title                    │
│            Year                     │
│            ⭐ 8.5                   │
│  OVERVIEW                           │
│  Movie description...               │
├─────────────────────────────────────┤
│  Status                             │
│  [ Want to Watch | Watched ] ←      │
├─────────────────────────────────────┤
│  Watch Details                      │
│  Mood when watched: [________]      │
│  Approximate watch date: [______]   │
├─────────────────────────────────────┤
│  Rewatch Reminder               NEW!│
│  Set Reminder >          In 1 Year  │
│  [Clear Reminder]                   │
├─────────────────────────────────────┤
│  Mood Info                          │
│  Mood it helps with: [________]     │
└─────────────────────────────────────┘
```

## Use Cases

### Scenario 1: Just Watched a Great Movie
```
You just discovered a fantastic movie while browsing an actor's 
filmography. You watched it tonight and want to rewatch it next year.

1. Tap the movie to add it
2. Select "Watched" status
3. Fill in "Mood when watched"
4. Set rewatch reminder to "In 1 Year"
5. Add movie

Result: Movie saved with reminder to watch again in 365 days!
```

### Scenario 2: Adding a Comfort Movie
```
You're adding a comfort movie you've seen many times. You know 
you'll want to watch it again when you're feeling stressed.

1. Tap the movie to add it
2. Select "Watched" status
3. Toggle "Seen Before" on
4. Fill in "Mood it helps with: Stress relief"
5. Set rewatch reminder to "In 6 Months"
6. Add movie

Result: Movie added to your collection with a reminder!
```

### Scenario 3: Seasonal Movie
```
You're adding a holiday movie in January. You want to watch it 
again next December.

1. Tap the movie to add it
2. Select "Watched" status
3. Set rewatch reminder to "Custom Date"
4. Choose December 1st
5. Add movie

Result: Movie scheduled for next holiday season!
```

## Features

✅ **Preset Intervals** - Quick options for common rewatch schedules  
✅ **Custom Dates** - Pick any future date you want  
✅ **Visual Feedback** - Shows selected date next to "Set Reminder"  
✅ **Clear Option** - Easy to remove reminder if you change your mind  
✅ **Only for Watched Movies** - Only appears when status is "Watched"  
✅ **Saved Immediately** - Reminder is saved when you tap "Add"  

## Technical Implementation

### New State Variables
```swift
@State private var nextRewatchDate: Date?
@State private var showingCustomDatePicker = false
```

### RewatchInterval Enum
```swift
enum RewatchInterval: String, CaseIterable, Identifiable {
    case none = "No Reminder"
    case oneMonth = "In 1 Month"
    case sixMonths = "In 6 Months"
    case oneYear = "In 1 Year"
    case twoYears = "In 2 Years"
    case custom = "Custom Date"
    
    func calculateDate(from baseDate: Date = Date()) -> Date? {
        // Calculates future date based on interval
    }
}
```

### Save Method Update
```swift
private func saveMovie() {
    let savedMovie = SavedMovie(...)
    
    // Set the rewatch date if one was selected
    if let rewatchDate = nextRewatchDate {
        savedMovie.nextRewatchDate = rewatchDate
    }
    
    modelContext.insert(savedMovie)
    try? modelContext.save()
}
```

## UI Components

### Menu Button
- **Label**: "Set Reminder" with calendar icon
- **Shows**: Current reminder date (or "None")
- **Style**: Standard menu with icons for each option

### Custom Date Picker
- **Type**: Graphical date picker
- **Range**: Today → Future (no past dates)
- **Display**: Only shows when "Custom Date" is selected

### Clear Button
- **Role**: Destructive (red text)
- **Icon**: xmark.circle
- **Visibility**: Only when a reminder is set

## Integration with Existing Features

### Works With:
- ✅ Actor Search → Add movies with reminders
- ✅ Related Movies → Schedule rewatches for similar films
- ✅ All existing mood tracking features
- ✅ Watch history tracking
- ✅ Status management

### Appears In:
- ✅ Rewatch Timeline view (if implemented)
- ✅ "Again!" list (for scheduled rewatches)
- ✅ Movie Detail view (can see/modify reminder after adding)

## Best Practices

### When to Use Each Interval:

**In 1 Month**
- Recently watched, want to see again soon
- Short films or comfort watches
- Testing if you'll enjoy rewatches

**In 6 Months**
- Good movie worth revisiting
- Seasonal content (opposite season)
- Movies with details you might forget

**In 1 Year**
- Great movies that deserve annual rewatches
- Holiday/seasonal movies (same time next year)
- Complex films that benefit from reflection

**In 2 Years**
- Epic movies you love but don't need to see often
- Long franchises you're spacing out
- Movies best with fresh perspective

**Custom Date**
- Specific occasions (birthdays, holidays)
- Movie marathons you're planning
- Watching with specific people/events

## Tips

💡 **Quick Add**: Use preset intervals for fast scheduling  
💡 **Seasonal Movies**: Use custom dates for holiday films  
💡 **Comfort Movies**: Shorter intervals (1-6 months) for rewatches  
💡 **Clear if Needed**: Don't worry about setting it perfectly - you can always change it later in Movie Detail view  
💡 **Batch Planning**: Add multiple movies from an actor/genre and set similar reminders  

## Future Enhancements

Potential improvements:
- Default reminder suggestions based on genre
- "Remind me when feeling [mood]" option
- Integration with calendar/notification system
- Statistics on rewatch frequency
- Automatic reminder suggestions based on watch history

## Notes

- Reminder dates are stored in the `nextRewatchDate` field of `SavedMovie`
- Only available when status is "Watched" (doesn't make sense for "Want to Watch")
- Custom dates must be in the future
- Clearing a reminder sets `nextRewatchDate` to nil
- The reminder integrates with the existing rewatch tracking system
