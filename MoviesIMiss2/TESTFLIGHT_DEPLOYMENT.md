# TestFlight Deployment Guide for MoviesIMiss2

This guide walks you through deploying your app to TestFlight for internal or external testing.

## Prerequisites Checklist

Before you can deploy to TestFlight, ensure you have:

- [ ] **Apple Developer Account** ($99/year)
  - Enrolled at [developer.apple.com](https://developer.apple.com/programs/)
  - Account must be active and in good standing
  
- [ ] **App Store Connect Access**
  - Access to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
  
- [ ] **Xcode Configured**
  - Signed in with your Apple ID (Xcode → Settings → Accounts)
  - Certificates downloaded

- [ ] **TMDB API Key Strategy** (see below)

---

## Step 1: Handle the TMDB API Key

⚠️ **CRITICAL:** Your app uses a TMDB API key stored in `Secrets.plist`, which is in `.gitignore`. TestFlight builds need this key, but you **cannot include it in your binary**.

### Recommended Approach: User Provides Their Own Key

The **safest and best** approach for TestFlight:

1. **Remove the dependency on `Secrets.plist`** for release builds
2. **Have users enter their own TMDB API key** on first launch
3. Store the key securely in the Keychain

Your app already has `APIKeySetupView` for this! Just ensure:
- The app checks for an API key on launch
- If no key exists, show the setup screen
- Store the key in Keychain (not UserDefaults)

**Benefits:**
- No security risks
- No rate limiting issues
- Each tester uses their own free TMDB key
- App Store compliant

### Alternative: Backend Service (More Complex)

If you want to ship with a working key:
1. Create a simple backend (Firebase, AWS Lambda, etc.)
2. Store your API key on the backend
3. Have your app make requests to your backend
4. Your backend proxies requests to TMDB

**Not recommended for v1** — adds complexity and costs.

---

## Step 2: Prepare Your Xcode Project

### 2.1: Set App Information

1. Open your project in Xcode
2. Select the **MoviesIMiss2** project in the Project Navigator
3. Select the **MoviesIMiss2** target
4. Go to the **General** tab:

**Identity:**
- **Display Name:** MoviesIMiss2 (or your preferred name)
- **Bundle Identifier:** `com.yourcompany.MoviesIMiss2`
  - Must be unique (replace `yourcompany` with your name/company)
  - Must match App Store Connect
- **Version:** `1.0.0` (user-facing version)
- **Build:** `1` (increment this for each TestFlight upload)

**Deployment Info:**
- **Minimum Deployments:**
  - iOS: 17.0
  - iPadOS: 17.0
  - macOS: 14.0

**Supported Destinations:**
- ✅ iPhone
- ✅ iPad
- ✅ Mac (Designed for iPad) — *or native Mac if you've built for it*

### 2.2: Configure Signing & Capabilities

1. Go to **Signing & Capabilities** tab
2. **Automatic Signing:**
   - ✅ Enable "Automatically manage signing"
   - Select your **Team** from dropdown
   - Xcode will create provisioning profiles automatically

**Add Required Capabilities:**

If not already added, click **+ Capability** and add:
- **User Notifications** (you're using NotificationManager)

### 2.3: Update Info.plist (if needed)

Add usage descriptions for privacy-sensitive features:

```xml
<!-- Required for notifications -->
<key>NSUserNotificationsUsageDescription</key>
<string>MoviesIMiss sends notifications to remind you when it's time to rewatch your favorite movies.</string>
```

---

## Step 3: Create App Store Connect Record

### 3.1: Create App Record

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps**
3. Click the **+** button → **New App**

**Fill in details:**
- **Platform:** iOS (covers iPhone and iPad)
  - *If you want Mac support, you'll need to handle this separately*
- **Name:** MoviesIMiss2 (or your chosen name)
  - Must be unique on the App Store
  - Can change later
- **Primary Language:** English (or your preference)
- **Bundle ID:** Select the one matching your Xcode project
- **SKU:** Can be anything (e.g., `moviesimiss2-001`)
- **User Access:** Full Access

3.2: Set App Information

After creating the app, go to **App Information** and fill in:

- **Category:** Entertainment
- **Subcategory:** (optional)
- **Content Rights:** You own all rights

---

## Step 4: Prepare App Metadata (for TestFlight)

### 4.1: App Icon

You need an app icon! Create a 1024×1024 PNG icon:

**Quick Options:**
- Use an icon generator (search "iOS app icon generator")
- Use SF Symbols as placeholder: film.circle.fill on a background
- Create in Figma, Sketch, or Canva

**Add to Xcode:**
1. Open **Assets.xcassets** in Xcode
2. Find **AppIcon**
3. Drag your 1024×1024 PNG into the "App Store iOS" slot
4. Xcode will generate all required sizes

### 4.2: TestFlight Information (Optional but Recommended)

In App Store Connect:
1. Go to your app → **TestFlight** tab
2. Click **Test Information**
3. Fill in:

**What to Test:**
```
Welcome to MoviesIMiss2 beta!

This is an early version. Please test:
- Adding movies through the Actor Search
- Setting up rewatch notifications
- Browsing curated movie lists
- Filtering between "New!" and "Again!" lists

Known Issues:
- Notifications require your own TMDB API key (free)
- Some movie posters may not load

Please report bugs or feedback to: your-email@example.com
```

**App Store Connect Users:**
```
Email: your-email@example.com
```

---

## Step 5: Create Archive and Upload

### 5.1: Select Archive Scheme

1. In Xcode, select **Product** → **Scheme** → **Edit Scheme...**
2. Select **Run** in the left sidebar
3. Set **Build Configuration** to **Release**
4. Close

### 5.2: Set Build Destination

1. In the toolbar, click the device/simulator selector
2. Select **Any iOS Device (arm64)** or **Any Mac (Apple Silicon)**

### 5.3: Create Archive

1. **Clean Build Folder:**
   - Product → Clean Build Folder (or ⇧⌘K)

2. **Archive:**
   - Product → Archive (or ⌥⌘B)
   - Wait for build to complete (can take several minutes)

**Common Issues:**

**"Secrets.plist not found"**
- Your build is looking for `Secrets.plist`
- Either:
  - Create an empty `Secrets.plist` with a dummy key for archiving
  - Update your code to handle missing `Secrets.plist` gracefully
  - **Recommended:** Make sure `TMDBService` checks for API key and falls back to user input

**"Failed to register bundle identifier"**
- Bundle ID already taken → Change it in Xcode and App Store Connect

**"Provisioning profile doesn't include signing certificate"**
- Go to Xcode → Settings → Accounts
- Select your team → Click "Download Manual Profiles"

### 5.4: Upload to App Store Connect

After archive completes:

1. **Organizer** window opens automatically (or Window → Organizer)
2. Select your archive from the list
3. Click **Distribute App**
4. Choose **App Store Connect**
5. Choose **Upload**
6. Select Distribution Options:
   - ✅ Upload your app's symbols (recommended for crash reports)
   - ✅ Manage Version and Build Number (Xcode will auto-increment)
7. Select Signing: **Automatically manage signing**
8. Click **Upload**

**Wait for Processing:**
- Upload takes a few minutes
- Processing in App Store Connect takes 10-30 minutes
- You'll receive email when ready

---

## Step 6: Enable TestFlight

### 6.1: Wait for Processing

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to your app → **TestFlight** tab
3. Wait for build to show "Ready to Submit" or "Missing Compliance"

### 6.2: Export Compliance

If you see **"Missing Compliance":**

1. Click on your build
2. Answer export compliance questions:
   - **Does your app use encryption?** → NO
     - (Unless you've added custom encryption beyond standard HTTPS)
   - Standard HTTPS/TLS doesn't require export documentation

3. Click **Start Internal Testing**

### 6.3: Add Internal Testers

**Internal Testers** (up to 100):
- Must have App Store Connect access
- Can test immediately without App Review

**To add:**
1. Go to **TestFlight** → **Internal Testing**
2. Click **App Store Connect Users** 
3. Click **+** and add testers by email
4. They'll receive an email invitation

### 6.4: Add External Testers (Optional)

**External Testers** (up to 10,000):
- Don't need App Store Connect access
- Requires App Review (first time only)

**To add:**
1. TestFlight → **External Testing**
2. Create a test group
3. Add testers by email
4. Submit for Beta App Review
5. Wait for approval (usually 24-48 hours)

---

## Step 7: Test Your Build

### 7.1: Install TestFlight App

Testers need the **TestFlight** app:
- Download from App Store (free)

### 7.2: Accept Invitation

1. Testers receive email invitation
2. Tap **View in TestFlight**
3. Opens TestFlight app
4. Tap **Install**

### 7.3: First Launch Testing

**Critical Test:**
1. Launch app for first time
2. App should prompt for TMDB API key (if you implemented user-provided key)
3. Tester enters their free TMDB key
4. App should work normally

---

## Step 8: Update Your Build

When you fix bugs or add features:

### 8.1: Increment Build Number

In Xcode:
1. Select target → **General** tab
2. Increment **Build** number (1 → 2 → 3...)
3. Keep **Version** the same (1.0.0) until public release

### 8.2: Create New Archive

1. Clean build folder
2. Archive
3. Upload to App Store Connect
4. Wait for processing

### 8.3: Auto-Update

TestFlight automatically notifies testers of new builds!

---

## Troubleshooting Common Issues

### Build Fails with "Secrets.plist" Error

**Solution:** Make sure your `TMDBService` handles missing API key:

```swift
// In TMDBService
var hasAPIKey: Bool {
    // Check Keychain first, then Secrets.plist as fallback
    if let _ = getAPIKeyFromKeychain() {
        return true
    }
    
    // Fallback to Secrets.plist for local development
    if let _ = getAPIKeyFromPlist() {
        return true
    }
    
    return false
}
```

### "No API Key" Error on TestFlight

**Solution:** Make sure `APIKeySetupView` is shown and functional:

```swift
// In ContentView
if tmdbService.hasAPIKey {
    mainTabView
} else {
    APIKeySetupView()
}
```

### Testers Can't Install

Check:
- ✅ Build is in "Ready to Submit" or "Testing" state
- ✅ Tester email is added to test group
- ✅ Tester has TestFlight app installed
- ✅ Tester opened invitation email on their device

### Build Processing Takes Forever

Normal processing: 10-30 minutes
If longer:
- Check for email from Apple (could be rejection)
- Verify upload completed successfully
- Try refreshing App Store Connect

---

## Security Best Practices

### API Key Management

✅ **DO:**
- Store user-entered API keys in **Keychain**
- Use Apple's Security framework
- Clear API key on logout/reset

❌ **DON'T:**
- Store in UserDefaults (not secure)
- Include hardcoded keys in binary
- Commit API keys to git

### Example Keychain Storage:

```swift
import Security

class KeychainHelper {
    static func save(key: String, value: String) -> Bool {
        let data = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }
    
    static func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
}
```

---

## Checklist Before Upload

- [ ] App icon added (1024×1024)
- [ ] Bundle identifier set and unique
- [ ] Version and build numbers set
- [ ] Automatic signing enabled
- [ ] User Notifications capability added
- [ ] Privacy descriptions added to Info.plist
- [ ] TMDB API key handled (user-provided or backend)
- [ ] Clean build folder
- [ ] Archive created successfully
- [ ] Upload completed
- [ ] App Store Connect app record created
- [ ] Export compliance answered
- [ ] TestFlight testers added

---

## Next Steps After TestFlight

### For Internal Testing
- Share feedback with your team
- Fix critical bugs
- Iterate on features

### For External Beta (Optional)
- Submit for Beta App Review
- Gather user feedback
- Prepare marketing materials

### For App Store Release
- Create App Store listing (screenshots, description)
- Set pricing (free or paid)
- Submit for App Review
- Wait for approval
- Release to the world! 🚀

---

## Support

**App Store Connect Issues:**
- [Apple Developer Support](https://developer.apple.com/support/)

**TestFlight Documentation:**
- [TestFlight Help](https://developer.apple.com/testflight/)

**Xcode Archiving:**
- [Distributing Your App](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)

---

Good luck with your TestFlight launch! 🎬
