# Build Error Fix: "Ambiguous use of 'init()'"

## The Error

You're seeing:
```
error: Ambiguous use of 'init()'
```

This typically happens when Swift can't determine which initializer to use.

---

## Solution: Add Files to Xcode Target

The new files need to be added to your Xcode project:

### Step 1: Check File Membership

1. In Xcode, select `KeychainHelper.swift` in the Project Navigator
2. Open the **File Inspector** (⌥⌘1 or View → Inspectors → File)
3. Under **Target Membership**, ensure `MoviesIMiss2` is **checked**
4. Repeat for `APIKeySetupView.swift`

### Step 2: Clean and Rebuild

```
1. Product → Clean Build Folder (⇧⌘K)
2. Product → Build (⌘B)
```

---

## If Error Persists: Check TMDBService

The error might be coming from `TMDBService()` initialization. Let me verify your TMDBService.swift has the updated code.

### Expected Code in TMDBService.swift:

Around line 38-65, you should see:

```swift
init() {
    loadAPIKey()
}

private func loadAPIKey() {
    // First, try to load from Keychain (for user-provided keys)
    if let key = KeychainHelper.shared.get(key: "TMDB_API_KEY") {
        apiKey = key
        return
    }
    
    // Fallback: Try to load from Secrets.plist (for development)
    if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
       let data = try? Data(contentsOf: url),
       let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String],
       let key = plist["TMDB_API_KEY"] {
        apiKey = key
    }
}

/// Set the API key at runtime and save it to Keychain
func setAPIKey(_ key: String) {
    apiKey = key
    KeychainHelper.shared.save(key: "TMDB_API_KEY", value: key)
}

/// Clear the stored API key
func clearAPIKey() {
    apiKey = nil
    KeychainHelper.shared.delete(key: "TMDB_API_KEY")
}
```

If this code is missing or different, the `init()` might be ambiguous.

---

## Alternative: Manually Add Files

If files aren't showing up in Xcode:

### Step 1: Add KeychainHelper.swift

1. In Xcode, right-click your project folder
2. **New File** → **Swift File**
3. Name it `KeychainHelper.swift`
4. Copy the contents from `/repo/KeychainHelper.swift`
5. Paste and save

### Step 2: Add APIKeySetupView.swift

1. Right-click your project folder
2. **New File** → **Swift File**
3. Name it `APIKeySetupView.swift`
4. Copy the contents from `/repo/APIKeySetupView.swift`
5. Paste and save

### Step 3: Verify TMDBService.swift Changes

1. Open `TMDBService.swift`
2. Find the `loadAPIKey()` method
3. Ensure it has been updated with the Keychain check first
4. Ensure `setAPIKey()` and `clearAPIKey()` methods exist

---

## Quick Test

After adding the files and updating TMDBService, test:

```swift
// This should compile now
let service = TMDBService()
```

If it still doesn't work, the issue is likely:
1. Files not added to target
2. Multiple definitions of `init()` somewhere
3. Conflicting imports

---

## Verification Checklist

- [ ] `KeychainHelper.swift` is in project
- [ ] `KeychainHelper.swift` has target membership checked
- [ ] `APIKeySetupView.swift` is in project
- [ ] `APIKeySetupView.swift` has target membership checked
- [ ] `TMDBService.swift` has been updated with new methods
- [ ] Clean build folder executed
- [ ] Project rebuilds successfully

---

## Still Having Issues?

### Check for Duplicate Files

Sometimes Xcode creates duplicate references:

1. In Project Navigator, search for "TMDBService"
2. If you see multiple files with the same name, delete duplicates
3. Keep only one version

### Check for Typos

Make sure class names are spelled correctly:
- `KeychainHelper` (not `KeyChainHelper` or `KeychainManager`)
- `TMDBService` (not `TMDBservice` or `TmdbService`)

### Last Resort: Restart Xcode

1. Save all files
2. Quit Xcode completely
3. Reopen your project
4. Clean build folder
5. Build

---

## Expected Result

After fixing, your app should:
- ✅ Build without errors
- ✅ Show API key setup screen if no key exists
- ✅ Work normally with Secrets.plist in development
- ✅ Save user-provided keys to Keychain

---

## Need More Help?

If you're still seeing the error, please share:
1. The complete error message
2. Which file/line it's pointing to
3. Whether the new files are showing in your Project Navigator

I can help debug further!
