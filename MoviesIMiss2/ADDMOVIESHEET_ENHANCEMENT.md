# AddMovieSheet Enhancement

## What Changed

The "Add Movie" sheet now displays the movie's **overview/description** and **rating** to help you make informed decisions when adding movies to your collection.

## New Information Displayed

### Before:
```
┌─────────────────────────────┐
│  Add Movie                  │
├─────────────────────────────┤
│  [Poster]  Title            │
│            Year             │
├─────────────────────────────┤
│  Status                     │
│  [ Want to Watch | Watched ]│
│  ☐ Seen Before              │
└─────────────────────────────┘
```

### After:
```
┌─────────────────────────────┐
│  Add Movie                  │
├─────────────────────────────┤
│  [Poster]  Title            │
│            Year             │
│            ⭐ 7.5           │
│                             │
│  OVERVIEW                   │
│  Full movie description     │
│  appears here so you can    │
│  read what it's about...    │
├─────────────────────────────┤
│  Status                     │
│  [ Want to Watch | Watched ]│
│  ☐ Seen Before              │
└─────────────────────────────┘
```

## What's Included

### ⭐ Rating (if available)
- Shows the TMDB vote average (e.g., "7.5")
- Yellow star icon for visual clarity
- Only appears if the movie has a rating

### 📝 Overview
- Full movie description from TMDB
- Labeled with "OVERVIEW" header
- Helps you decide if you want to add the movie
- Only shows if overview text is available

## Where You'll See This

The enhanced sheet appears when adding movies from:
- ✅ Actor Search → Actor's Movies
- ✅ Related Movies → Similar/Recommended tabs
- ✅ Any other place that uses `AddMovieSheet`

## Benefits

1. **Better Decision Making**: Read the description before adding
2. **See Ratings**: Know if it's highly rated before adding
3. **More Context**: Understand what the movie is about
4. **Informed Watchlist**: Build a better curated collection

## Technical Details

### Changes Made to ActorSearchView.swift

#### Added to the first section:
1. **Rating display** (conditional):
   ```swift
   if let rating = movie.voteAverage, rating > 0 {
       HStack(spacing: 4) {
           Image(systemName: "star.fill")
           Text(String(format: "%.1f", rating))
       }
   }
   ```

2. **Overview section** (conditional):
   ```swift
   if !movie.overview.isEmpty {
       VStack(alignment: .leading, spacing: 4) {
           Text("Overview")
           Text(movie.overview)
       }
   }
   ```

3. **Layout improvements**:
   - Changed HStack alignment to `.top` for better poster/text alignment
   - Added spacing and padding for readability
   - Used proper font sizing and styling

## Example

When adding "The Shawshank Redemption":
- **Title**: The Shawshank Redemption
- **Year**: 1994
- **Rating**: ⭐ 9.3
- **Overview**: "Framed in the 1940s for the double murder of his wife and her lover, upstanding banker Andy Dufresne begins a new life at the Shawshank prison, where he puts his accounting skills to work for an amoral warden. During his long stretch in prison, Dufresne comes to be admired by the other inmates..."

Now you can read this before deciding to add it to your watchlist!

## Notes

- The overview and rating come from the TMDB API
- Some older or less popular movies may not have ratings
- Overview text automatically wraps to fit the available space
- All existing functionality (status, mood tracking, etc.) remains unchanged
