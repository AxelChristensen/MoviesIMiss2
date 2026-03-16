# IMMEDIATE DEBUGGING STEPS - No Console Output

## 🚨 Problem: No console output when adding movies

This means the code isn't running at all. Follow these steps:

## Step 1: CLEAN BUILD (CRITICAL)

**You MUST do a clean build for changes to take effect:**

```
1. Xcode → Product → Clean Build Folder (Cmd+Shift+K)
2. Wait for it to complete
3. Xcode → Product → Build (Cmd+B)
4. Wait for successful build
5. Xcode → Product → Run (Cmd+R)
```

**Why this matters:** Xcode sometimes caches old code. A clean build ensures you're running the latest code with all the logging.

## Step 2: Verify Console is Visible

1. In Xcode, open the console: **View → Debug Area → Show Debug Area** (Cmd+Shift+Y)
2. Bottom right of Xcode should show console output
3. Make sure console filter isn't hiding output (click the filter icon and ensure it's set to "All Output")

## Step 3: Add a Movie and Watch Console

When you add a movie, you should see this EXACT output in console:

### When you select rewatch interval:
```
📅 === SETTING REWATCH INTERVAL ===
   Selected: TEST: In 1 Minute
   Calculated date: Mar 15, 2026 at 3:46 PM
   nextRewatchDate is now: Mar 15, 2026 at 3:46 PM
=================================
```

### When you tap "Add":
```
🎬 === SAVING MOVIE ===
   Title: Forrest Gump
   Has Seen Before: true
   Next Rewatch Date: Mar 15, 2026 at 3:46 PM
✅ Set rewatch date on movie: Mar 15, 2026 at 3:46 PM
✅ Movie saved to database
🔔 Attempting to schedule notification for Forrest Gump at Mar 15, 2026 at 3:46 PM

🔔 === SCHEDULING NOTIFICATION ===
   Movie: Forrest Gump
   TMDB ID: 13
   Authorization Status: 1
   Rewatch Date: Mar 15, 2026 at 3:46 PM
   Identifier: rewatch-13
   Trigger Components: year: 2026 month: 3 day: 15 hour: 15 minute: 46 second: 0 nanosecond: 0
✅ Successfully scheduled notification!
✅ Verified notification in pending list
   Next trigger: Mar 15, 2026 at 3:46 PM
=================================

=== END SAVING MOVIE ===
```

## If You See NO Console Output:

### Issue 1: App Not Running Latest Code
**Solution:** Clean build folder and rebuild (see Step 1)

### Issue 2: Console Filter Hiding Output
**Solution:** 
1. Look at bottom right corner of Xcode console
2. Find the filter field (search box)
3. Make sure it's empty
4. Click the filter icon (funnel) and select "All Output"

### Issue 3: Wrong Target/Scheme Selected
**Solution:**
1. Top left of Xcode, check scheme dropdown
2. Should show "MoviesIMiss2" 
3. Select your device or simulator next to it

### Issue 4: App Crashed Silently
**Solution:**
1. Check Xcode for crash logs
2. Look for red errors in Issue Navigator (Cmd+4)
3. Rebuild app

## If Console Shows Some Output But Not All:

### You see "SETTING REWATCH INTERVAL" but not "SAVING MOVIE"
→ The Add button might not be calling saveMovie()
→ Try tapping Add again
→ Check if there are any errors in console

### You see "SAVING MOVIE" but "Next Rewatch Date: nil"
→ The date isn't being set correctly
→ Make sure you selected a rewatch interval from the menu
→ Try "TEST: In 1 Minute" specifically

### You see "SAVING MOVIE" with date but no "SCHEDULING NOTIFICATION"
→ The notification code isn't being reached
→ This shouldn't happen - would indicate a Swift issue
→ Rebuild app completely

## Step 4: Test Without Movie

If nothing else works, test the notification system directly:

1. Go to **Debug tab**
2. Tap **"Test Notification (5 seconds)"**
3. Watch console - should see:
   ```
   ✅ Test notification scheduled for 5 seconds from now
   ```
4. Background app and wait

**If this works:** The notification system is fine, problem is with movie integration
**If this doesn't work:** Notification system isn't set up properly

## Step 5: Verify Files Exist

Make sure these files exist in your project:

1. Open Project Navigator (Cmd+1)
2. Search for "NotificationManager.swift"
3. Search for "NotificationDebugView.swift"
4. If either is missing, the files weren't added to the project

**To add missing files:**
1. Right-click project folder
2. Add Files to "MoviesIMiss2"
3. Select the missing .swift files
4. Ensure "Add to targets" has MoviesIMiss2 checked

## Step 6: Check for Build Errors

1. Open Issue Navigator (Cmd+4)
2. Look for any warnings or errors
3. Build errors will prevent new code from running
4. Common error: "Cannot find 'NotificationManager' in scope"
   → File not added to project, see Step 5

## Quick Diagnostic Checklist

Run through this checklist:

- [ ] Did clean build (Cmd+Shift+K)
- [ ] Built successfully (Cmd+B)
- [ ] App is running (Cmd+R)
- [ ] Console is visible (Cmd+Shift+Y)
- [ ] Console filter is set to "All Output"
- [ ] Tapped "I've seen this before" toggle
- [ ] Selected "TEST: In 1 Minute" from menu
- [ ] Tapped "Add" button
- [ ] Watching console output in Xcode

## Expected Timeline of Events

Here's when you should see console output:

**1. App Launch:**
```
📱 Notification Status: [status]
```

**2. When you tap rewatch menu and select option:**
```
📅 === SETTING REWATCH INTERVAL ===
```

**3. When you tap "Add" button:**
```
🎬 === SAVING MOVIE ===
```

**4. Immediately after saving:**
```
🔔 === SCHEDULING NOTIFICATION ===
```

If any of these are missing, that's where the problem is.

## Nuclear Option: Start Fresh

If nothing works:

1. **Quit Xcode completely**
2. **Delete DerivedData:**
   - Xcode → Preferences → Locations
   - Click arrow next to DerivedData path
   - Delete the "MoviesIMiss2" folder
3. **Reopen project in Xcode**
4. **Clean build folder** (Cmd+Shift+K)
5. **Build and run** (Cmd+R)

## Still Nothing?

If you still see no console output after all this:

**Share this information:**
1. Screenshot of Project Navigator showing files
2. Screenshot of scheme/target selector (top left of Xcode)
3. Screenshot of console area
4. Any build warnings or errors from Issue Navigator (Cmd+4)
5. Are you running on simulator or device?

## Most Likely Cause

**95% of "no console output" issues are caused by:**
1. Not doing a clean build after code changes
2. Console filter hiding output
3. Running old cached version of app

**Solution:** Do a clean build NOW before anything else!

```
Cmd+Shift+K → Cmd+B → Cmd+R
```

Then try adding a movie and watch the console closely. You SHOULD see output if you've done the clean build correctly.
