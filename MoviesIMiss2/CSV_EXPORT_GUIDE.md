# CSV Export Feature

## Overview

The CSV export feature allows you to export all your saved movie data to a CSV (Comma-Separated Values) file that can be opened in Excel, Numbers, Google Sheets, or any spreadsheet application.

## Features

### 1. **Export All Movies**
Export all your saved movies with complete metadata including:
- Title and Year
- TMDB ID
- Watch Status (Pending, Watched, Want to Watch Again)
- Dates (Added, Last Watched, Next Rewatch)
- Personal Data (Vibes, Mood Notes, etc.)
- Overview and Poster Path

### 2. **API Request Logging** (Optional)
Enable CSV logging to track all movie data fetched from TMDB API, useful for debugging or data analysis.

## How to Use

### Export Your Movie Collection

1. Navigate to **Debug Settings** in your app
2. Tap **"Export All Movies to CSV"** in the Movie Data Export section
3. The system share sheet will appear
4. Choose how to share or save the file:
   - Save to Files
   - Email to yourself
   - Share via Messages or AirDrop
   - Open in another app (Excel, Numbers, etc.)

### Enable API Logging (Optional)

1. In Debug Settings, toggle **"Enable CSV Logging"** ON
2. All movie data fetched from TMDB will be logged
3. View statistics and export the log file anytime
4. Clear the log when needed

## CSV Format

### Movie Export Columns

| Column | Description |
|--------|-------------|
| Title | Movie title |
| Year | Release year |
| TMDB ID | The Movie Database ID |
| Status | pending, watched, or wantToWatchAgain |
| Date Added | When you added the movie |
| Last Watched | When you last watched it |
| Next Rewatch | Scheduled rewatch date |
| Has Seen Before | Yes/No |
| Overview | Movie synopsis |
| Vibes | Your personal vibes (semicolon separated) |
| Vibe Notes | Your notes about the vibes |
| Mood When Watched | Your mood when you watched it |
| Mood It Helps With | Moods this movie helps with |
| Poster Path | TMDB poster image path |

### API Log Columns

| Column | Description |
|--------|-------------|
| Timestamp | When the data was fetched |
| ID | TMDB movie ID |
| Title | Movie title |
| Year | Release year |
| Release Date | Full release date |
| Vote Average | TMDB rating |
| Overview | Movie synopsis |
| Poster Path | TMDB poster image path |
| Source | Where the data came from (Search, Actor, etc.) |

## Use Cases

### Data Backup
Export your movie collection as a backup before app updates or device changes.

### Data Analysis
Import into spreadsheet software to:
- Count movies by status
- Analyze your vibes distribution
- Track watching patterns over time
- Create custom reports

### Sharing
Share your curated movie lists with friends or family by emailing the CSV file.

### Migration
Export data to migrate to another app or platform.

## Privacy

- All CSV files are created locally on your device
- No data is sent to any server
- You control where and how to share the exported file
- Delete export files anytime from the Files app

## Tips

### Opening CSV Files

**On iOS/iPadOS:**
- Numbers app (recommended for best formatting)
- Microsoft Excel
- Google Sheets (upload via browser)

**On macOS:**
- Numbers
- Microsoft Excel
- LibreOffice Calc

**On Windows:**
- Microsoft Excel
- Google Sheets
- LibreOffice Calc

### Importing to Google Sheets

1. Export the CSV file
2. Save to your Files app or email to yourself
3. Go to Google Sheets in a browser
4. File → Import → Upload
5. Select your CSV file

### Common Issues

**Special Characters:** 
The CSV properly escapes quotes, commas, and newlines, so all your data should import correctly.

**Date Format:**
Dates are in ISO 8601 format (YYYY-MM-DDTHH:MM:SS) which most spreadsheet apps will recognize.

**Empty Fields:**
If a field is empty (like Next Rewatch Date), it will be blank in the CSV.

## File Location

Exported CSV files are temporarily stored in your app's Documents directory and are available through the iOS share sheet. After sharing, you can delete the file or it will be cleaned up automatically by the system when space is needed.

## Technical Details

- File Name: `movies_export.csv`
- Encoding: UTF-8
- Line Endings: Unix style (\n)
- Quote Character: Double quote (")
- Delimiter: Comma (,)
- Header Row: Yes (first row contains column names)

## Support

If you have issues with CSV export:
1. Make sure you have saved movies in your collection
2. Ensure you have enough storage space
3. Try exporting to Files app first, then open from there
4. Check that your spreadsheet app supports UTF-8 encoding

---

**Last Updated:** March 22, 2026
