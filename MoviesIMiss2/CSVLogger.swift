//
//  CSVLogger.swift
//  MoviesIMiss2
//
//  CSV logging for movie data export
//

import Foundation
import SwiftData

/// Singleton class for logging movie data to CSV files
@MainActor
final class CSVLogger {
    static let shared = CSVLogger()
    static let loggingEnabledKey = "csvLoggingEnabled"
    
    private let fileManager = FileManager.default
    private let csvFileName = "movies_export.csv"
    
    private init() {}
    
    // MARK: - File URL
    
    private var csvFileURL: URL? {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(csvFileName)
    }
    
    // MARK: - Export All Movies
    
    /// Export all saved movies to a CSV file
    func exportAllMovies(from context: ModelContext) throws -> URL? {
        let descriptor = FetchDescriptor<SavedMovie>(
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        
        let movies = try context.fetch(descriptor)
        
        guard !movies.isEmpty else {
            return nil
        }
        
        // Create CSV content
        var csvContent = "Title,Year,TMDB ID,Status,Date Added,Last Watched,Next Rewatch,Has Seen Before,Overview,Vibes,Vibe Notes,Mood When Watched,Mood It Helps With,Poster Path\n"
        
        for movie in movies {
            let row = createCSVRow(for: movie)
            csvContent.append(row)
        }
        
        // Write to file
        guard let fileURL = csvFileURL else {
            throw CSVError.fileURLCreationFailed
        }
        
        try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
    
    // MARK: - Log Individual Movie
    
    /// Log a single movie to the CSV (append mode)
    func logMovie(_ movie: TMDBMovie, source: String = "Search") async {
        guard UserDefaults.standard.bool(forKey: Self.loggingEnabledKey) else {
            return
        }
        
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let row = "\(timestamp),\(movie.id),\"\(escapeCSV(movie.title))\",\(movie.year),\(movie.releaseDate ?? ""),\(movie.voteAverage ?? 0.0),\"\(escapeCSV(movie.overview))\",\(movie.posterPath ?? ""),\(source)\n"
        
        await appendToLog(row, createHeader: "Timestamp,ID,Title,Year,Release Date,Vote Average,Overview,Poster Path,Source\n")
    }
    
    /// Log multiple movies at once
    func logMovies(_ movies: [TMDBMovie], source: String = "Search") async {
        guard UserDefaults.standard.bool(forKey: Self.loggingEnabledKey) else {
            return
        }
        
        let timestamp = ISO8601DateFormatter().string(from: Date())
        var rows = ""
        
        for movie in movies {
            let row = "\(timestamp),\(movie.id),\"\(escapeCSV(movie.title))\",\(movie.year),\(movie.releaseDate ?? ""),\(movie.voteAverage ?? 0.0),\"\(escapeCSV(movie.overview))\",\(movie.posterPath ?? ""),\(source)\n"
            rows.append(row)
        }
        
        await appendToLog(rows, createHeader: "Timestamp,ID,Title,Year,Release Date,Vote Average,Overview,Poster Path,Source\n")
    }
    
    // MARK: - Helper Methods
    
    private func createCSVRow(for movie: SavedMovie) -> String {
        let dateFormatter = ISO8601DateFormatter()
        
        let title = escapeCSV(movie.title)
        let year = movie.year
        let tmdbId = String(movie.tmdbId)
        let status = movie.statusRawValue
        let dateAdded = dateFormatter.string(from: movie.dateAdded)
        let lastWatched = movie.lastWatched.map { dateFormatter.string(from: $0) } ?? ""
        let nextRewatch = movie.nextRewatchDate.map { dateFormatter.string(from: $0) } ?? ""
        let hasSeenBefore = movie.hasSeenBefore ? "Yes" : "No"
        let overview = escapeCSV(movie.overview)
        let vibes = escapeCSV((movie.personalVibes ?? []).joined(separator: "; "))
        let vibeNotes = escapeCSV(movie.vibeNotes ?? "")
        let moodWhenWatched = escapeCSV(movie.moodWhenWatched ?? "")
        let moodItHelpsWith = escapeCSV(movie.moodItHelpsWithString ?? "")
        let posterPath = movie.posterPath ?? ""
        
        return "\(title),\(year),\(tmdbId),\(status),\(dateAdded),\(lastWatched),\(nextRewatch),\(hasSeenBefore),\"\(overview)\",\(vibes),\(vibeNotes),\(moodWhenWatched),\(moodItHelpsWith),\(posterPath)\n"
    }
    
    private func escapeCSV(_ string: String) -> String {
        // Escape quotes and wrap in quotes if contains comma, quote, or newline
        let escaped = string.replacingOccurrences(of: "\"", with: "\"\"")
        if escaped.contains(",") || escaped.contains("\"") || escaped.contains("\n") {
            return "\"\(escaped)\""
        }
        return escaped
    }
    
    private func appendToLog(_ content: String, createHeader: String) async {
        guard let fileURL = csvFileURL else {
            return
        }
        
        do {
            if !fileManager.fileExists(atPath: fileURL.path) {
                // Create new file with header
                try createHeader.write(to: fileURL, atomically: true, encoding: .utf8)
            }
            
            // Append content
            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                fileHandle.seekToEndOfFile()
                if let data = content.data(using: .utf8) {
                    fileHandle.write(data)
                }
                try fileHandle.close()
            }
        } catch {
            print("CSV logging error: \(error)")
        }
    }
    
    // MARK: - File Management
    
    /// Export the CSV file for sharing
    func exportFile() -> URL? {
        guard let fileURL = csvFileURL,
              fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        return fileURL
    }
    
    /// Clear the log file
    func clearLog() throws {
        guard let fileURL = csvFileURL else {
            throw CSVError.fileURLCreationFailed
        }
        
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    /// Get the file size formatted as a string
    func getFormattedFileSize() -> String? {
        guard let fileURL = csvFileURL,
              let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
              let fileSize = attributes[.size] as? Int64 else {
            return nil
        }
        
        return ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
    
    /// Get the number of entries in the log
    func getEntryCount() -> Int? {
        guard let fileURL = csvFileURL,
              let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return nil
        }
        
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        return max(0, lines.count - 1) // Subtract header row
    }
}

// MARK: - Errors

enum CSVError: LocalizedError {
    case fileURLCreationFailed
    case noMoviesToExport
    
    var errorDescription: String? {
        switch self {
        case .fileURLCreationFailed:
            return "Could not create file URL for CSV export"
        case .noMoviesToExport:
            return "No movies to export"
        }
    }
}
