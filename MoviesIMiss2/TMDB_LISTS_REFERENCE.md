# TMDB Movie Lists Reference

All available TMDB movie lists and how to use them in your app.

## 📋 Available Movie Lists

### 1. Top Rated (Currently Using)
**Endpoint**: `/movie/top_rated`  
**Method**: `tmdbService.fetchTopRated(page: 1)`  
**Description**: Highest rated movies of all time  
**Examples**: The Shawshank Redemption, The Godfather, Schindler's List  

### 2. Popular
**Endpoint**: `/movie/popular`  
**Method**: `tmdbService.fetchPopular(page: 1)`  
**Description**: Currently trending/popular movies (updated daily)  
**Examples**: Latest blockbusters, trending releases  

### 3. Now Playing
**Endpoint**: `/movie/now_playing`  
**Method**: `tmdbService.fetchNowPlaying(page: 1)`  
**Description**: Movies currently in theaters  
**Examples**: New releases in cinemas  

### 4. Upcoming
**Endpoint**: `/movie/upcoming`  
**Method**: `tmdbService.fetchUpcoming(page: 1)`  
**Description**: Movies coming soon to theaters  
**Examples**: Future releases  

### 5. By Genre
**Endpoint**: `/discover/movie?with_genres={id}`  
**Method**: `tmdbService.fetchByGenre(genreId: 28, page: 1)`  
**Description**: Movies filtered by specific genre  

## 🎭 Genre IDs

| Genre ID | Genre Name          |
|----------|---------------------|
| 28       | Action              |
| 12       | Adventure           |
| 16       | Animation           |
| 35       | Comedy              |
| 80       | Crime               |
| 99       | Documentary         |
| 18       | Drama               |
| 10751    | Family              |
| 14       | Fantasy             |
| 36       | History             |
| 27       | Horror              |
| 10402    | Music               |
| 9648     | Mystery             |
| 10749    | Romance             |
| 878      | Science Fiction     |
| 10770    | TV Movie            |
| 53       | Thriller            |
| 10752    | War                 |
| 37       | Western             |

## 💡 Usage Examples

### Change MovieListView to use Popular movies:

In `MovieListView.swift`, change line ~108:

```swift
// Before:
let movies = try await tmdbService.fetchTopRated(page: page)

// After:
let movies = try await tmdbService.fetchPopular(page: page)
```

### Load Comedy Movies:

```swift
let movies = try await tmdbService.fetchByGenre(genreId: 35, page: 1)
```

### Load Action Movies:

```swift
let movies = try await tmdbService.fetchByGenre(genreId: 28, page: 1)
```

### Mix Multiple Lists:

```swift
// Load first 50 top-rated and 50 popular
var allMovies: [TMDBMovie] = []

for page in 1...2 {
    let topRated = try await tmdbService.fetchTopRated(page: page)
    let popular = try await tmdbService.fetchPopular(page: page)
    allMovies.append(contentsOf: topRated)
    allMovies.append(contentsOf: popular)
}
```

## 🔍 Advanced: Discover API Parameters

The `/discover/movie` endpoint supports many parameters:

```swift
// Example: Action movies from 2020-2023, rating > 7
URLQueryItem(name: "with_genres", value: "28")           // Action
URLQueryItem(name: "primary_release_date.gte", value: "2020-01-01")
URLQueryItem(name: "primary_release_date.lte", value: "2023-12-31")
URLQueryItem(name: "vote_average.gte", value: "7.0")
URLQueryItem(name: "sort_by", value: "popularity.desc")
```

Available parameters:
- `with_genres` - Filter by genre IDs (comma-separated)
- `primary_release_year` - Specific year
- `primary_release_date.gte` - Released after date (YYYY-MM-DD)
- `primary_release_date.lte` - Released before date (YYYY-MM-DD)
- `vote_average.gte` - Minimum rating
- `vote_average.lte` - Maximum rating
- `vote_count.gte` - Minimum number of votes
- `with_original_language` - Language code (e.g., "en", "fr", "ja")
- `sort_by` - Sort order:
  - `popularity.desc` / `popularity.asc`
  - `release_date.desc` / `release_date.asc`
  - `vote_average.desc` / `vote_average.asc`
  - `vote_count.desc` / `vote_count.asc`

## 🎬 Curated List Ideas

### 1. Classic Movies (Before 2000, Highly Rated)
```swift
// Add to TMDBService:
func fetchClassics(page: Int = 1) async throws -> [TMDBMovie] {
    guard let apiKey = apiKey else {
        throw TMDBError.noAPIKey
    }
    
    var components = URLComponents(string: "\(baseURL)/discover/movie")
    components?.queryItems = [
        URLQueryItem(name: "api_key", value: apiKey),
        URLQueryItem(name: "primary_release_date.lte", value: "1999-12-31"),
        URLQueryItem(name: "vote_average.gte", value: "7.5"),
        URLQueryItem(name: "vote_count.gte", value: "1000"),
        URLQueryItem(name: "sort_by", value: "vote_average.desc"),
        URLQueryItem(name: "page", value: "\(page)")
    ]
    
    guard let url = components?.url else {
        throw TMDBError.invalidURL
    }
    
    return try await performRequest(url: url)
}
```

### 2. Hidden Gems (Good ratings, fewer votes)
```swift
func fetchHiddenGems(page: Int = 1) async throws -> [TMDBMovie] {
    // Filter: 7+ rating, 100-1000 votes
    URLQueryItem(name: "vote_average.gte", value: "7.0")
    URLQueryItem(name: "vote_count.gte", value: "100")
    URLQueryItem(name: "vote_count.lte", value: "1000")
}
```

### 3. Recent Critically Acclaimed
```swift
func fetchRecentAcclaimed(page: Int = 1) async throws -> [TMDBMovie] {
    // Last 3 years, 8+ rating
    URLQueryItem(name: "primary_release_date.gte", value: "2021-01-01")
    URLQueryItem(name: "vote_average.gte", value: "8.0")
}
```

## 🚀 Quick Implementation

To switch which list loads on app launch, edit `MovieListView.swift` line ~108:

```swift
// Current (Top Rated):
let movies = try await tmdbService.fetchTopRated(page: page)

// Option 1: Popular
let movies = try await tmdbService.fetchPopular(page: page)

// Option 2: Now Playing
let movies = try await tmdbService.fetchNowPlaying(page: page)

// Option 3: Comedy Movies
let movies = try await tmdbService.fetchByGenre(genreId: 35, page: page)

// Option 4: Action Movies
let movies = try await tmdbService.fetchByGenre(genreId: 28, page: page)
```

That's it! The app will now load your chosen list automatically. 🎉

## 📚 Official TMDB API Documentation

- **API Overview**: https://developers.themoviedb.org/3/getting-started/introduction
- **Movie Lists**: https://developers.themoviedb.org/3/movies
- **Discover**: https://developers.themoviedb.org/3/discover/movie-discover
- **Genres**: https://developers.themoviedb.org/3/genres/get-movie-list
