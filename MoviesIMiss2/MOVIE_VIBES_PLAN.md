# Movie Vibes Feature - Implementation Plan

## User's Request
"When adding movies I've seen before I want to be able to add a 'vibe' that other users will be able to see when they find the movie"

## Current State
Your app has:
- ✅ `moodWhenWatched` - Local field for your mood
- ✅ `moodItHelpsWithString` - Local field for what mood it helps with
- ❌ No backend - Data stays on your device only
- ❌ No user accounts
- ❌ No sharing between users

## Implementation Options

### Option 1: Enhanced Local Vibes (Quick Win - No Backend)

**What it does:**
- Rename fields to be more "vibe-focused"
- Make vibes more prominent in UI
- Add preset vibe options (cozy, intense, uplifting, etc.)
- Store locally only

**Pros:**
- ✅ Can implement today
- ✅ No backend needed
- ✅ No ongoing costs
- ✅ Works offline
- ✅ Foundation for future social features

**Cons:**
- ❌ Not shared with other users
- ❌ Only you see your vibes

**Time:** 30 minutes
**Cost:** $0

---

### Option 2: Firebase Backend (Recommended for Social)

**What it does:**
- Add Firebase to your app
- Store vibes in Firestore
- Users can see vibes from other users
- Anonymous or authenticated users
- Real-time sync

**Pros:**
- ✅ Share vibes between users
- ✅ Real-time updates
- ✅ Free tier (good for starting)
- ✅ Easy to implement
- ✅ Handles user auth

**Cons:**
- ❌ Requires Firebase setup
- ❌ Costs money at scale
- ❌ TestFlight reviewers will see everyone's vibes
- ❌ Need moderation for inappropriate content

**Time:** 2-3 hours setup + implementation
**Cost:** Free for <50K reads/day, then $0.06 per 100K reads

**Implementation Steps:**
1. Create Firebase project
2. Add Firebase SDK to app
3. Create `MovieVibe` model
4. Add vibe submission UI
5. Fetch and display vibes from others
6. Add reporting/moderation

---

### Option 3: Custom Backend

**What it does:**
- Build your own API
- Full control over data
- Custom features

**Pros:**
- ✅ Complete control
- ✅ No vendor lock-in
- ✅ Custom features

**Cons:**
- ❌ Complex to build
- ❌ Requires server hosting
- ❌ Need to maintain
- ❌ Higher costs
- ❌ Longer development time

**Time:** Days to weeks
**Cost:** $5-50+/month hosting

---

## Recommended Approach

### Phase 1: Local Vibes (Now)
Implement enhanced local vibes today:
- Add "vibe" field to SavedMovie
- Create vibe picker UI with presets
- Show vibes in movie details
- Beautiful vibe tags/chips

**Benefits:**
- Ships with TestFlight immediately
- No backend complexity
- Users get value now
- Foundation for Phase 2

### Phase 2: Social Vibes (Later)
Add Firebase backend when ready:
- Migrate local vibes to cloud
- Show community vibes
- Vote on vibes
- Anonymous or sign-in

---

## Phase 1 Implementation: Local Vibes

### 1. Update SavedMovie Model

Add a dedicated vibe field:

```swift
@Model
final class SavedMovie {
    // ... existing fields
    var personalVibe: String? // "cozy", "intense", "uplifting", etc.
    var vibeNotes: String?    // Optional free-form notes
}
```

### 2. Create Vibe Presets

```swift
enum MovieVibe: String, CaseIterable, Identifiable {
    case cozy = "Cozy"
    case intense = "Intense"
    case uplifting = "Uplifting"
    case nostalgic = "Nostalgic"
    case thoughtProvoking = "Thought-Provoking"
    case emotional = "Emotional"
    case fun = "Fun"
    case dark = "Dark"
    case inspiring = "Inspiring"
    case relaxing = "Relaxing"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .cozy: return "flame.fill"
        case .intense: return "bolt.fill"
        case .uplifting: return "arrow.up.heart.fill"
        case .nostalgic: return "clock.arrow.circlepath"
        case .thoughtProvoking: return "brain.head.profile"
        case .emotional: return "heart.fill"
        case .fun: return "star.fill"
        case .dark: return "moon.fill"
        case .inspiring: return "sparkles"
        case .relaxing: return "leaf.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .cozy: return .orange
        case .intense: return .red
        case .uplifting: return .green
        case .nostalgic: return .purple
        case .thoughtProvoking: return .blue
        case .emotional: return .pink
        case .fun: return .yellow
        case .dark: return .indigo
        case .inspiring: return .cyan
        case .relaxing: return .mint
        }
    }
}
```

### 3. Vibe Picker UI

```swift
struct VibePicker: View {
    @Binding var selectedVibe: String?
    
    let vibes = MovieVibe.allCases
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What's the vibe?")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(vibes) { vibe in
                    VibeButton(
                        vibe: vibe,
                        isSelected: selectedVibe == vibe.rawValue
                    ) {
                        if selectedVibe == vibe.rawValue {
                            selectedVibe = nil
                        } else {
                            selectedVibe = vibe.rawValue
                        }
                    }
                }
            }
        }
    }
}

struct VibeButton: View {
    let vibe: MovieVibe
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: vibe.icon)
                    .font(.title2)
                Text(vibe.rawValue)
                    .font(.caption)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? vibe.color.opacity(0.2) : Color.gray.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? vibe.color : Color.clear, lineWidth: 2)
            )
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}
```

### 4. Display Vibes in UI

Show vibes in movie detail views:

```swift
if let vibeString = movie.personalVibe,
   let vibe = MovieVibe(rawValue: vibeString) {
    HStack {
        Image(systemName: vibe.icon)
            .foregroundStyle(vibe.color)
        Text(vibe.rawValue)
            .font(.subheadline)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
    .background(vibe.color.opacity(0.15))
    .cornerRadius(20)
}
```

---

## Phase 2 Implementation: Social Vibes (Future)

### 1. Firebase Setup

**Create Firebase Project:**
1. Go to firebase.google.com
2. Create new project
3. Add iOS app
4. Download GoogleService-Info.plist
5. Add Firebase SDK to Xcode

### 2. Data Model

```swift
struct CommunityVibe: Codable, Identifiable {
    var id: String = UUID().uuidString
    var tmdbId: Int           // Movie ID
    var vibe: String          // Vibe type
    var notes: String?        // Optional notes
    var userId: String        // Anonymous or auth
    var timestamp: Date
    var upvotes: Int          // Community voting
}
```

### 3. Firestore Structure

```
movies/
  └─ {tmdbId}/
      └─ vibes/
          └─ {vibeId}
              ├─ vibe: "cozy"
              ├─ notes: "Perfect winter movie"
              ├─ userId: "anonymous_123"
              ├─ timestamp: Date
              └─ upvotes: 5
```

### 4. Vibe Service

```swift
class VibeService {
    static let shared = VibeService()
    private let db = Firestore.firestore()
    
    func addVibe(tmdbId: Int, vibe: String, notes: String?) async throws {
        let vibeData: [String: Any] = [
            "vibe": vibe,
            "notes": notes ?? "",
            "userId": getAnonymousUserId(),
            "timestamp": Timestamp(date: Date()),
            "upvotes": 0
        ]
        
        try await db.collection("movies")
            .document("\(tmdbId)")
            .collection("vibes")
            .addDocument(data: vibeData)
    }
    
    func fetchVibes(tmdbId: Int) async throws -> [CommunityVibe] {
        let snapshot = try await db.collection("movies")
            .document("\(tmdbId)")
            .collection("vibes")
            .order(by: "upvotes", descending: true)
            .limit(to: 20)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: CommunityVibe.self)
        }
    }
}
```

---

## User Experience

### Adding a Vibe (Local Version)
```
1. Search for movie (e.g., "The Grand Budapest Hotel")
2. Tap to add
3. Toggle "I've seen this before"
4. See "What's the vibe?" section
5. Tap chips: Cozy ☕ | Fun ✨ | Nostalgic 🕰️
6. Select "Cozy"
7. Optionally add notes
8. Add movie
```

### Adding a Vibe (Social Version)
```
Same as above, plus:
9. Vibe syncs to Firebase
10. Other users can see it
11. Users can upvote vibes they agree with
```

### Viewing Vibes (Social Version)
```
1. Browse movie in "New!" list
2. See "Community Vibes" section
3. See: 
   - Cozy ☕ (12 people)
   - Nostalgic 🕰️ (8 people)
   - Fun ✨ (5 people)
4. Tap to see notes from others
```

---

## Privacy & Moderation

### For Social Version:

**User Privacy:**
- Anonymous by default
- Optional sign-in for reputation
- No personal data required

**Content Moderation:**
- Limit notes to 280 characters
- Profanity filter
- Report button
- Admin review for flagged content

**Security Rules (Firebase):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /movies/{movie}/vibes/{vibe} {
      allow read: if true;
      allow create: if request.resource.data.notes.size() < 280;
      allow update: if false; // No editing after post
      allow delete: if false; // Only admins
    }
  }
}
```

---

## Cost Estimates (Social Version)

### Firebase Free Tier:
- 50K document reads/day
- 20K document writes/day
- 20K document deletes/day
- 1GB storage

**Likely usage:**
- 100 TestFlight users
- ~1000 movies viewed/day = 1000 reads
- ~50 vibes added/day = 50 writes
- **Well within free tier** ✅

### Paid Tier (if you scale):
- $0.06 per 100K document reads
- $0.18 per 100K document writes
- $0.02 per 100K document deletes

---

## Recommendation

**Start with Phase 1 (Local Vibes):**
1. Implement today
2. Ship with TestFlight
3. Get user feedback
4. See if people use it

**Evaluate Phase 2 (Social) later:**
- If users love vibes → add Firebase
- If not used much → keep it local
- Can always migrate later

---

## Next Steps

**Want me to implement Phase 1 (Local Vibes)?**

I can:
1. Add `personalVibe` field to SavedMovie
2. Create MovieVibe enum with presets
3. Build VibePicker UI component
4. Add to AddMovieSheet
5. Display vibes in movie lists

This takes ~30 minutes and requires no backend!

**Or want to go straight to Phase 2 (Social)?**

I can:
1. Create Firebase setup guide
2. Build vibe sync service
3. Add community vibe display
4. Implement upvoting

This takes ~2-3 hours and requires Firebase account.

---

**Which would you like to do?** 🎬
