//
//  DebugSettingsView.swift
//  MoviesIMiss2
//
//  Debug settings for CSV logging
//

import SwiftUI

struct DebugSettingsView: View {
    @AppStorage(CSVLogger.loggingEnabledKey) private var isCSVLoggingEnabled = false
    @State private var fileSize: String?
    @State private var entryCount: Int?
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    @State private var shareURL: URL?
    
    var body: some View {
        Form {
            Section("CSV Data Logging") {
                Toggle("Enable CSV Logging", isOn: $isCSVLoggingEnabled)
                Text("When enabled, all movie data fetched from TMDB will be logged to a CSV file.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if isCSVLoggingEnabled {
                Section("Log File Statistics") {
                    if let fileSize = fileSize {
                        LabeledContent("File Size", value: fileSize)
                    }
                    if let entryCount = entryCount {
                        LabeledContent("Total Entries", value: "\(entryCount)")
                    }
                    Button("Refresh Stats") { refreshStats() }
                }
                
                Section("Actions") {
                    Button("Export CSV File") { exportFile() }
                        .disabled(entryCount == nil || entryCount == 0)
                    Button("Clear Log File", role: .destructive) { showingDeleteAlert = true }
                        .disabled(entryCount == nil || entryCount == 0)
                }
            }
            
            Section("Information") {
                Text("CSV Format: Timestamp, ID, Title, Year, Release Date, Vote Average, Overview, Poster Path, Source")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Debug Settings")
        .onAppear { refreshStats() }
        .alert("Delete Log File", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { deleteLog() }
        } message: {
            Text("Are you sure you want to permanently delete the CSV log file?")
        }
        .sheet(isPresented: $showingShareSheet) {
            if let shareURL = shareURL {
                ActivityView(items: [shareURL])
            }
        }
    }
    
    private func refreshStats() {
        fileSize = CSVLogger.shared.getFormattedFileSize()
        entryCount = CSVLogger.shared.getEntryCount()
    }
    
    private func deleteLog() {
        try? CSVLogger.shared.clearLog()
        refreshStats()
    }
    
    private func exportFile() {
        if let url = CSVLogger.shared.exportFile() {
            shareURL = url
            showingShareSheet = true
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
