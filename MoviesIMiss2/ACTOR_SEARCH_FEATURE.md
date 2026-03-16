# Actor Search Feature

## Overview
The Actor Search feature allows users to search for movies by actor name. This is a powerful way to discover movies featuring your favorite actors and add them to your watchlist.

## Files Created

### 1. ActorSearchView.swift
Main UI for the actor search feature:
- **ActorSearchView**: Search interface with searchable modifier
- **ActorRow**: Displays individual actor in search results
- **ActorMoviesView**: Shows all movies for a selected actor
- **MovieCard**: Displays movie information in a card format
- **AddMovieSheet**: Modal sheet for adding a movie to your collection

## Files Modified

### 1. TMDBModels.swift
Added data models for actor/person-related TMDB API responses:
- `TMDBPersonResponse`: Response wrapper for person search
- `TMDBPerson`: Individual actor/person data (now conforms to `Hashable`)
- `TMDBKnownForMovie`: Movies an actor is known for
- `TMDBMovieCreditsResponse`: Cast and crew for a specific movie
- `TMDBCastMember`: Individual cast member
- `TMDBCrewMember`: Individual crew member
- `TMDBProfileImageSize`: Enum for profile image sizes
- `TMDBMovie`: Updated to conform to `Hashable`

### 2. TMDBService.swift
Added three new methods for actor-related API calls:
- `searchPeople(query:)`: Search for actors by name
- `fetchMoviesByActor(personId:page:)`: Get all movies featuring a specific actor
- `fetchMovieCredits(movieId:)`: Get cast and crew for a specific movie

### 3. ContentView.swift
Added a new tab for "Actors" in the main TabView with the system icon "person.fill.viewfinder"

### 4. MovieStatus.swift
Added `.watched` case to the MovieStatus enum to support marking movies as watched when adding from actor search

## Features

### Search for Actors
1. Navigate to the "Actors" tab
2. Type an actor's name in the search bar
3. See matching actors with their profile pictures
4. View movies they're known for under their name

### Browse Actor's Movies
1. Tap on an actor from the search results
2. View all their movies sorted by popularity
3. See movie posters, titles, years, and ratings
4. Scroll through their complete filmography

### Add Movies from Actor Search
1. Tap on any movie in an actor's filmography
2. Choose whether you want to watch it or have already watched it
3. Mark if you've seen it before
4. Add mood information
5. Set approximate watch date (for watched movies)
6. Movie is saved to your collection

## User Flow

```
Actors Tab → Search Actor → Actor Movies → Add to Watchlist
                                          → Add as Watched
```

## API Usage

The feature uses these TMDB API endpoints:
- `/search/person` - Search for actors/people
- `/discover/movie?with_cast={personId}` - Get movies by actor
- `/movie/{movieId}/credits` - Get cast/crew (for future features)

## Design Decisions

1. **Filter to Actors Only**: The search filters results to only show people known for acting, excluding directors, producers, etc.

2. **Debounced Search**: 300ms delay prevents excessive API calls while typing

3. **Movies Sorted by Popularity**: Actor's movies are sorted by popularity to show their most well-known work first

4. **Profile Images**: Uses circular profile images for actors following common design patterns

5. **Known For Preview**: Shows 2 movies the actor is known for in search results

## Future Enhancements

Potential improvements to consider:
- Add ability to filter actor's movies by genre or year
- Show actor's biographical information
- Display character names in movie credits
- Filter by movies already in your collection
- Sort options (by year, rating, title)
- Pagination for actors with extensive filmographies
- Cache actor profile images

## Integration Notes

- The feature seamlessly integrates with existing movie management
- Movies added through actor search appear in appropriate views (Watchlist, New!, etc.)
- All existing mood tracking and status features work with actor-discovered movies
- Uses the same `SavedMovie` SwiftData model as the rest of the app

## Error Handling

The feature includes proper error handling for:
- Missing API key
- Network errors
- Empty search results
- API response parsing errors
- Invalid URLs

All errors display user-friendly messages using `ContentUnavailableView`.
