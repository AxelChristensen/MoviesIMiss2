# Quick Build Fix

## Issue 1: BugsAndImprovements.txt in Build Target

**Error:** `Unexpected input file: BugsAndImprovements.txt`

**Fix:**
1. In Xcode, select `BugsAndImprovements.txt` in Project Navigator
2. Open File Inspector (⌥⌘1 or View → Inspectors → File)
3. Under **Target Membership**
4. **UNCHECK** the MoviesIMiss2 target
5. The file will stay in your project but won't be included in the build

**Do the same for ALL .txt and .md files:**
- BugsAndImprovements.txt
- All .md documentation files
- Any other non-code files

## Issue 2: CachedAsyncImage Ambiguity

The ImageCache has conflicting initializers. Use the simpler version below.

**Replace ImageCache.swift with this corrected version:**

Save and rebuild!
