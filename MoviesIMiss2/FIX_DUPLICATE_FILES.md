# URGENT: Fix Build Errors - Duplicate Files

## The Problem

You have **duplicate copies** of `APIKeySetupView.swift` in your Xcode project:
- `APIKeySetupView.swift` (old version)
- `APIKeySetupView 2.swift` (old version)  
- `APIKeySetupView 3.swift` (newest, correct version)

This is causing "Invalid redeclaration" and "Ambiguous use of 'init()'" errors.

---

## Quick Fix (5 minutes)

### Step 1: Delete Duplicate Files

In Xcode Project Navigator:

1. **Find and DELETE** these files:
   - ❌ `APIKeySetupView.swift` (the old one)
   - ❌ `APIKeySetupView 2.swift` (the old one)
   
2. **How to delete:**
   - Right-click the file
   - Select **"Delete"**
   - Choose **"Move to Trash"** (NOT "Remove Reference")

3. **KEEP this file:**
   - ✅ `APIKeySetupView 3.swift` (the newest one with fixes)

### Step 2: Rename the Correct File

1. Right-click `APIKeySetupView 3.swift`
2. Select **Rename**
3. Rename it to just: `APIKeySetupView.swift` (remove the "3")

### Step 3: Verify KeychainHelper

Make sure you have exactly **ONE** `KeychainHelper.swift` file in your project.
- If you see duplicates, delete all but one

### Step 4: Clean and Rebuild

```
1. Product → Clean Build Folder (⇧⌘K)
2. Close Xcode
3. Reopen Xcode
4. Product → Build (⌘B)
```

---

## Alternative: Start Fresh

If you're still having issues, let's start completely fresh:

### Delete ALL API Key Files

1. Delete all versions of `APIKeySetupView.swift` (all of them)
2. Delete `KeychainHelper.swift`
3. Clean build folder

### Add Files Manually

Then manually create the files from scratch:

**1. Create KeychainHelper.swift:**

1. Right-click your project folder → New File → Swift File
2. Name it `KeychainHelper.swift`
3. Replace all contents with this:

```swift
//
//  KeychainHelper.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/19/26.
//

import Foundation
import Security

/// Helper class for securely storing sensitive data in the Keychain
class KeychainHelper {
    
    static let shared = KeychainHelper()
    
    private init() {}
    
    /// Save a string value to the Keychain
    @discardableResult
    func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Retrieve a string value from the Keychain
    func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    /// Delete a value from the Keychain
    @discardableResult
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
```

**2. Create APIKeySetupView.swift:**

1. Right-click your project folder → New File → Swift File
2. Name it `APIKeySetupView.swift`
3. Copy the complete code from `APIKeySetupView 3.swift` (see below)

---

## Complete APIKeySetupView.swift Code

Use this as your ONLY `APIKeySetupView.swift`:

```swift
//
//  APIKeySetupView.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/19/26.
//

import SwiftUI

struct APIKeySetupView: View {
    @State private var apiKey: String = ""
    @State private var isValidating = false
    @State private var errorMessage: String?
    @State private var showingInstructions = false
    @State private var tmdbService = TMDBService()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Image(systemName: "film.stack")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue.gradient)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical)
                    
                    Text("Welcome to MoviesIMiss!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("To get started, you'll need a free API key from The Movie Database (TMDB).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom)
                } header: {
                    EmptyView()
                }
                .listRowBackground(Color.clear)
                
                Section {
                    TextField("Enter your TMDB API key", text: $apiKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.asciiCapable)
                        #endif
                    
                    if let errorMessage = errorMessage {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("API Key")
                } footer: {
                    Text("Your API key is stored securely in the Keychain and never shared.")
                }
                
                Section {
                    Button {
                        showingInstructions = true
                    } label: {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("How to get an API key")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Need Help?")
                }
                
                Section {
                    Button {
                        validateAndSaveAPIKey()
                    } label: {
                        HStack {
                            Spacer()
                            if isValidating {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                Text("Validating...")
                            } else {
                                Text("Continue")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(apiKey.isEmpty || isValidating)
                }
            }
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingInstructions) {
                APIKeyInstructionsView()
            }
        }
    }
    
    private func validateAndSaveAPIKey() {
        isValidating = true
        errorMessage = nil
        
        tmdbService.setAPIKey(apiKey.trimmingCharacters(in: .whitespacesAndNewlines))
        
        Task {
            do {
                _ = try await tmdbService.fetchTopRated(page: 1)
                
                await MainActor.run {
                    isValidating = false
                    NotificationCenter.default.post(name: NSNotification.Name("APIKeyUpdated"), object: nil)
                }
            } catch {
                await MainActor.run {
                    isValidating = false
                    errorMessage = "Invalid API key. Please check and try again."
                    tmdbService.clearAPIKey()
                }
            }
        }
    }
}

struct APIKeyInstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    instructionStep(
                        number: "1",
                        title: "Create a TMDB Account",
                        description: "Visit themoviedb.org and sign up for a free account."
                    )
                    
                    instructionStep(
                        number: "2",
                        title: "Go to API Settings",
                        description: "Once logged in, go to your account Settings, then select 'API' from the left sidebar."
                    )
                    
                    instructionStep(
                        number: "3",
                        title: "Request an API Key",
                        description: "Click 'Request an API Key' and select 'Developer'. Fill out the simple form (you can use placeholder information for personal use)."
                    )
                    
                    instructionStep(
                        number: "4",
                        title: "Copy Your API Key",
                        description: "Once approved (usually instant), copy your API Key (v3 auth) and paste it into the app."
                    )
                    
                    Divider()
                        .padding(.vertical)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Label("It's completely free", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Label("Takes less than 2 minutes", systemImage: "clock.fill")
                            .foregroundStyle(.blue)
                        Label("Your key stays private", systemImage: "lock.fill")
                            .foregroundStyle(.purple)
                    }
                    .font(.subheadline)
                    
                    #if os(iOS)
                    Button {
                        if let url = URL(string: "https://www.themoviedb.org/signup") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Open TMDB Website")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.up.right")
                            Spacer()
                        }
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                    }
                    .padding(.top)
                    #else
                    Link(destination: URL(string: "https://www.themoviedb.org/signup")!) {
                        HStack {
                            Spacer()
                            Text("Open TMDB Website")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.up.right")
                            Spacer()
                        }
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                    }
                    .padding(.top)
                    #endif
                }
                .padding()
            }
            .navigationTitle("Get API Key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func instructionStep(number: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(number)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.blue.gradient)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(.blue.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview("Setup View") {
    APIKeySetupView()
}

#Preview("Instructions") {
    APIKeyInstructionsView()
}
```

---

## Verification After Fix

After deleting duplicates and rebuilding:

1. ✅ You should have exactly ONE `APIKeySetupView.swift`
2. ✅ You should have exactly ONE `KeychainHelper.swift`
3. ✅ Build should succeed with no errors
4. ✅ App should show API key setup screen

---

## Still Getting Errors?

If you still see errors after this:

1. **Search your project** for any file containing "APIKeySetupView"
2. **Delete ALL of them**
3. **Create ONE new file** manually using the code above
4. **Clean build** (⇧⌘K)
5. **Restart Xcode**
6. **Build** (⌘B)

---

This should completely fix the duplicate file issue!
