# Pre-TestFlight Checklist

Quick checklist to ensure your app is ready for TestFlight deployment.

## ✅ Code Changes Made

The following changes have been implemented to make your app TestFlight-ready:

### 1. **KeychainHelper.swift** (NEW)
- Secure storage for API keys
- Uses Apple's Security framework
- Replaces insecure UserDefaults storage

### 2. **TMDBService.swift** (UPDATED)
- Now checks Keychain first, then falls back to Secrets.plist
- Added `setAPIKey(_ key: String)` method for runtime API key setting
- Added `clearAPIKey()` method for clearing stored keys
- Development workflow unchanged (still uses Secrets.plist locally)

### 3. **APIKeySetupView.swift** (NEW)
- Beautiful onboarding screen for new users
- API key validation before saving
- Instructions for getting a TMDB API key
- Link to TMDB website

### 4. **ContentView.swift** (UPDATED)
- Now responds to API key updates via NotificationCenter
- Automatically refreshes when user enters API key
- Seamless transition from setup to main app

---

## 🎯 How It Works

### For Development (You)
1. You still use `Secrets.plist` locally
2. No changes to your workflow
3. API key stays in `.gitignore`

### For TestFlight Users
1. App launches without `Secrets.plist`
2. User sees `APIKeySetupView`
3. User follows instructions to get free TMDB key
4. User enters key → validated and saved to Keychain
5. App loads normally

---

## 📋 Final Checklist Before Archive

### Project Configuration

- [ ] **Bundle Identifier Set**
  - Unique identifier in format `com.yourname.MoviesIMiss2`
  - Same in Xcode and App Store Connect

- [ ] **App Icon Added**
  - 1024×1024 PNG in Assets.xcassets
  - All required sizes generated

- [ ] **Version Numbers Set**
  - Version: `1.0.0` (or your choice)
  - Build: `1` (increment for each upload)

- [ ] **Signing Configured**
  - Automatic signing enabled
  - Team selected
  - Provisioning profile generated

### Capabilities & Permissions

- [ ] **User Notifications Capability Added**
  - In Signing & Capabilities tab

- [ ] **Privacy Descriptions Added**
  - `NSUserNotificationsUsageDescription` in Info.plist
  - Clear explanation of why you need notifications

### Code Quality

- [ ] **App Builds Successfully**
  - Product → Build (⌘B)
  - No errors or warnings (fix warnings if possible)

- [ ] **App Runs on Device/Simulator**
  - Test on iPhone and iPad
  - Test API key setup flow
  - Test main features

- [ ] **Secrets.plist Handling**
  - File is in `.gitignore`
  - App works WITHOUT the file
  - API key setup screen appears when no key exists

### Testing the API Key Flow

- [ ] **Test Without API Key**
  1. Delete app from simulator/device
  2. Make sure `Secrets.plist` is NOT included in target
  3. Build and run
  4. Should see API key setup screen
  5. Enter a valid TMDB key
  6. App should load normally

- [ ] **Test With Local API Key**
  1. Make sure `Secrets.plist` IS included for development
  2. Build and run
  3. App should skip setup and go straight to main view

### App Store Connect

- [ ] **App Created in App Store Connect**
  - Name matches or is available
  - Bundle ID matches Xcode

- [ ] **Test Information Added**
  - What to test description
  - Known issues listed
  - Contact email provided

### Build Settings

- [ ] **Release Configuration**
  - Scheme set to Release (Edit Scheme)
  - Optimizations enabled

- [ ] **Deployment Target**
  - iOS 17.0 minimum
  - iPadOS 17.0 minimum
  - macOS 14.0 (if supporting Mac)

---

## 🔨 Archive Process

### 1. Clean Build
```
Product → Clean Build Folder (⇧⌘K)
```

### 2. Select Destination
```
Any iOS Device (arm64)
```

### 3. Archive
```
Product → Archive
```

### 4. Upload
```
Distribute App → App Store Connect → Upload
```

---

## 🧪 Post-Upload Testing

After your build is processed in App Store Connect:

### 1. Add Yourself as Internal Tester
- TestFlight → Internal Testing
- Add your email
- Install TestFlight app on your device

### 2. Test the Full Flow
- [ ] Install from TestFlight
- [ ] API key setup appears
- [ ] Get TMDB API key from themoviedb.org
- [ ] Enter key in app
- [ ] Key validates successfully
- [ ] Main app loads
- [ ] Search for movies works
- [ ] Add movies to lists
- [ ] Notifications work (test with 1-minute option)
- [ ] Navigate all tabs

### 3. Common First-Time Issues

**Issue:** "App crashes on launch"
- Check crash logs in App Store Connect
- Verify all required frameworks are included
- Check for hardcoded paths to `Secrets.plist`

**Issue:** "Can't validate API key"
- Check network connectivity
- Verify TMDB API is accessible
- Check error messages in console

**Issue:** "Notifications don't appear"
- Verify User Notifications capability added
- Check notification permissions granted
- Background app before notification triggers

---

## 📱 Tester Instructions to Include

When inviting external testers, include these instructions:

```
Welcome to MoviesIMiss2 Beta!

SETUP:
1. Install the TestFlight app from the App Store
2. Accept the invitation email
3. Install MoviesIMiss2

GETTING STARTED:
1. The app will ask for a TMDB API key
2. Tap "How to get an API key" for instructions
3. Visit themoviedb.org and create a free account
4. Go to Settings → API → Request API Key
5. Copy your API key and paste into the app
6. The app will validate and save your key

TESTING FOCUS:
- Search for actors and add their movies
- Test the "New!" and "Again!" lists
- Try setting rewatch notifications
- Explore the curated movie lists

KNOWN ISSUES:
- [List any known bugs here]

FEEDBACK:
Please report bugs or suggestions to: your-email@example.com
```

---

## 🚀 Ready to Ship!

Once you've completed this checklist:

1. ✅ Archive your app
2. ✅ Upload to App Store Connect
3. ✅ Add test information
4. ✅ Invite testers
5. ✅ Monitor feedback
6. ✅ Iterate and improve!

Good luck with your TestFlight launch! 🎬

---

## 📚 Additional Resources

- [TestFlight Deployment Guide](TESTFLIGHT_DEPLOYMENT.md) - Detailed step-by-step guide
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [TMDB API Documentation](https://developers.themoviedb.org/3)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
