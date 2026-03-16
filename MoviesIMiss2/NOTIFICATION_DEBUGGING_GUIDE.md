# Debugging Movie Rewatch Notifications

This guide will help you test and debug the notification system for rewatch reminders.

## What Was Added

### 1. **NotificationManager.swift**
A centralized manager for handling all notification operations:
- Request notification permissions
- Schedule/cancel notifications for movies
- Debug and inspect pending notifications

### 2. **NotificationDebugView.swift**
A dedicated debug interface accessible from the Debug tab:
- View notification permission status
- See all pending notifications
- Test notification scheduling
- Reschedule or cancel notifications

### 3. **Updated ActorSearchView.swift**
The `saveMovie()` method now schedules notifications when a rewatch date is set.

### 4. **Updated MoviesIMiss2App.swift**
Requests notification permission on app launch.

## How to Debug Notifications

### Step 1: Grant Notification Permission

1. **Run your app** on a real device or simulator
2. On first launch, you should see a permission alert
3. Tap **Allow** to grant notification permissions
4. Go to the **Debug** tab to verify status shows "Authorized"

> **Note:** If you accidentally denied permissions, go to Settings → MoviesIMiss2 → Notifications and enable them manually.

### Step 2: Add a Movie with a Rewatch Date

1. Go to the **Actors** tab
2. Search for an actor (e.g., "Tom Hanks")
3. Tap on an actor to see their movies
4. Tap a movie to open the Add Movie sheet
5. Toggle "I've seen this before"
6. In the "Rewatch Reminder" section:
   - Tap the menu to set a rewatch interval
   - For quick testing, choose "Next Week" or use "Custom Date" and pick tomorrow
7. Tap **Add** to save the movie

**Console Output:** You should see:
```
✅ Scheduled notification for [Movie Title] on [Date]
```

### Step 3: Verify Notification Was Scheduled

Go to the **Debug** tab and check:

1. **Pending Notifications** count should increase by 1
2. Tap **Print to Console** to see detailed information about scheduled notifications
3. Look for your movie in the "Movies with Rewatch Dates" section

**Expected Console Output:**
```
=== PENDING NOTIFICATIONS (1) ===

📬 rewatch-12345
   Title: Time to Rewatch!
   Body: It's time to watch "[Movie Title]" again 🎬
   Scheduled: Mar 22, 2026 at 12:00 AM
   Time until: 7 days, 0 hours
===========================
```

### Step 4: Test Immediate Notifications

To test notifications without waiting days/weeks:

1. Go to the **Debug** tab
2. Tap **Test Notification (5 seconds)**
3. Background the app (press home button or switch apps)
4. Wait 5 seconds
5. You should see a notification appear!

> **Important:** Notifications only appear when the app is in the background or closed. They won't show while the app is active in the foreground.

### Step 5: Test with a Near-Future Date

For more realistic testing:

1. Add a movie with a custom rewatch date set to **1 minute from now**
2. Background your app
3. Wait 1 minute
4. You should receive a notification

### Step 6: Debug Common Issues

#### Issue: No notification appears

**Check:**
1. ✅ Notification permission is "Authorized" (Debug tab)
2. ✅ Pending notification count is > 0 (Debug tab)
3. ✅ App is backgrounded (notifications don't show in foreground)
4. ✅ Device is not in Do Not Disturb mode
5. ✅ Wait the full duration (system may delay by a few seconds)

**Solution:** Tap "Print to Console" in Debug tab and verify:
- The notification trigger date matches what you expect
- The identifier starts with "rewatch-"

#### Issue: Permission status shows "Denied"

**Solution:**
1. Go to iOS Settings app
2. Scroll down to MoviesIMiss2
3. Tap **Notifications**
4. Enable "Allow Notifications"
5. Return to app and check Debug tab

#### Issue: Notification scheduled but count is 0

**Solution:**
- The rewatch date might be in the past
- Notifications are only scheduled for future dates
- Check the console for warnings:
  ```
  ⚠️ Rewatch date is in the past for [Movie Title]
  ```

### Step 7: Test Notification Actions

1. Schedule a notification for 5 seconds
2. Background the app
3. When notification appears, tap it
4. App should open (handling the tap can be added later)

## Debugging Commands

### Print All Pending Notifications

In the Debug tab, tap **Print to Console**. This outputs:
- All scheduled notifications
- Their trigger dates
- Time remaining until each notification

### Reschedule All Notifications

If notifications seem out of sync:
1. Go to Debug tab
2. Tap **Reschedule All Notifications**
3. This cancels all existing notifications and recreates them

### Cancel All Notifications

To start fresh:
1. Go to Debug tab
2. Tap **Cancel All Notifications** (red button)
3. This removes all pending notifications

### Cancel Individual Movie Notification

In the Debug tab, under "Movies with Rewatch Dates":
1. Swipe left on a movie
2. Tap **Cancel** to remove its notification
3. Or tap **Reschedule** to recreate it

## Console Output Reference

### Successful Scheduling
```
✅ Scheduled notification for The Matrix on Mar 22, 2026 at 12:00 AM
```

### Permission Granted
```
✅ Notification permission granted
📱 Notification Status: Authorized
```

### Permission Denied
```
❌ Notification permission denied
📱 Notification Status: Denied
```

### No Rewatch Date
```
⚠️ No rewatch date set for The Matrix
```

### Past Date Warning
```
⚠️ Rewatch date is in the past for The Matrix
```

### Cancellation
```
🗑️ Cancelled notification for The Matrix
```

### Rescheduling
```
🔄 Rescheduling 5 notifications...
✅ Scheduled notification for Movie 1 on [Date]
✅ Scheduled notification for Movie 2 on [Date]
...
```

## Testing Checklist

Use this checklist to verify everything works:

- [ ] App requests notification permission on first launch
- [ ] Permission status shows "Authorized" in Debug tab
- [ ] Can add movie with rewatch date
- [ ] Pending notification count increases after adding movie
- [ ] Console shows "✅ Scheduled notification" message
- [ ] "Print to Console" shows notification details
- [ ] Test notification (5 seconds) appears when app is backgrounded
- [ ] Can cancel notification via swipe action
- [ ] Can reschedule individual notifications
- [ ] "Reschedule All" recreates all notifications
- [ ] "Cancel All" removes all notifications
- [ ] Movie appears in "Again!" tab with correct date
- [ ] Real notification appears at scheduled time

## Advanced Debugging

### Check System Notification Settings Programmatically

Add this to your debugging:
```swift
Task {
    let center = UNUserNotificationCenter.current()
    let settings = await center.notificationSettings()
    print("Authorization: \(settings.authorizationStatus.rawValue)")
    print("Alert: \(settings.alertSetting.rawValue)")
    print("Sound: \(settings.soundSetting.rawValue)")
    print("Badge: \(settings.badgeSetting.rawValue)")
}
```

### Simulate Time Passing (for Simulator)

Since you can't change the system time easily:
1. Use very short test intervals (5 seconds, 1 minute)
2. Or modify `RewatchInterval` to add a "In 30 Seconds" option for testing
3. The system may delay notifications slightly (this is normal)

### Watch Console During Scheduling

When you add a movie with a rewatch date, immediately check Xcode console for:
- Success/failure messages
- Error descriptions
- Scheduled date confirmation

## Real-World Testing

Once basic testing works, test realistic scenarios:

1. **Week-Long Test**
   - Schedule a movie for 7 days from now
   - Check pending notifications daily
   - Wait for the actual notification

2. **Multiple Movies**
   - Add 5 movies with different rewatch dates
   - Verify all notifications are scheduled
   - Confirm they appear at correct times

3. **App Updates**
   - Schedule notifications
   - Close app completely
   - Relaunch app
   - Verify notifications still exist

4. **App Restart**
   - Add movies with notifications
   - Force quit the app
   - Restart device
   - Verify notifications still fire

## Troubleshooting

### Notifications not appearing on device

1. Check Settings → Notifications → MoviesIMiss2
2. Ensure "Allow Notifications" is ON
3. Check delivery settings (Lock Screen, Notification Center, Banners)
4. Disable Focus modes temporarily
5. Ensure volume is up (for notification sound)

### Simulator vs Device differences

**Simulator:**
- Notifications work but may be delayed
- No banner/sound in some iOS versions
- Check Notification Center manually

**Device:**
- More reliable
- Shows actual banners and sounds
- Better for final testing

### Dates seem wrong

- Check device timezone vs notification timezone
- Verify `DateComponents` include time zone
- Use `.formatted()` for debugging date values

## Next Steps

After verifying notifications work:

1. **Handle Notification Taps**
   - Implement `UNUserNotificationCenterDelegate`
   - Open specific movie when notification is tapped
   - Mark movie as "watched" or "snoozed"

2. **Add Snooze Feature**
   - "Remind me tomorrow" action button
   - "I watched it" action button

3. **Notification Customization**
   - Add movie poster to notification (rich notifications)
   - Custom sounds per mood type
   - Notification grouping

4. **Background Refresh**
   - Reschedule notifications if dates change
   - Update notifications when movies are edited
   - Cancel notifications when movies are deleted

## Summary

You now have a complete notification debugging system:

✅ **NotificationManager** - Handles all notification logic  
✅ **NotificationDebugView** - Visual debugging interface  
✅ **Test notifications** - Verify system works immediately  
✅ **Console logging** - Detailed debugging output  
✅ **Manual controls** - Schedule/cancel/reschedule notifications  

Use the Debug tab as your primary tool for understanding what's happening with notifications!
