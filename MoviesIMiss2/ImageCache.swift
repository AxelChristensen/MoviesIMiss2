//
//  ImageCache.swift
//  MoviesIMiss2
//
//  Created by Axel Christensen on 3/21/26.
//

import SwiftUI

/// A simple image cache using NSCache
class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        // Configure cache limits
        cache.countLimit = 100 // Max 100 images
        cache.totalCostLimit = 50 * 1024 * 1024 // Max 50MB
    }
    
    func get(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func clear() {
        cache.removeAllObjects()
    }
}

/// Image loader that handles downloading and caching
@MainActor
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    private let url: URL
    private let cache = ImageCache.shared
    
    init(url: URL) {
        self.url = url
    }
    
    func load() {
        // Check cache first
        if let cachedImage = cache.get(forKey: url.absoluteString) {
            self.image = cachedImage
            return
        }
        
        // Download if not cached
        isLoading = true
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if let downloadedImage = UIImage(data: data) {
                    // Cache the image
                    cache.set(downloadedImage, forKey: url.absoluteString)
                    
                    await MainActor.run {
                        self.image = downloadedImage
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    func cancel() {
        // In a production app, you'd cancel the network request here
        isLoading = false
    }
}

/// A cached async image view that works like AsyncImage but with caching
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @StateObject private var loader: ImageLoader
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
        
        // Initialize the loader with a dummy URL if nil
        _loader = StateObject(wrappedValue: ImageLoader(url: url ?? URL(string: "https://example.com")!))
    }
    
    var body: some View {
        Group {
            if let url = url {
                if let image = loader.image {
                    content(Image(uiImage: image))
                } else {
                    placeholder()
                        .onAppear {
                            loader.load()
                        }
                }
            } else {
                placeholder()
            }
        }
    }
}

// Convenience extension for simple usage
extension CachedAsyncImage where Content == Image, Placeholder == Color {
    init(url: URL?) {
        self.init(
            url: url,
            content: { image in image },
            placeholder: { Color.gray.opacity(0.2) }
        )
    }
}
