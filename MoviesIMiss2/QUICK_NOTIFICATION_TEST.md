# Quick Notification Testing Guide

## 🚀 Quick Start (3 Steps)

1. **Run the app** → Grant notification permission when prompted
2. **Go to Actors tab** → Search for actor → Add movie → Set rewatch to "TEST: In 1 Minute"
3. **Background the app** → Wait 1 minute → Notification appears! ✨

## 📱 Debug Tab Overview

The **Debug** tab (hammer icon) shows:

```
┌─────────────────────────────────────┐
│ Notification Permissions            │
│ Status: Authorized ✅               │
├─────────────────────────────────────┤
│ Pending Notifications               │
│ Total Scheduled: 3                  │
│ [Print to Console]                  │
├─────────────────────────────────────┤
│ Movies with Rewatch Dates           │
│ • The Matrix - In 7d                │
│ • Inception - In 30d                │
│ • Interstellar - In 1y              │
├─────────────────────────────────────┤
│ Quick Actions                       │
│ [Reschedule All Notifications]      │
│ [Cancel All Notifications]          │
├─────────────────────────────────────┤
│ Testing                             │
│ [Test Notification (5 seconds)]     │
│ [Test Notification (1 minute)]      │
└─────────────────────────────────────┘
```

## 🧪 Testing Methods

### Method 1: Quick Test (5 seconds)
```
Debug tab → Test Notification (5 seconds) → Background app → Wait
```
✅ Best for: Verifying notifications work at all

### Method 2: Near-Future Test (1 minute)
```
Add movie → Set rewatch to "TEST: In 1 Minute" → Background app → Wait
```
✅ Best for: Testing full workflow end-to-end

### Method 3: Real-World Test (Tomorrow)
```
Add movie → Custom Date → Pick tomorrow → Background app → Check tomorrow
```
✅ Best for: Final verification before release

## 📊 What to Check

| Check | Location | Expected Result |
|-------|----------|----------------|
| Permission | Debug tab → Status | "Authorized" (green) |
| Scheduled | Debug tab → Pending | Count matches movies added |
| Console | Xcode console | "✅ Scheduled notification..." |
| Appears | Lock screen | Notification banner appears |
| Content | Notification | Shows movie title correctly |

## 🔍 Console Messages to Look For

### ✅ Success
```
✅ Notification permission granted
📱 Notification Status: Authorized
✅ Scheduled notification for The Matrix on Mar 22, 2026
```

### ⚠️ Warnings
```
⚠️ No rewatch date set for Movie Title
⚠️ Rewatch date is in the past for Movie Title
```

### ❌ Errors
```
❌ Notification permission denied
❌ Failed to schedule test notification: [error]
```

## 🐛 Common Issues & Fixes

### Issue: Permission is "Denied"
**Fix:** Settings → MoviesIMiss2 → Notifications → Enable

### Issue: Notification doesn't appear
**Check:**
- App is backgrounded (not in foreground)
- Not in Do Not Disturb mode
- Wait full duration + a few extra seconds
- Check lock screen and notification center

### Issue: Count is 0 but movie has date
**Fix:** Rewatch date might be in past. Use "TEST: In 1 Minute" or tomorrow's date

### Issue: Notification appears without banner
**Fix:** Settings → Notifications → MoviesIMiss2 → Enable "Banners"

## ⚡ Quick Actions

### Print all notifications
```
Debug tab → Print to Console → Check Xcode console
```

### Reset everything
```
Debug tab → Cancel All Notifications → Start fresh
```

### Reschedule all
```
Debug tab → Reschedule All Notifications → Rebuilds all
```

### Cancel one movie
```
Debug tab → Swipe left on movie → Cancel
```

## 📝 Testing Checklist

```
□ Permission granted (shows "Authorized")
□ Add movie with "TEST: In 1 Minute"
□ Console shows "✅ Scheduled notification"
□ Pending count increased by 1
□ Print to Console shows notification details
□ Background app
□ Wait 1 minute
□ Notification appears on lock screen
□ Tap notification opens app
```

## 🎯 Pro Tips

1. **Always background the app** - Notifications only appear when app is not active
2. **Use TEST interval** - Don't wait weeks to test!
3. **Check console first** - Errors appear immediately in Xcode
4. **Test on device** - Simulators can be unreliable for notifications
5. **Watch the time** - Add a few seconds buffer for system delays
6. **Use Print to Console** - See exactly what's scheduled

## 📱 Simulator vs Device

**Simulator:**
- ✅ Works for basic testing
- ⚠️ May be delayed
- ⚠️ Banner might not appear
- ✅ Check Notification Center manually

**Device:**
- ✅✅ Best for testing
- ✅ Reliable banners and sounds
- ✅ Real-world behavior

## 🔄 Full Test Workflow

```
1. Launch app
   → Permission prompt appears → Allow

2. Go to Actors tab
   → Search "Tom Hanks"
   → Tap Tom Hanks
   → Tap "Forrest Gump"
   → Toggle "I've seen this before"
   → Tap rewatch menu
   → Select "TEST: In 1 Minute"
   → Tap Add

3. Check Debug tab
   → Status: Authorized ✅
   → Pending Notifications: 1
   → Tap "Print to Console"
   → Check Xcode console for details

4. Background app
   → Press home button
   → Wait 60 seconds

5. Notification appears! 🎉
   → "Time to Rewatch!"
   → "It's time to watch Forrest Gump again 🎬"
```

## 💡 Understanding the Code

### Where notifications are scheduled
```swift
// ActorSearchView.swift - saveMovie()
if nextRewatchDate != nil {
    Task {
        try? await NotificationManager.shared
            .scheduleRewatchNotification(for: savedMovie)
    }
}
```

### What gets scheduled
```swift
// NotificationManager.swift
content.title = "Time to Rewatch!"
content.body = "It's time to watch \"\(movie.title)\" again 🎬"
// Triggers at: movie.nextRewatchDate
```

### How to debug
```swift
// NotificationManager.swift
await notificationManager.printPendingNotifications()
// Prints all scheduled notifications with dates
```

## 🎓 Next Steps

After basic testing works:

1. **Test multiple movies** - Schedule 3-5 notifications
2. **Test editing** - Change rewatch date on existing movie
3. **Test deletion** - Delete movie, notification should cancel
4. **Test app restart** - Close app, restart, notifications still work
5. **Test device restart** - Restart device, notifications persist

## ❓ FAQ

**Q: Why don't notifications appear when app is open?**
A: iOS doesn't show notification banners when the app is active. This is normal behavior.

**Q: How long do I need to wait?**
A: For TEST options, wait exactly 5 seconds or 1 minute. Add 5-10 seconds buffer for system delays.

**Q: Can I change system time to test?**
A: Not recommended. Use TEST intervals or real short delays instead.

**Q: Do I need a real device?**
A: Simulator works but device is more reliable. Use simulator for quick checks, device for final testing.

**Q: What if permission is already denied?**
A: Must go to iOS Settings → MoviesIMiss2 → Notifications → Enable manually.

## 📞 Getting Help

If notifications still don't work:

1. Check Xcode console for error messages
2. Run "Print to Console" and verify notification exists
3. Try "Test Notification (5 seconds)" first
4. Verify not in Do Not Disturb mode
5. Check device notification settings
6. Try on a different device or clean simulator

---

**Remember:** Background the app before waiting for notifications! 🎬✨
