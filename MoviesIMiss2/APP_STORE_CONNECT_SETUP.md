# App Store Connect Setup Guide

Complete walkthrough for setting up your app in App Store Connect.

---

## Prerequisites

Before you begin, ensure you have:

- ✅ **Active Apple Developer Account** ($99/year)
  - Enrolled at [developer.apple.com](https://developer.apple.com/programs/)
  - Payment processed and account active
  
- ✅ **Bundle Identifier** decided
  - Must be unique (e.g., `com.yourname.MoviesIMiss2`)
  - Will be registered during this process
  
- ✅ **App Name** decided
  - Must be unique on the App Store
  - Can be changed later if needed

---

## Part 1: Register Your Bundle Identifier

### Step 1: Log into Apple Developer Portal

1. Go to [developer.apple.com](https://developer.apple.com)
2. Click **Account** in the top right
3. Sign in with your Apple ID

### Step 2: Register Bundle ID

1. In the left sidebar, click **Certificates, Identifiers & Profiles**
2. Click **Identifiers**
3. Click the **+** button (top left)
4. Select **App IDs** → Click **Continue**
5. Select **App** → Click **Continue**

### Step 3: Configure Your App ID

**Description:**
```
MoviesIMiss2
```

**Bundle ID:**
- Select **Explicit**
- Enter: `com.yourname.MoviesIMiss2`
  - Replace `yourname` with your actual name or company
  - Example: `com.johnsmith.MoviesIMiss2`
  - Must match exactly what you'll use in Xcode

**Capabilities:**
Check these boxes:
- ✅ **Push Notifications** (even if not using immediately)
- ✅ **iCloud** (optional, for future sync features)
- ✅ **App Groups** (optional, for sharing data)

**Click Continue** → **Click Register**

✅ Your Bundle ID is now registered!

---

## Part 2: Create App in App Store Connect

### Step 1: Access App Store Connect

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Sign in with your Apple ID
3. Click **My Apps**

### Step 2: Create New App

1. Click the **+** button (near top left)
2. Select **New App**

### Step 3: Fill in App Information

A modal will appear. Fill in the following:

#### **Platforms:**
- ✅ **iOS** (this covers iPhone and iPad)
- ❌ macOS (leave unchecked for now, can add later)

#### **Name:**
```
MoviesIMiss2
```
- This is what users see on the App Store
- Must be unique across the entire App Store
- If taken, try variations:
  - `MoviesIMiss 2`
  - `Movies I Miss`
  - `MoviesIMiss - Rewatch Tracker`

💡 **Tip:** Check availability by typing. If taken, you'll see a red error.

#### **Primary Language:**
```
English (U.S.)
```
- Or your preferred language
- This is the language of your app's metadata

#### **Bundle ID:**
- Click the dropdown
- Select the Bundle ID you just registered
  - `com.yourname.MoviesIMiss2`
- If you don't see it, you may need to wait a few minutes or refresh

#### **SKU:**
```
moviesimiss2-v1
```
- Can be anything (internal identifier)
- Never shown to users
- Can't be changed later
- Suggestion format: `appname-v1` or `com.yourname.appname`

#### **User Access:**
- Leave as **Full Access** (default)
- This controls who can see the app in App Store Connect

### Step 4: Create the App

Click **Create**

✅ Your app record is now created!

---

## Part 3: Configure App Information

After creating your app, you'll be taken to the app dashboard. Let's configure it:

### Step 1: App Information

Click **App Information** in the left sidebar.

#### **General Information:**

**Subtitle (Optional):**
```
Track movies you want to rewatch
```
- Max 30 characters
- Appears under your app name

**Category:**
- **Primary:** Entertainment
- **Secondary (Optional):** Productivity or Lifestyle

**Content Rights:**
```
Does not use third-party content
```
- Or check the box if you do

**Age Rating:**
- Click **Edit** next to Age Rating
- Answer the questionnaire honestly
  - No violence, mature content, etc.
- Should result in **4+** rating for your app

**Save** when done.

---

## Part 4: Prepare for First Build

### Step 1: Pricing and Availability

1. Click **Pricing and Availability** in the left sidebar
2. Set **Price:** Free (or your choice)
3. **Availability:** All countries (or specific ones)
4. Click **Save**

### Step 2: App Privacy

1. Click **App Privacy** in the left sidebar
2. Click **Get Started**

**Privacy Policy URL:**
- If you don't have one yet, you can add it later
- For beta testing, it's optional
- For App Store release, you'll need one

**Data Collection:**

For MoviesIMiss2, you likely:
- **Don't collect user data** (everything stored locally)
- **Use third-party analytics** (if you add analytics later)

Answer questions accordingly:
1. **Do you collect data from this app?**
   - Select **No** (assuming no analytics or tracking)
   
2. Click **Save**

💡 **Note:** For TestFlight, you don't need to complete privacy details fully.

### Step 3: TestFlight Information

1. Click on the **TestFlight** tab at the top
2. Click **Test Information** in the left sidebar
3. Fill in:

**Beta App Description:**
```
MoviesIMiss2 helps you track movies you want to watch again. Search for actors, discover their filmography, and set reminders for rewatches.

This is a beta version for testing. All features are functional but may have bugs.
```

**What to Test:**
```
Please test the following features:

1. TMDB API Key Setup:
   - Follow the in-app instructions to get a free TMDB API key
   - Enter your key and verify it validates successfully

2. Movie Discovery:
   - Search for actors by name
   - Browse their movies
   - Add movies to your lists

3. Movie Lists:
   - Browse tab: Discover curated movies
   - New! tab: Movies you haven't seen
   - Again! tab: Movies to rewatch

4. Notifications:
   - Add a movie with "Seen Before" checked
   - Set rewatch date to "TEST: In 1 Minute"
   - Background the app and verify notification appears

Known Issues:
- First launch may take a moment to load
- Some older movies may have missing posters

Please report any bugs or feedback to: your-email@example.com
```

**Feedback Email:**
```
your-email@example.com
```
- Replace with your actual email

**Marketing URL (Optional):**
- Leave blank for now

**Privacy Policy URL (Optional):**
- Leave blank for TestFlight

Click **Save**

---

## Part 5: Configure Xcode Project

Now that App Store Connect is set up, configure your Xcode project to match:

### Step 1: Open Your Project in Xcode

1. Open Xcode
2. Open your MoviesIMiss2 project
3. In the Project Navigator, select the **MoviesIMiss2** project (top level)
4. Select the **MoviesIMiss2** target

### Step 2: Set Bundle Identifier

1. Go to the **General** tab
2. Under **Identity**, set **Bundle Identifier** to match what you registered:
   ```
   com.yourname.MoviesIMiss2
   ```
   - Must match EXACTLY

### Step 3: Set Version Information

**Version:**
```
1.0.0
```
- User-facing version number
- Follows semantic versioning (major.minor.patch)

**Build:**
```
1
```
- Internal build number
- Increment this for each upload (1, 2, 3...)
- Doesn't need to match version

### Step 4: Configure Signing

1. Go to the **Signing & Capabilities** tab
2. Under **Signing:**
   - ✅ Check **Automatically manage signing**
   - **Team:** Select your Apple Developer team from dropdown
   - **Provisioning Profile:** Will be created automatically

**If you see errors:**
- Make sure you're logged into Xcode with your Apple ID
  - Xcode → Settings → Accounts
- Make sure your Bundle ID matches App Store Connect
- Try unchecking and re-checking "Automatically manage signing"

### Step 5: Add Capabilities

Still on the **Signing & Capabilities** tab:

1. Click **+ Capability** (top left)
2. Add **Push Notifications**
   - Even if not using yet, good to have
3. Add **Background Modes** (if not already present)
   - Check **Remote notifications** (for future use)

### Step 6: Add Privacy Descriptions

1. In Project Navigator, find **Info.plist**
   - Or select target → **Info** tab
2. Add these keys:

**NSUserNotificationsUsageDescription:**
```
MoviesIMiss sends notifications to remind you when it's time to rewatch your favorite movies.
```

**How to add:**
- Right-click in Info.plist → Add Row
- Key: `Privacy - User Notifications Usage Description`
- Type: String
- Value: (paste the description above)

---

## Part 6: Test Build Locally

Before archiving, make sure everything works:

### Step 1: Clean Build

```
Product → Clean Build Folder (⇧⌘K)
```

### Step 2: Build

```
Product → Build (⌘B)
```

**Fix any errors that appear.**

### Step 3: Run on Simulator

1. Select an iPhone simulator from the device menu
2. Product → Run (⌘R)
3. Verify:
   - ✅ App launches
   - ✅ API key setup screen appears (if no Secrets.plist)
   - ✅ Can enter API key
   - ✅ Main app loads after key entry

### Step 4: Run on Physical Device (Recommended)

1. Connect your iPhone or iPad via USB
2. Select it from the device menu
3. Product → Run (⌘R)
4. Test the full flow on real hardware

---

## Part 7: Ready to Archive!

Your App Store Connect is now configured. Next steps:

### ✅ Checklist Before First Archive:

- [ ] Bundle ID matches App Store Connect
- [ ] App builds without errors
- [ ] Signing is configured and working
- [ ] Version numbers are set (1.0.0, build 1)
- [ ] Privacy descriptions added to Info.plist
- [ ] App tested on simulator and/or device
- [ ] API key setup flow works
- [ ] Main features functional

### Next: Create Archive

Follow the steps in **TESTFLIGHT_DEPLOYMENT.md** starting at "Step 5: Create Archive and Upload"

Quick version:
1. Select **Any iOS Device (arm64)** from device menu
2. Product → Archive
3. Wait for archive to complete
4. Distribute → App Store Connect → Upload
5. Wait for processing in App Store Connect
6. Enable TestFlight testing

---

## Common Issues & Solutions

### "Bundle identifier already in use"

**Solution:** Someone else registered that Bundle ID. You need to:
1. Choose a different Bundle ID
2. Register it in Apple Developer portal
3. Update it in App Store Connect
4. Update it in Xcode

### "No signing identities found"

**Solution:**
1. Xcode → Settings → Accounts
2. Select your Apple ID
3. Click **Download Manual Profiles**
4. If still issues, try **Manage Certificates** → + → **Apple Development**

### "The app name you entered is already in use"

**Solution:** Try a variation:
- Add a space: `Movies I Miss`
- Add descriptive text: `MoviesIMiss - Rewatch Tracker`
- Add version: `MoviesIMiss 2`

### "Cannot connect to App Store Connect"

**Solution:**
- Check your internet connection
- Verify your Apple Developer account is active
- Try logging out and back in
- Check developer.apple.com for any account issues

### "Provisioning profile doesn't match"

**Solution:**
1. Make sure Bundle ID is EXACTLY the same in:
   - Apple Developer portal
   - App Store Connect
   - Xcode project
2. Clean build folder
3. Toggle automatic signing off and back on

---

## Quick Reference

### Important URLs:

- **Apple Developer:** https://developer.apple.com
- **App Store Connect:** https://appstoreconnect.apple.com
- **TestFlight:** Use the TestFlight app on iOS
- **Support:** https://developer.apple.com/support/

### Your App Details:

**Bundle ID:** `com.yourname.MoviesIMiss2` (replace `yourname`)  
**App Name:** MoviesIMiss2 (or your chosen name)  
**SKU:** moviesimiss2-v1  
**Version:** 1.0.0  
**Build:** 1  

---

## Next Steps

1. ✅ **App Store Connect is set up**
2. ✅ **Xcode project is configured**
3. 📦 **Next:** Create your first archive
4. 🚀 **Then:** Upload to TestFlight
5. 🧪 **Finally:** Test with real users

Continue with **TESTFLIGHT_DEPLOYMENT.md** for the upload process!

---

## Need Help?

- Check **TESTFLIGHT_DEPLOYMENT.md** for full deployment guide
- Check **PRE_TESTFLIGHT_CHECKLIST.md** for verification checklist
- Apple Developer Support: https://developer.apple.com/support/

Good luck! 🎬
