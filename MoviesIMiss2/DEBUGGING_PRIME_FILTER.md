# Debugging Amazon Prime Filtering

## Issue: Only a Few Movies Showing for Amazon Prime

If you're seeing fewer Amazon Prime movies than expected, here are several possible reasons and how to debug them.

## Quick Diagnostics

### Step 1: Check the Console Logs

When you select "Amazon Prime (Free)", look for these logs:

```
🎬 Loading watch providers for X movies...
📊 Total pending movies: X
📦 Already cached: X
✅ Loaded providers for X movies
📦 Total cached: X
🎯 Movies matching Amazon Prime (Free): X
```

**What to look for:**
- Are providers loading? (Should see "Loading watch providers...")
- How many movies total? (Total pending movies)
- How many match? (Movies matching Amazon Prime (Free))

### Step 2: Understanding the Numbers

**Example Output:**
```
📊 Total pending movies: 100
📦 Already cached: 100
🎯 Movies matching Amazon Prime (Free): 5
```

This means:
- You have 100 movies in your browse list
- All 100 have provider data loaded
- Only 5 are actually free on Amazon Prime

**This is likely correct!** Amazon Prime's free selection changes frequently and may not include many of the curated movies.

## Common Reasons for Few Results

### 1. Limited Prime Video Availability
**Reality Check:** Not many highly-rated movies are free on Prime.

Amazon Prime Video in the US typically has:
- Fewer "free with Prime" movies than you might expect
- Many more rental/purchase options
- Rotating selection that changes monthly

**What to try:**
- Select "Amazon Prime (Rental/Buy)" instead
- Should see many more movies (50-100+)
- This confirms the filter is working correctly

### 2. Geographic Region (US Only)
The filter currently uses US provider data:
```swift
watchProviders = response.providers(for: "US")
```

If you're outside the US:
- Provider availability will be different
- Some movies may not have US provider data
- Consider adding country selection (future feature)

### 3. Curated List Type
Different list types have different Prime availability:

**More Prime Movies:**
- Popular movies (current hits)
- 2010s-2020s decade filter
- Action, Comedy genres

**Fewer Prime Movies:**
- Top Rated (classic films, often not on Prime)
- Very high ratings (8.5+)
- Older decades (1950s-1980s)

### 4. Provider Data Availability
Some movies may not have provider data in TMDB:
- Very new releases
- Independent/foreign films
- Older classics

## Debugging Steps

### Test 1: Verify Provider Loading

1. **Reset Filters**
2. **Load fresh movies** (tap refresh)
3. **Select "Amazon Prime (Free)"**
4. **Watch the console** - should see loading messages
5. **Wait for completion** - should see match count

### Test 2: Compare with "Rental/Buy"

1. **Note the count** for "Amazon Prime (Free)" (example: 5 movies)
2. **Switch to "Amazon Prime (Rental/Buy)"**
3. **Compare the count** (should be much higher, like 80 movies)

If rental count is much higher → Filter is working correctly!

### Test 3: Verify a Specific Movie

1. **Select "Amazon Prime (Free)"**
2. **Tap on one of the shown movies**
3. **Scroll to "Where to Watch" section**
4. **Verify Amazon Prime is listed** in "Stream" category

If Amazon Prime appears in Stream → Filter is accurate! ✅

### Test 4: Check Different Filters

Try combinations that typically have more Prime content:

```
List Type: Popular
Decade: 2010s
Rating: All
Service: Amazon Prime (Free)
```

vs.

```
List Type: Top Rated
Decade: 1970s
Rating: 8.5+
Service: Amazon Prime (Free)
```

First combination should show more results.

## Expected Behavior

### Realistic Expectations

**Amazon Prime (Free):**
- Typically: 5-20 movies from a curated "Top Rated" list
- Can be: 0-5 for very specific filters (8.5+, 1980s, etc.)
- Could be: 50-100+ for "Popular" or current content

**Amazon Prime (Rental/Buy):**
- Typically: 80-150 movies from most lists
- Almost all mainstream movies available to rent

### Why So Few Free Movies?

Amazon Prime's free streaming library:
- **Rotates monthly** - movies come and go
- **Focuses on Amazon Originals** - not in curated TMDB lists
- **Limited classics** - older films often only available to rent
- **Competes with rentals** - Amazon prefers you rent

**This is normal!** Prime Video's "free with subscription" catalog is genuinely smaller than Netflix, Disney+, or Hulu.

## Advanced Debugging

### Enable Detailed Logs

The debug logs will show provider matching:

```
  ✅ Free match for provider 9
    - Found in flatrate (free with subscription)
```

Or:

```
  🔍 Rental/Buy match for provider 9
    - Found in rent
    - Found in buy
```

### Sample a Few Movies

Pick 3-5 movies from your Browse list and manually check:
1. Go to justwatch.com
2. Search for each movie
3. Check US availability
4. See if it's really free on Prime

This will verify if TMDB data is accurate.

## Solutions & Workarounds

### If You Want More Results

**Option 1: Broaden Your Filters**
```
Service: Amazon Prime (Free)
Decade: All Time (not just 1980s)
Rating: All (not 8.5+)
List: Popular (not Top Rated)
```

**Option 2: Include Rentals**
```
Service: Amazon Prime (Rental/Buy)
```
Many movies are rentable for $3-5.

**Option 3: Try Other Services**
```
Service: Netflix
Service: Hulu
Service: Tubi TV (free with ads)
```

Compare availability across platforms.

### If No Movies Show At All

**Checklist:**
- [ ] Wait for "Loading streaming availability..." to finish
- [ ] Check console for "Movies matching" count
- [ ] Try "Amazon Prime (Rental/Buy)" - does it show more?
- [ ] Reset all filters and try again
- [ ] Try a different service (Netflix, Hulu)

If other services work but Prime doesn't:
- Could be temporary TMDB API issue
- Try again in a few minutes
- Check your internet connection

## Reporting Issues

### When to Report a Bug

Report if you see:
- ❌ Movies showing "not available" but appearing in filter
- ❌ Provider data never loads (perpetual spinner)
- ❌ Console shows errors
- ❌ Filter shows 0 movies for ALL services

### What's NOT a Bug

Don't report if:
- ✅ Only 5-10 Prime movies show (this is realistic)
- ✅ More rental movies than free movies (expected)
- ✅ Netflix has more movies than Prime (true)
- ✅ Old movies (1950s-1970s) not on Prime (normal)

## Summary

**Key Points:**

1. **Amazon Prime (Free) genuinely has limited selection** 📚
2. **5-20 movies from a "Top Rated" list is normal** ✅
3. **Rental/Buy should show 10-20x more movies** 💰
4. **Use console logs to verify behavior** 🔍
5. **Try different filters for more results** 🎛️

**The filter is working correctly if:**
- Provider data loads successfully ✅
- Match count appears in console ✅
- "Rental/Buy" shows more than "Free" ✅
- Tapping a movie confirms Prime availability ✅

**Most likely:** You're seeing accurate results - Prime just doesn't have many highly-rated classic films available for free! This is a content licensing issue, not a bug. 🎬
