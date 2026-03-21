# Build Error Troubleshooting

## Common Build Errors & Solutions

### Error 1: "Cannot find 'CachedAsyncImage' in scope"

**Cause:** ImageCache.swift not added to Xcode target

**Fix:**
1. Find `ImageCache.swift` in Finder
2. Drag it into Xcode Project Navigator
3. Make sure "Copy items if needed" is checked
4. Make sure your target is checked
5. Click "Finish"

**OR create manually:**
```
1. Right-click project folder → New File → Swift File
2. Name: ImageCache.swift
3. Copy contents from the ImageCache.swift file
4. Save
```

---

### Error 2: "Cannot assign to value: 'movies' is a 'let' constant"

**Cause:** Variable declared as `let` instead of `var`

**Fix:**
In `MovieListView.swift`, find line with `let movies: [TMDBMovie]` and change to:
```swift
var movies: [TMDBMovie]
```

---

### Error 3: "Cannot find type 'PlatformImage' in scope"

**Cause:** ImageCache.swift has compilation issues

**Fix:**
Make sure ImageCache.swift starts with:
```swift
import SwiftUI

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif
```

---

### Error 4: "Value of type 'SavedMovie' has no member 'id'"

**Cause:** SavedMovie doesn't conform to Identifiable

**Fix:**
This is actually referring to `tmdbMovie.id`. Make sure your TMDBMovie struct exists.

---

### Error 5: Circular dependency or "type checking too complex"

**Cause:** SwiftUI views too nested or complex

**Fix:**
Clean build folder:
```
Product → Clean Build Folder (⇧⌘K)
```
Then rebuild.

---

## Step-by-Step Build Fix Process

### Step 1: Clean Everything
```
1. Product → Clean Build Folder (⇧⌘K)
2. Close Xcode
3. Delete DerivedData:
   - Finder → Go → Go to Folder
   - Paste: ~/Library/Developer/Xcode/DerivedData
   - Delete the folder for your project
4. Reopen Xcode
```

### Step 2: Verify Files Exist

Check these files are in your project:
- [ ] ImageCache.swift
- [ ] MovieListView.swift (updated)
- [ ] NewMoviesView.swift (updated)
- [ ] AgainListView.swift (updated)
- [ ] ActorSearchView.swift (updated)
- [ ] MovieStatus.swift
- [ ] SavedMovie.swift

### Step 3: Check Target Membership

For each file above:
1. Select file in Project Navigator
2. Open File Inspector (⌥⌘1)
3. Under "Target Membership"
4. Make sure "MoviesIMiss2" is checked

### Step 4: Verify Imports

Make sure these imports exist where needed:

**ImageCache.swift:**
```swift
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
```

**MovieListView.swift:**
```swift
import SwiftUI
import SwiftData
```

**NewMoviesView.swift:**
```swift
import SwiftUI
import SwiftData
```

### Step 5: Build Incrementally

Try building in stages:
```
1. Comment out ALL CachedAsyncImage usage
2. Build → Should succeed
3. Uncomment one file at a time
4. Build after each
5. Find which file causes the error
```

---

## Manual Fix: Revert Changes

If nothing works, revert the lazy loading changes:

### In MovieListView.swift:

**Remove these state variables:**
```swift
@State private var currentPage = 1
@State private var isLoadingMore = false
@State private var hasMorePages = true
private let maxPages = 10
```

**Revert loadCuratedMovies() to:**
```swift
private func loadCuratedMovies() async {
    isLoadingCuratedList = true
    errorMessage = nil
    
    do {
        // Clear existing pending movies
        let descriptor = FetchDescriptor<SavedMovie>(
            predicate: #Predicate { $0.statusRawValue == "pending" }
        )
        let existingPending = try modelContext.fetch(descriptor)
        for movie in existingPending {
            modelContext.delete(movie)
        }
        
        // Fetch all existing movies
        let allMoviesDescriptor = FetchDescriptor<SavedMovie>()
        let allExistingMovies = try modelContext.fetch(allMoviesDescriptor)
        let existingTmdbIds = Set(allExistingMovies.map { $0.tmdbId })
        
        // Load 5 pages
        var allMovies: [TMDBMovie] = []
        for page in 1...5 {
            let movies = try await tmdbService.fetchTopRated(page: page)
            allMovies.append(contentsOf: movies)
        }
        
        // Add to database
        for tmdbMovie in allMovies {
            guard !existingTmdbIds.contains(tmdbMovie.id) else {
                continue
            }
            
            let savedMovie = SavedMovie(
                tmdbId: tmdbMovie.id,
                title: tmdbMovie.title,
                year: tmdbMovie.year,
                overview: tmdbMovie.overview,
                posterPath: tmdbMovie.posterPath,
                status: .pending
            )
            modelContext.insert(savedMovie)
        }
        
        try modelContext.save()
    } catch {
        errorMessage = "Failed to load movies: \(error.localizedDescription)"
    }
    
    isLoadingCuratedList = false
}
```

**Remove these functions:**
```swift
// Delete loadMoreMoviesIfNeeded()
// Delete loadNextPage()
// Delete loadMoviesPage()
```

**Revert moviesList to:**
```swift
private var moviesList: some View {
    List {
        ForEach(pendingMovies) { movie in
            MovieRowView(movie: movie)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedMovie = movie
                }
        }
    }
}
```

---

## Still Not Working?

### Share These Details:

1. **Exact error message** (copy/paste from Xcode)
2. **Which file** the error is in
3. **Line number** of the error
4. **Error type** (red circle, yellow triangle, etc.)
5. **iOS version** you're targeting

---

## Quick Diagnostic Commands

In Xcode's Issue Navigator (⌘5), check:
- How many errors?
- Are they all in one file?
- Are they related to types or syntax?

**Screenshot the error and share it with me** for specific help!

---

## Last Resort: Start Fresh

1. Create a new branch in git
2. Revert all recent changes
3. Apply changes one file at a time
4. Build after each file
5. Identify the problematic change

---

Let me know the specific error and I'll give you the exact fix! 🔧
