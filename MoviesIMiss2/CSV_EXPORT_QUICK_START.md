# CSV Export - Quick Start Card

## 🎯 Goal
Export all your saved movies to a CSV file you can open in Excel, Numbers, or Google Sheets.

## ⚡ 3 Steps to Success

### 1️⃣ Add CSVLogger to Xcode
```
Right-click project → "Add Files..." → Select CSVLogger.swift
```

### 2️⃣ Add Export Button to Your UI
```swift
NavigationLink("Export Movies") {
    DebugSettingsView()
}
```

### 3️⃣ Run and Test
```
Build → Run → Tap "Export All Movies to CSV" → Share/Save
```

## 📋 What You Get

CSV with all your movie data:
- ✅ Titles, years, status
- ✅ Watch dates (added, last watched, next rewatch)
- ✅ **All your vibes and mood notes**
- ✅ Overview and poster paths
- ✅ TMDB IDs

## 🔧 If Build Fails

**Error: "Cannot find CSVLogger"**
→ Add `CSVLogger.swift` to Xcode project

**Error: "Invalid redeclaration of MovieListView"**
→ Remove `INTEGRATION_EXAMPLE.swift` from build target

**Any other errors:**
→ Clean build (⇧⌘K) then rebuild (⌘B)

## 📖 Full Documentation

- `BUILD_FIX_SUMMARY.md` - Detailed fix instructions
- `README_CSV_EXPORT.md` - Complete setup guide
- `INTEGRATION_EXAMPLE.swift` - Code examples
- `CSV_EXPORT_GUIDE.md` - User guide

## 💡 Integration Examples

**Settings Menu:**
```swift
Section("Data") {
    NavigationLink("Export Movies") {
        DebugSettingsView()
    }
}
```

**Toolbar Button:**
```swift
.toolbar {
    Button("Export") { showingExport = true }
}
.sheet(isPresented: $showingExport) {
    NavigationStack { DebugSettingsView() }
}
```

**Menu Option:**
```swift
Menu {
    Button("Export to CSV") { showingExport = true }
} label: {
    Label("More", systemImage: "ellipsis.circle")
}
```

## ✅ Checklist

- [ ] `CSVLogger.swift` added to Xcode project
- [ ] `INTEGRATION_EXAMPLE.swift` removed from build or deleted
- [ ] Project builds successfully (⌘B)
- [ ] Export UI added (NavigationLink or Button)
- [ ] Tested export with sample movies
- [ ] Opened CSV in spreadsheet app

---

**That's it!** You now have full CSV export capability. 🎬📊
