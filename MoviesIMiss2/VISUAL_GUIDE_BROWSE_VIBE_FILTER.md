# Visual Guide - Browse Search Vibe Filtering

## Before & After Comparison

### BEFORE: Search Results Without Vibe Filtering

```
┌─────────────────────────────────────────┐
│  Browse                                 │
│  🔍 Search Results                      │
├─────────────────────────────────────────┤
│                                         │
│  Search: "inception"                    │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 🎬  Inception                   │   │
│  │     2010 • ⭐ 8.8               │   │
│  │     A thief who steals...       │   │
│  │     [+]                         │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 🎬  Inception: The Cobol Job    │   │
│  │     2010 • ⭐ 7.2               │   │
│  │     Documentary short...        │   │
│  │     [+]                         │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘

Problem: Hard to tell which movies you've 
already saved with specific vibes
```

---

### AFTER: Search Results WITH Vibe Filtering

```
┌─────────────────────────────────────────┐
│  Browse                                 │
│  🔍 Search Results                      │
├─────────────────────────────────────────┤
│                                         │
│  Search: "inception"                    │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ [All] [Cozy 🔥] [Intense ⚡]    │   │ ← NEW!
│  │ [Fun ⭐] [Uplifting 💚]         │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 🎬  Inception                   │   │
│  │     2010 • ⭐ 8.8               │   │
│  │     A thief who steals...       │   │
│  │     [+]                         │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 🎬  Inception: The Cobol Job    │   │
│  │     2010 • ⭐ 7.2               │   │
│  │     Documentary short...        │   │
│  │     [+]                         │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘

Solution: Filter bar shows all vibes you've used
Default shows ALL search results
```

---

### WITH FILTER ACTIVE: "Intense" Selected

```
┌─────────────────────────────────────────┐
│  Browse                                 │
│  🔍 Search Results                      │
├─────────────────────────────────────────┤
│                                         │
│  Search: "inception"                    │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ [All] [Cozy 🔥] [Intense ⚡]    │   │ ← "Intense"
│  │ [Fun ⭐] [Uplifting 💚]         │   │   SELECTED
│  └─────────────────────────────────┘   │   (filled red)
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 🎬  Inception                   │   │ ← ONLY shows
│  │     2010 • ⭐ 8.8               │   │   because you've
│  │     A thief who steals...       │   │   saved it with
│  │     [+]                         │   │   "Intense" vibe
│  └─────────────────────────────────┘   │
│                                         │
│  (Cobol Job documentary hidden)        │
│                                         │
└─────────────────────────────────────────┘

Result: Shows ONLY search results you've 
saved with "Intense" vibe
```

---

### EMPTY STATE: Filter Returns No Results

```
┌─────────────────────────────────────────┐
│  Browse                                 │
│  🔍 Search Results                      │
├─────────────────────────────────────────┤
│                                         │
│  Search: "batman"                       │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ [All] [Cozy 🔥] [Intense ⚡]    │   │ ← "Cozy"
│  │ [Fun ⭐] [Uplifting 💚]         │   │   SELECTED
│  └─────────────────────────────────┘   │
│                                         │
│                                         │
│           🔽                            │
│                                         │
│    No Saved Movies with This Vibe      │
│                                         │
│    These search results don't include  │
│    any movies you've saved with the    │
│    "Cozy" vibe                         │
│                                         │
│       [Show All Results]                │
│                                         │
│                                         │
└─────────────────────────────────────────┘

Helpful empty state explains WHY it's empty
and offers quick way to see all results
```

---

## UI Component Details

### Vibe Filter Pill States

#### "All" Button
```
Unselected:          Selected (default):
┌──────────┐        ┌──────────┐
│   All    │        │   All    │
└──────────┘        └──────────┘
Gray bg             Blue bg
Dark text           White text
```

#### Vibe Pills
```
Unselected:          Selected:
┌──────────────┐    ┌──────────────┐
│ 🔥 Cozy      │    │ 🔥 Cozy      │
└──────────────┘    └──────────────┘
Light orange bg     Solid orange bg
Orange text         White text
(15% opacity)       (100% opacity)
```

### Filter Bar Layout

```
┌────────────────────────────────────────────────────┐
│ ← scroll                                  scroll → │
│                                                    │
│  [All] [Cozy 🔥] [Intense ⚡] [Fun ⭐] ...        │
│    ↑         ↑           ↑          ↑             │
│   12pt    spacing    between     pills            │
│                                                    │
│  ← 16pt padding                    padding 16pt → │
└────────────────────────────────────────────────────┘
    8pt padding top/bottom
```

---

## Complete User Flow Example

### Scenario: "Did I already save Inception as intense?"

```
Step 1: Search
┌─────────────────┐
│ 🔍 inception    │ ← Type search
└─────────────────┘

Step 2: See Results + Filter Bar
┌─────────────────────────────────┐
│ [All] [Cozy] [Intense] [Fun]    │ ← Filter appears
│                                 │
│ 🎬 Inception (2010)             │
│ 🎬 Inception: Cobol Job (2010)  │
└─────────────────────────────────┘

Step 3: Tap "Intense"
┌─────────────────────────────────┐
│ [All] [Cozy] [Intense] [Fun]    │ ← Intense highlighted
│                ^                │
│                RED FILL         │
│                                 │
│ 🎬 Inception (2010)             │ ← YES! Shows up
└─────────────────────────────────┘
Result: You HAVE saved Inception with "Intense" vibe!

Step 4: Tap "Cozy" Instead
┌─────────────────────────────────┐
│ [All] [Cozy] [Intense] [Fun]    │ ← Cozy highlighted
│         ^                       │
│      ORANGE FILL                │
│                                 │
│   No Saved Movies with          │
│   This Vibe                     │
│                                 │
│   [Show All Results]            │
└─────────────────────────────────┘
Result: You have NOT saved Inception as "Cozy"
```

---

## State Transitions

### From Browse Mode → Search Mode

```
BROWSE MODE (No Search)
┌─────────────────────────────────┐
│  Browse                         │
│  🔍 [search bar]                │
│  [2020s ▾] [Top Rated ▾] [↻]   │ ← Toolbar visible
│                                 │
│  Curated Movie List             │
└─────────────────────────────────┘

         ↓ Type "inception"

SEARCH MODE (With Vibes)
┌─────────────────────────────────┐
│  Search Results                 │
│  🔍 inception                   │
│  (toolbar hidden)               │
│                                 │
│  [All] [Cozy] [Intense]         │ ← Filter appears!
│                                 │
│  Search results...              │
└─────────────────────────────────┘

         ↓ Clear search

BROWSE MODE (Returns)
┌─────────────────────────────────┐
│  Browse                         │
│  🔍 [search bar]                │
│  [2020s ▾] [Top Rated ▾] [↻]   │ ← Toolbar back
│                                 │
│  Curated Movie List             │
└─────────────────────────────────┘
```

---

## Color Coding Reference

### Vibe Colors in Filter Pills

```
🔥 Cozy          → Orange
⚡ Intense        → Red
💚 Uplifting      → Green
🕰️  Nostalgic     → Purple
🧠 Thought-Prov.  → Blue
💗 Emotional      → Pink
⭐ Fun            → Yellow
🌙 Dark           → Indigo
✨ Inspiring      → Cyan
🍃 Relaxing       → Mint
```

### State Colors

```
"All" selected    → Blue
"All" unselected  → Gray (20% opacity)
Vibe selected     → Full vibe color
Vibe unselected   → Vibe color (15% opacity)
```

---

## Responsive Behavior

### On iPhone (Portrait)

```
┌───────────────────────┐
│ Browse                │
│ 🔍 inception          │
│                       │
│ ← [All] [Cozy] ... →  │ ← Scroll
│                       │
│ ┌───────────────────┐ │
│ │ 🎬 Inception      │ │
│ │    2010           │ │
│ │    ...            │ │
│ └───────────────────┘ │
│                       │
│ ┌───────────────────┐ │
│ │ ...               │ │
│ └───────────────────┘ │
└───────────────────────┘

Single column
Horizontal scroll for vibes
```

### On iPad / Large Screen

```
┌─────────────────────────────────────────────────┐
│ Browse                                          │
│ 🔍 inception                                    │
│                                                 │
│ [All] [Cozy 🔥] [Intense ⚡] [Fun ⭐] [Upli... │
│                                                 │
│ ┌──────────────┐  ┌──────────────┐            │
│ │ 🎬 Inception │  │ 🎬 Inception:│            │
│ │    2010      │  │    Cobol Job │            │
│ │    ...       │  │    ...       │            │
│ └──────────────┘  └──────────────┘            │
└─────────────────────────────────────────────────┘

Multiple columns
More vibes visible without scrolling
```

---

## Animation & Interaction

### Tap Behavior

```
1. Tap unselected vibe:
   ┌──────────┐  →  ┌──────────┐
   │ 🔥 Cozy  │  →  │ 🔥 Cozy  │
   └──────────┘     └──────────┘
   Light bg         Solid bg (animate)
   
2. Tap selected vibe (deselect):
   ┌──────────┐  →  ┌──────────┐
   │ 🔥 Cozy  │  →  │ 🔥 Cozy  │
   └──────────┘     └──────────┘
   Solid bg         Light bg (animate)
   
3. Results update instantly (no loading)
```

### Scroll Behavior

```
Filter bar:
- Horizontal scroll
- No vertical scroll
- Bounces at edges
- Shows partial pills at edges

Results:
- Vertical scroll
- Lazy loading
- Smooth animations
```

---

## Perfect For

✅ **Quick verification** - "Did I save this with that vibe?"  
✅ **Cross-reference** - Match search with your collection  
✅ **Avoid duplicates** - Check before adding  
✅ **Mood-based discovery** - Find saved movies by feeling  
✅ **Collection management** - See what you've curated  

---

**The filter bar appears magically when you search, making it effortless to cross-reference your vibe-tagged collection!** 🎬✨
