# Notification Not Working - Debugging Checklist

## 🔍 What to Check

Follow these steps in order to diagnose why notifications aren't being scheduled:

### Step 1: Check Console Output

When you add a movie with a rewatch date, you should see this in the Xcode console:

```
🔔 Attempting to schedule notification for [Movie Title] at [Date]

🔔 === SCHEDULING NOTIFICATION ===
   Movie: [Movie Title]
   TMDB ID: [number]
   Authorization Status: 1 (1 = authorized)
   Rewatch Date: [date]
   Identifier: rewatch-[id]
   Trigger Components: [components]
✅ Successfully scheduled notification!
✅ Verified notification in pending list
   Next trigger: [date]
=================================
```

**If you DON'T see this output:**
→ The `saveMovie()` function isn't being called or notification scheduling is failing silently

**If you see:**
```
❌ Notifications not authorized! Status: Not Determined (or Denied)
```
→ Permission hasn't been granted. Go to Step 2.

**If you see:**
```
⚠️ No rewatch date set, skipping notification
```
→ The rewatch date isn't being set properly. Go to Step 3.

### Step 2: Check Notification Permission

**In the app:**
1. Go to the **Debug tab**
2. Look at "Status" under "Notification Permissions"
3. Should say **"Authorized"** in green

**Expected statuses:**
- ✅ "Authorized" - Good! Notifications will work
- ⚠️ "Not Determined" - Tap "Request Permission" button
- ❌ "Denied" - Must enable in iOS Settings manually

**If permission is denied:**
1. Exit the app
2. Go to iOS **Settings** app
3. Scroll down to **MoviesIMiss2**
4. Tap **Notifications**
5. Enable "Allow Notifications"
6. Return to app and check Debug tab again

### Step 3: Verify Rewatch Date is Set

**Add a movie and check:**
1. Go to Actors tab
2. Search for actor
3. Tap a movie
4. Toggle "I've seen this before"
5. **Tap the rewatch menu** - should show:
   - TEST: In 1 Minute
   - Immediately
   - Next Week
   - etc.
6. Select "TEST: In 1 Minute"
7. **Check that the menu shows the date next to "When to watch again"**
8. Tap "Add"

**Check Debug tab:**
- Go to Debug tab
- Under "Movies with Rewatch Dates"
- Your movie should appear with "In 1m" or similar

**If movie doesn't appear:**
→ The rewatch date isn't being saved. Check console for errors.

### Step 4: Check Pending Notifications

**In Debug tab:**
1. Look at "Total Scheduled" under "Pending Notifications"
2. Should be **greater than 0** after adding a movie

**If count is 0:**
1. Tap "Print to Console"
2. Check Xcode console for output
3. Should list all pending notifications

**Expected console output:**
```
=== PENDING NOTIFICATIONS (1) ===

📬 rewatch-12345
   Title: Time to Rewatch!
   Body: It's time to watch "[Movie]" again 🎬
   Scheduled: [Date]
   Time until: 1 minutes
===========================
```

**If empty:**
→ Notification failed to schedule. Check console for errors from Step 1.

### Step 5: Test with Simple Test Notification

**Bypass movie system:**
1. Go to Debug tab
2. Scroll to "Testing" section
3. Tap "Test Notification (5 seconds)"
4. **Immediately press home** to background the app
5. Wait 5 seconds

**If test notification appears:**
→ System works! Problem is with movie scheduling logic

**If test notification doesn't appear:**
→ Permissions or system issue. See Step 6.

### Step 6: System Checks

**Verify:**
- [ ] App is running on iOS 16+ (notifications require UNUserNotificationCenter)
- [ ] Device is not in Do Not Disturb mode
- [ ] Device is not in Focus mode
- [ ] Notification settings allow Banners (Settings → Notifications → MoviesIMiss2 → Banners)
- [ ] App is backgrounded when waiting (notifications don't show in foreground)
- [ ] Wait a few extra seconds (system can delay slightly)

**Check device notification settings:**
1. Settings → Notifications → MoviesIMiss2
2. Verify:
   - Allow Notifications: **ON**
   - Lock Screen: **ON**
   - Notification Center: **ON**
   - Banners: **Temporary** or **Persistent**

### Step 7: Common Issues

#### Issue: "I added the movie but don't see it in Debug tab"

**Possible causes:**
- Didn't toggle "I've seen this before"
- Didn't select a rewatch interval
- Selected "Never" interval
- App crashed before saving

**Fix:**
1. Delete the movie (if it exists)
2. Add it again carefully
3. Toggle "I've seen this before" **first**
4. Select rewatch interval
5. Verify date appears next to menu
6. Tap Add
7. Check Debug tab immediately

#### Issue: "Permission shows 'Authorized' but count is 0"

**Possible causes:**
- Rewatch date is in the past
- Date calculation failed
- Silent error in scheduling

**Fix:**
1. Check Xcode console for error messages
2. Try Test Notification (5 seconds) - if that works, problem is in date calculation
3. Try "Immediately" interval instead of "TEST: In 1 Minute"
4. Use Debug tab → "Reschedule All Notifications"

#### Issue: "Console shows nothing when I add movie"

**Possible causes:**
- App wasn't built with latest changes
- Console filter is hiding output
- Wrong scheme/target selected

**Fix:**
1. Clean build folder (Cmd+Shift+K)
2. Build and run again
3. In Xcode console, check filter (should show all output)
4. Try Product → Clean Build Folder → Build again

#### Issue: "Notification scheduled but never appears"

**Possible causes:**
- App in foreground (notifications don't show)
- Time hasn't passed yet
- System delay
- Notification was dismissed

**Fix:**
1. Ensure app is backgrounded (press home)
2. Check notification center (swipe down from top)
3. Wait extra 10-20 seconds beyond scheduled time
4. Check lock screen
5. Restart device and try again

## 🎯 Quick Diagnostic

Run this quick test:

1. **Build and run** the latest code
2. **Check Debug tab** → Status should be "Authorized"
3. **Tap "Test Notification (5 seconds)"**
4. **Press home immediately**
5. **Wait 5 seconds**

**Result:**
- ✅ Notification appears → System works, check movie logic
- ❌ No notification → Permission/system issue

## 📋 Console Messages Reference

### Good Messages:
```
✅ Notification permission granted
📱 Notification Status: Authorized
🔔 Attempting to schedule notification for...
✅ Successfully scheduled notification!
✅ Verified notification in pending list
```

### Warning Messages:
```
⚠️ No rewatch date set, skipping notification
⚠️ Rewatch date is in the past for [Movie]
⚠️ Notification not found in pending list!
```

### Error Messages:
```
❌ Notification permission denied
❌ Notifications not authorized! Status: [status]
❌ Failed to schedule notification: [error]
```

## 🔧 Manual Reschedule

If movies have dates but no notifications:

1. Go to **Debug tab**
2. Verify movies appear under "Movies with Rewatch Dates"
3. Tap **"Reschedule All Notifications"**
4. Check console for scheduling output
5. Verify "Total Scheduled" count increased

## 💡 Pro Tips

1. **Always check console first** - It tells you exactly what's happening
2. **Use Test Notification** - Verifies system works before debugging movie logic
3. **Check Debug tab** - Visual confirmation of what's scheduled
4. **Background the app** - Critical for notifications to appear
5. **Wait extra time** - System may delay by 5-10 seconds

## 🆘 Still Not Working?

If you've tried everything:

1. **Copy console output** from adding a movie and share it
2. **Screenshot Debug tab** showing:
   - Permission status
   - Pending notification count
   - Movies with rewatch dates
3. **Check for errors** in Xcode Issues navigator (⌘+4)
4. **Try on different device** - Simulator vs real device
5. **Restart Xcode** - Sometimes necessary after code changes

## ✅ Success Checklist

When everything works, you should see:

- ✅ Debug tab shows "Authorized"
- ✅ Console shows "✅ Successfully scheduled notification!"
- ✅ Debug tab "Total Scheduled" > 0
- ✅ Movie appears in "Movies with Rewatch Dates"
- ✅ "Print to Console" shows notification details
- ✅ Test notification appears after 5 seconds
- ✅ Real notification appears at scheduled time
