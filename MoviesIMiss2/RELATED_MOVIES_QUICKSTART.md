# Related Movies Feature - Quick Start Guide

## What Was Added

A new "Discover Related Movies" button in the Movie Detail panel that helps you find similar and recommended movies based on any movie in your collection.

## Where to Find It

1. Open any movie from your watchlist
2. Scroll down past the mood information section
3. Look for the **blue "Discover Related Movies"** button (just above the red "Remove from Watchlist" button)

## How It Works

### Step 1: Tap the Button
Tap "Discover Related Movies" from any movie detail view

### Step 2: Choose Your Discovery Method
Use the segmented control at the top to switch between:
- **Similar** 🎬 - Movies with similar genres, themes, and style
- **Recommended** ✨ - TMDB's algorithm-based recommendations

### Step 3: Browse and Add
- Scroll through the related movies
- See poster, title, year, rating, and description
- Tap any movie to add it to your collection

## Example Use Cases

### "I loved this movie, show me more like it"
→ Use the **Similar** tab to find movies with comparable themes and genres

### "What should I watch next based on this?"
→ Use the **Recommended** tab for TMDB's curated suggestions

### "I want to explore a genre deeper"
→ Find a movie you like in that genre, then discover related titles

## Features

✅ Two discovery methods (Similar & Recommended)  
✅ Parallel loading for fast results  
✅ Movie cards with ratings and descriptions  
✅ Direct add to your collection  
✅ Works with all existing mood tracking features  
✅ Error handling for network issues  

## Visual Layout

```
┌─────────────────────────────────┐
│  Movie Detail View              │
├─────────────────────────────────┤
│  [Poster] Title & Info          │
│  ─────────────────────────      │
│  Watch History                  │
│  [Log Watched Today]            │
│  When to Watch Again            │
│  ─────────────────────────      │
│  Mood Information               │
│  ─────────────────────────      │
│  [Discover Related Movies] ⭐   │ ← NEW BUTTON
│  ─────────────────────────      │
│  [Remove from Watchlist]        │
└─────────────────────────────────┘
```

When you tap it:

```
┌─────────────────────────────────┐
│  Related to [Movie Title]       │
├─────────────────────────────────┤
│  [ Similar | Recommended ]      │ ← Segmented Picker
├─────────────────────────────────┤
│  ┌───┐ Movie Title              │
│  │📷│ Year • ⭐ 7.5             │
│  └───┘ Description snippet...   │
│         [+] Add                 │
├─────────────────────────────────┤
│  ┌───┐ Another Movie            │
│  │📷│ Year • ⭐ 8.2             │
│  └───┘ Description snippet...   │
│         [+] Add                 │
└─────────────────────────────────┘
```

## API Endpoints Used

- `/movie/{id}/similar` - Finds similar movies
- `/movie/{id}/recommendations` - Gets TMDB recommendations

## Technical Details

- **Parallel Loading**: Fetches both similar and recommended movies at once
- **Swift Concurrency**: Uses async/await for smooth performance
- **Lazy Loading**: Efficient scrolling with LazyVStack
- **Error Handling**: Graceful handling of network and API errors

## Tips

💡 **Best Results**: Works great with popular movies that have lots of data  
💡 **Discovery Path**: Start with a movie you love → Find similar → Add to watchlist → Watch → Repeat  
💡 **Genre Deep Dive**: Pick one movie per genre and explore its related movies  
💡 **Mix Both Tabs**: Similar gives you safe bets, Recommended gives you surprises  

## Troubleshooting

**No results showing?**
- Very new or obscure movies may have limited related content
- Try switching between Similar and Recommended tabs
- Check your internet connection

**Can't add a movie?**
- Make sure you have a TMDB API key configured
- The movie may already be in your collection (feature to filter these coming soon)

## What's Next?

The feature is fully functional! Future enhancements could include:
- Showing which movies are already in your collection
- Filtering out duplicate adds
- Sorting options
- Pagination for huge result sets
