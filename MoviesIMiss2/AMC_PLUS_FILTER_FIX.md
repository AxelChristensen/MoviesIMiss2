# AMC+ Streaming Filter Fix

## Problem
Cape Fear was showing AMC+ in its watch providers, but when filtering for AMC+ in the "New!" tab, no movies appeared.

## Root Cause
TMDB uses **multiple provider IDs** for AMC+ depending on distribution channel:
- **528** = AMC+ Amazon Channel (what Cape Fear had)
- **635** = AMC+ Roku Premium Channel (what the code was checking for)

The original code only checked for a single provider ID (635), missing movies available through other AMC+ channels.

## Solution
Updated the streaming provider system to support **multiple provider IDs** per service:

### Changes Made

#### 1. WatchProviderFilter.swift
- Changed `providerId: Int?` to return the first ID from `providerIds`
- Added new `providerIds: [Int]` property that returns all IDs for a service
- Updated AMC+ to include both IDs: `[528, 635]`
- Added `hasAnyProvider()` extension method to check multiple IDs

```swift
var providerIds: [Int] {
    switch self {
    // ...
    case .amcPlus: return [528, 635] // Both Amazon and Roku channels
    // ...
    }
}

extension TMDBCountryProviders {
    func hasAnyProvider(ids: [Int], freeOnly: Bool = false, rentalOnly: Bool = false) -> Bool {
        for id in ids {
            if hasProvider(id: id, freeOnly: freeOnly, rentalOnly: rentalOnly) {
                return true
            }
        }
        return false
    }
}
```

#### 2. NewMoviesView.swift
- Updated filtering logic to use `hasAnyProvider()` with all provider IDs
- Changed from checking single ID to checking array of IDs

```swift
let hasProvider = providers.hasAnyProvider(
    ids: providerIds,
    freeOnly: selectedStreamingProvider.isFreeOnly,
    rentalOnly: selectedStreamingProvider.isRentalOnly
)
```

#### 3. MovieListView.swift
- Updated Browse tab filtering to use `hasAnyProvider()`
- Updated debug output to show all provider IDs being checked

#### 4. AgainListView.swift
- Updated Again! tab filtering to use `hasAnyProvider()`

## Result
Now when filtering for AMC+, the app checks for **both** provider IDs (528 and 635), so movies available through either AMC+ Amazon Channel or AMC+ Roku Premium Channel will appear in the filtered results.

## Debug Output
With the fix, you should see:
```
🔍 Searching for provider IDs: [528, 635] (AMC+)
📺 Cape Fear: Providers: flatrate[AMC+ Amazon Channel (ID:528), ...]
✅ Cape Fear HAS AMC+
```

## Future Extensibility
This pattern can be used for other services that have multiple TMDB provider IDs:
- Paramount+ (different channels/platforms)
- Showtime (standalone vs add-on)
- HBO/Max (various distribution methods)
- etc.

Just add multiple IDs to the `providerIds` array for any service.
