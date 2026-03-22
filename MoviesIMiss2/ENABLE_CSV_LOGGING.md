# How to Enable CSV Logging Feature

The CSV logging code has been prepared but is currently commented out to avoid build errors. Here's how to enable it when you're ready:

## Step 1: Add Files to Xcode Project

1. **In Xcode, locate these two files** (they're in your repo but not in the Xcode project yet):
   - `CSVLogger.swift`
   - `DebugSettingsView.swift`

2. **Add them to your Xcode project**:
   - Right-click on your project folder in Xcode's navigator
   - Select "Add Files to [Your Project Name]..."
   - Navigate to find the files
   - Make sure "Copy items if needed" is checked
   - Make sure your app target is selected
   - Click "Add"

## Step 2: Uncomment the CSV Logging Code

Once the files are in your project, search for `TODO: Uncomment when CSVLogger` in `TMDBService.swift` and uncomment all the logging lines.

**Find and replace:**

Replace:
```swift
// TODO: Uncomment when CSVLogger is added to project
// await CSVLogger.shared.logMovies(...)
```

With:
```swift
await CSVLogger.shared.logMovies(...)
```

There are approximately 11 places in TMDBService.swift where this needs to be done.

## Step 3: Build and Test

1. Build your project (⌘B)
2. If there are no errors, the CSV logging feature is ready!
3. Add DebugSettingsView to your app navigation (see INTEGRATION_EXAMPLES.swift)

## Quick Integration

Add this to your settings or navigation:

```swift
NavigationLink("Debug Settings") {
    DebugSettingsView()
}
```

## Current State

✅ Code is written and ready  
✅ Documentation is complete  
⚠️ Files need to be added to Xcode project  
⚠️ CSV logging calls are commented out  

Once you add the files and uncomment the code, you'll have full CSV logging capability!

## Alternative: Skip CSV Logging

If you don't want CSV logging:
1. Delete the CSVLogger.swift and DebugSettingsView.swift files
2. Remove the commented TODO lines from TMDBService.swift
3. Continue with your project

The commented code has zero impact on performance or functionality.
