# Director Search Feature ✨

## Overview

Added the ability to search for directors in addition to actors in the Actors tab.

## What Changed

### UI Enhancement
- **Segmented Control** added at the top of Actors tab
- Switch between "Actors" and "Directors" search modes
- Dynamic title and prompts based on selected mode
- Icons for each mode (person for actors, film.stack for directors)

### Search Modes

**Actors Mode:**
- Search for actors by name
- See their filmography
- Add movies they've appeared in

**Directors Mode:**
- Search for directors by name  
- See movies they've directed
- Add movies they've made

## Implementation Details

### New SearchMode Enum

```swift
enum SearchMode: String, CaseIterable {
    case actors = "Actors"
    case directors = "Directors"
    
    var icon: String
    var prompt: String
    var emptyTitle: String
    var emptyDescription: String
}
```

### Features

✅ **Segmented Picker** - Easy switching between modes  
✅ **Dynamic UI** - Title, prompts, and icons change based on mode  
✅ **Clear on Switch** - Results clear when changing modes  
✅ **Same Search API** - Uses TMDB person search (works for both)  
✅ **Visual Distinction** - Director results show "(Director)" in title  

## User Experience

### Flow:

1. Open **Actors** tab
2. See segmented control: `[Actors | Directors]`
3. Select desired mode
4. Search bar placeholder updates
5. Search for a person
6. See their movies
7. Tap to add to watchlist

### Actors Mode Example:
```
Search: "Tom Hanks"
Results: Tom Hanks's movies (as actor)
Title: "Tom Hanks"
```

### Directors Mode Example:
```
Search: "Christopher Nolan"
Results: Christopher Nolan's movies (as director)
Title: "Christopher Nolan (Director)"
```

## Files Modified

✅ **ActorSearchView.swift**
- Added `SearchMode` enum
- Added segmented control picker
- Updated navigation title
- Pass search mode to `ActorMoviesView`
- Dynamic empty states based on mode
- Filter search results by department (acting vs directing)
- Switch API calls based on mode in `loadMovies()`

✅ **TMDBService.swift**
- Added `fetchMoviesByDirector(personId:)` method
- Uses `with_crew` parameter for director credits
- Keeps `fetchMoviesByActor(personId:)` for actor credits

## How It Works

### Segmented Control:
```swift
Picker("Search Mode", selection: $searchMode) {
    ForEach(SearchMode.allCases, id: \.self) { mode in
        Label(mode.rawValue, systemImage: mode.icon)
            .tag(mode)
    }
}
.pickerStyle(.segmented)
```

### Mode-Specific UI:
```swift
.navigationTitle(searchMode == .actors ? "Search by Actor" : "Search by Director")
.searchable(text: $searchText, prompt: searchMode.prompt)
```

### Passing Context:
```swift
ActorMoviesView(actor: actor, searchMode: searchMode)
```

## Technical Notes

### TMDB API & Filtering

**Person Search:**
- Uses `/search/person` endpoint for both modes
- **Actors Mode:** Filters to `known_for_department == "acting"`
- **Directors Mode:** Filters to `known_for_department == "directing"`
- This ensures you only see relevant results for each mode
- Example: Quentin Tarantino appears in Directors, not Actors

**Movie Fetching:**
- **Actors Mode:** Uses `/discover/movie?with_cast={personId}`
  - Gets movies where the person is in the cast
  - Shows their acting filmography
  
- **Directors Mode:** Uses `/discover/movie?with_crew={personId}`
  - Gets movies where the person is in the crew (director)
  - Shows only movies they directed
  - Example: Sergio Leone shows only his directed movies (The Good, the Bad and the Ugly, Once Upon a Time in the West, etc.)

### Why Separate Endpoints Matter
Without using the correct endpoint:
- ❌ Directors would show movies they appeared in as actors
- ❌ Mixed results of directed and acted-in movies
- ❌ Confusing filmography

With correct endpoints:
✅ Actors show only acting credits
✅ Directors show only directing credits
✅ Clean, accurate filmographies
✅ Sergio Leone shows only westerns he directed

### Future Enhancements

**Possible Improvements:**
- Filter results by known_for_department (Acting vs Directing)
- Show person's role(s) in search results
- Combined search showing both acting and directing credits
- Separate lists for "As Actor" vs "As Director"

**Advanced Features:**
- Search by production companies
- Search by cinematographers
- Search by composers
- Multi-role filtering

## Benefits

✅ **More Discovery Options** - Find movies by director  
✅ **Better Organization** - Clear separation of search types  
✅ **Improved UX** - Easy mode switching with segmented control  
✅ **Visual Clarity** - Icons and labels make purpose clear  
✅ **Future-Proof** - Easy to add more search modes  

## Testing

**Test Actors Mode:**
1. Select "Actors"
2. Search for "Leonardo DiCaprio"
3. See his movies as an actor
4. Title shows "Leonardo DiCaprio"

**Test Directors Mode:**
1. Select "Directors"
2. Search for "Steven Spielberg"
3. See his movies as director
4. Title shows "Steven Spielberg (Director)"

**Test Mode Switching:**
1. Search for an actor
2. Switch to Directors mode
3. Results should clear
4. Search again
5. Results should appear for new mode

## Status

✅ **IMPLEMENTED** - Director search now available in Actors tab!

The tab could be renamed to "People" or "Cast & Crew" in the future if desired.

---

**Enhancement #1 from BugsAndImprovements.txt is complete!** 🎬
