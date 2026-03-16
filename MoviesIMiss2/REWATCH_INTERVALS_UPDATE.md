# Rewatch Interval Options Update

## New Options Added

Added three new rewatch interval options to give users more flexibility in scheduling when they want to watch movies again.

## Changes Made

### Updated RewatchInterval Enum

Added to both `AddMovieSheet` (ActorSearchView.swift) and `MovieDetailView.swift`:

**New Options:**
1. **Immediately** ⚡ - Watch it right now/today
2. **Next Week** 📅 - In 7 days
3. **Never** ∞ - Don't set a reminder (at end of list)

### Complete Options List (in order)

1. **⚡ Immediately** - Today/now
2. **📅 Next Week** - 7 days from today
3. **📅 In 1 Month** - 30 days
4. **📅 In 6 Months** - 6 months
5. **📅 In 1 Year** - 1 year
6. **📅 In 2 Years** - 2 years
7. **📆 Custom Date** - Pick your own date
8. **∞ Never** - No reminder

## Icon Assignments

| Option | Icon | Meaning |
|--------|------|---------|
| Immediately | `bolt.fill` | Lightning bolt - urgent/now |
| Next Week | `calendar.badge.clock` | Calendar with clock |
| In 1 Month | `calendar.badge.plus` | Calendar with plus |
| In 6 Months | `calendar` | Basic calendar |
| In 1 Year | `calendar.circle` | Calendar circle |
| In 2 Years | `calendar.badge.clock` | Calendar with clock |
| Custom Date | `calendar.badge.exclamationmark` | Calendar with exclamation |
| Never | `infinity` | Infinity symbol |

## Use Cases

### Immediately ⚡
**When to use:**
- Just found a movie you're excited about
- In the mood to watch right now
- Want to add it to "watch tonight" queue
- Movie is perfect for current mood

**Example:**
```
Find "Spider-Man: No Way Home" through actor search:
1. Add with status "Want to Watch"
2. Set rewatch reminder: "Immediately"
3. Movie appears in Again!/New! list with today's date

Result: Ready to watch tonight!
```

### Next Week 📅
**When to use:**
- Want to watch soon, but not today
- Planning weekend movie nights
- Spreading out similar movies
- Giving yourself time to finish current watch

**Example:**
```
Add "The Matrix" to rewatch:
1. Status: "Want to Watch"
2. Seen Before: ON
3. Set reminder: "Next Week"

Result: Scheduled for next weekend!
```

### Never ∞
**When to use:**
- Movie you might rewatch someday, but no specific plan
- Want it in your collection without a reminder
- Don't want notifications/scheduling
- Keeping it for reference

**Example:**
```
Add "The Room" (guilty pleasure):
1. Status: "Want to Watch"
2. Seen Before: ON
3. Set reminder: "Never"

Result: In collection, no scheduled reminder
```

## Technical Implementation

### Date Calculation

```swift
case .immediately:
    return baseDate // Today/now

case .nextWeek:
    return calendar.date(byAdding: .day, value: 7, to: baseDate)

case .never:
    return nil // No reminder
```

### Menu Order

The options appear in chronological order from soonest to latest:
- Immediately (now)
- Next Week (7 days)
- 1 Month
- 6 Months
- 1 Year
- 2 Years
- Custom Date
- Never (last, as it removes the reminder)

## Integration

### Works In:
✅ AddMovieSheet (when adding from Actor/Browse/Related Movies)  
✅ MovieDetailView (when editing existing movies)  
✅ Both "Watched" status and "Seen Before" toggle scenarios  

### Sorting:
- "Immediately" movies appear first in Again! list (earliest date)
- "Never" movies appear last or not at all (no date)
- Movies sorted by `nextRewatchDate`

## User Experience

### Visual Feedback

**Menu displays:**
```
Set Reminder >                    Immediately

Options menu:
⚡ Immediately
📅 Next Week
📅 In 1 Month
📅 In 6 Months
📅 In 1 Year
📅 In 2 Years
📆 Custom Date
∞ Never
```

**After selection:**
```
Set Reminder >                    Mar 15, 2026
(Shows the calculated date)
```

### Clear vs Never

**Clear Reminder button:**
- Removes existing reminder
- Only shows if reminder is already set
- Destructive action (red)

**Never option:**
- Alternative to clearing
- Explicitly states "no reminder"
- Part of the standard menu
- Same result (nil date), different UX

## Examples by Scenario

### Scenario 1: Movie Marathon Planning
```
Planning Marvel marathon starting this weekend:

1. Add "Iron Man" → Immediately
2. Add "Iron Man 2" → Next Week  
3. Add "Thor" → In 1 Month
4. Add "Avengers" → In 6 Months

Result: Staggered viewing schedule!
```

### Scenario 2: Comfort Movie Collection
```
Building comfort movie collection:

1. Add "When Harry Met Sally" → Never
2. Add "The Princess Bride" → Never
3. Add "Amelie" → Never

Result: Available when needed, no pressure
```

### Scenario 3: Seasonal Planning
```
Adding holiday movies in March:

1. Add "Home Alone" → Custom Date (Dec 1)
2. Add "Elf" → Custom Date (Dec 15)
3. Add "It's a Wonderful Life" → Custom Date (Dec 24)

Result: Scheduled for holiday season!
```

### Scenario 4: Quick Rewatch
```
Just watched "Everything Everywhere All at Once" - loved it!

1. Status: "Watched"
2. Fill watch details
3. Set reminder: "Next Week" (want to see it again soon!)

Result: Quick rewatch scheduled
```

## Benefits

### More Granular Control
- **Before**: Shortest option was 1 month
- **After**: Can schedule for today or next week

### Explicit "No Reminder" Option
- **Before**: Had to use "Clear Reminder" button
- **After**: Can select "Never" from menu directly

### Better User Intent
- "Immediately" = urgent, excited
- "Next Week" = soon, but planned
- "Never" = collection item, no schedule

### Complete Spectrum
Now covers:
- ⚡ Urgent (Immediately)
- 📅 Soon (Next Week)
- 📅 Short-term (1-6 months)
- 📅 Long-term (1-2 years)
- 📆 Specific (Custom)
- ∞ No plan (Never)

## Comparison Table

| Time Frame | Old Options | New Options |
|------------|-------------|-------------|
| Right now | ❌ None | ✅ Immediately |
| This week | ❌ None | ✅ Next Week |
| Short term | ✅ 1 Month | ✅ 1 Month |
| Medium term | ✅ 6 Months | ✅ 6 Months |
| Long term | ✅ 1-2 Years | ✅ 1-2 Years |
| Specific | ✅ Custom | ✅ Custom |
| No reminder | ⚠️ Clear button only | ✅ Never option |

## Summary

The rewatch interval options now cover the full spectrum from "watch right now" to "never schedule":

**New additions:**
1. ⚡ **Immediately** - For movies you want to watch today
2. 📅 **Next Week** - For soon-but-not-today scheduling  
3. ∞ **Never** - Explicit "no reminder" option

**Complete list order:**
Immediately → Next Week → 1 Month → 6 Months → 1 Year → 2 Years → Custom → Never

This gives users maximum flexibility in planning their watching schedule! 🎬✨
