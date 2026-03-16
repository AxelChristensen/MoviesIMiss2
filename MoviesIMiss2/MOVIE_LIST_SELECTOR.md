# Movie List Selector Feature

## ✨ What's New

Added a dropdown menu in the MovieListView toolbar that lets you choose which TMDB movie list to load!

## 📋 Available Lists

1. **⭐ Top Rated** - Highest rated movies of all time
2. **🔥 Popular** - Currently trending movies (updated daily)
3. **🎬 Now Playing** - Movies currently in theaters
4. **📅 Upcoming** - Movies coming soon
5. **⚡ Action** - Action genre movies
6. **😄 Comedy** - Comedy genre movies
7. **🎭 Drama** - Drama genre movies
8. **🌙 Horror** - Horror genre movies
9. **✨ Sci-Fi** - Science Fiction movies
10. **❤️ Romance** - Romance movies

## 🎯 How to Use

### In the App:

1. Open the **Review** tab
2. Tap the **dropdown menu** in the toolbar (shows current list name)
3. Select any list from the menu
4. The app automatically loads 100 movies from that list
5. Selected list shows a checkmark ✓

### Visual Location:

```
┌─────────────────────────────────────┐
│ Movies to Review    [Top Rated ▼] 🔄│ ← Menu here!
├─────────────────────────────────────┤
│ Movie 1                             │
│ Movie 2                             │
│ ...                                 │
└─────────────────────────────────────┘
```

## 🔧 Technical Details

### Code Changes:

**MovieListView.swift:**
- Added `selectedList` state variable
- Added `MovieListType` enum with 10 options
- Added toolbar menu with all list types
- Updated `loadCuratedMovies()` to fetch based on selection
- Each list type has an icon and optional genre ID

### How It Works:

1. User selects a list from menu
2. `selectedList` state updates
3. `loadCuratedMovies()` is called automatically
4. Function checks if it's a genre list or standard list
5. Calls appropriate TMDBService method
6. Loads 5 pages (~100 movies total)
7. Saves to database with status "pending"
8. SwiftData @Query automatically updates the UI

## 🎨 Icons Used:

| List | Icon |
|------|------|
| Top Rated | star.fill |
| Popular | flame.fill |
| Now Playing | film.fill |
| Upcoming | calendar |
| Action | bolt.fill |
| Comedy | face.smiling |
| Drama | theatermasks.fill |
| Horror | moon.fill |
| Sci-Fi | sparkles |
| Romance | heart.fill |

## 💡 Future Enhancements

Possible additions:
- Remember last selected list (UserDefaults)
- Add more genres (Animation, Thriller, Documentary, etc.)
- Mix multiple lists
- Custom filters (year range, rating, etc.)
- Save different lists as presets
- Add "Hidden Gems" and "Classics" curated lists

## 📱 Platform Compatibility

✅ Works on macOS, iOS, and iPadOS
✅ Menu adapts to each platform's UI conventions
✅ Touch-friendly on iOS
✅ Mouse-friendly on macOS

Enjoy exploring different movie lists! 🎬🍿
