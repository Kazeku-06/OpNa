# Offline Markdown Notes App

A production-ready Flutter application for offline-first personal note-taking with Markdown support, version control, and robust data management.

## Features

### Core Features
- **100% Offline Operation** - No internet, authentication, or cloud services required
- **Markdown Editor** - Full-featured editor with toolbar and live preview
- **Note Management** - Create, edit, delete, duplicate, and pin notes
- **Search System** - Fast search across titles and content with debounced input
- **Autosave** - Automatic saving every 3 seconds with crash recovery
- **Folder Organization** - Organize notes with optional folder system

### Advanced Features
- **Version Control** - Manual version saving with complete history
- **Diff Viewer** - Visual comparison between note versions
- **Backup & Restore** - Full app backup to local storage
- **Import/Export** - Import markdown files and export notes as ZIP
- **Sort Options** - Sort by date created, updated, title, or pinned status

## Architecture

### Clean Architecture Implementation
```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   └── file_manager/       # File system operations
├── features/
│   └── notes/
│       ├── data/           # Data layer (repositories)
│       ├── domain/         # Domain layer (entities, repositories)
│       └── presentation/   # UI layer (screens, widgets, providers)
└── main.dart
```

### Storage Architecture
- **Metadata Storage**: Hive (local NoSQL database)
  - Note titles, timestamps, pinned status, folders
  - Fast queries and indexing
- **Content Storage**: File System
  - Markdown content stored as `.md` files
  - Version history as separate files
  - Prevents database bloat with large content

### State Management
- **Riverpod** for reactive state management
- **Provider-based architecture** with clear separation of concerns
- **Automatic state updates** across the app

## File Structure

### Notes Storage
```
/app_documents/
├── notes/
│   ├── note_uuid_1.md
│   ├── note_uuid_2.md
│   └── ...
├── versions/
│   ├── note_uuid_1/
│   │   ├── v1.md
│   │   ├── v2.md
│   │   └── ...
│   └── ...
└── backups/
    ├── backup_timestamp.zip
    └── ...
```

## Key Design Decisions

### 1. Hybrid Storage Approach
- **Why**: Separates fast metadata queries from large content storage
- **Trade-off**: Slightly more complex but much better performance
- **Benefit**: Can handle 1000+ notes efficiently

### 2. File-based Content Storage
- **Why**: Prevents SQLite database bloat with large markdown content
- **Trade-off**: More file system operations
- **Benefit**: Better performance, easier backup/export

### 3. Manual Version Control
- **Why**: Gives users control over when versions are saved
- **Trade-off**: Requires user action vs automatic
- **Benefit**: Prevents version spam, meaningful snapshots

### 4. Autosave with Manual Save
- **Why**: Best of both worlds - safety + control
- **Trade-off**: Slightly more complex UX
- **Benefit**: Never lose work, but versions are intentional

## Performance Considerations

### Search Optimization
- **Debounced input** (300ms) to prevent excessive queries
- **File system search** for content matching
- **Hive queries** for metadata matching
- **Result limiting** to 100 matches for performance

### Memory Management
- **Lazy loading** of note content
- **Efficient file operations** with proper error handling
- **Version cleanup** (max 50 versions per note)

### Crash Recovery
- **Autosave timer** ensures regular saves
- **Background save** when app goes to background
- **Draft recovery** on app restart

## Edge Cases Handled

### File System Issues
- **Corrupted files**: Graceful error handling with user feedback
- **Storage full**: Proper error messages and cleanup suggestions
- **Permission denied**: Clear error messages with resolution steps

### Data Integrity
- **UUID conflicts**: Prevention during import operations
- **Version conflicts**: Proper ordering and cleanup
- **Concurrent access**: File locking and error recovery

### User Experience
- **Large files**: Progress indicators and chunked operations
- **Network changes**: No impact (fully offline)
- **App crashes**: Automatic recovery of unsaved content

## Getting Started

### Prerequisites
- Flutter SDK 3.10.4 or higher
- Dart SDK compatible with Flutter version

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter pub run build_runner build` to generate Hive adapters
4. Run `flutter run` to start the app

### Dependencies
- **flutter_riverpod**: State management
- **hive_flutter**: Local database
- **flutter_markdown**: Markdown rendering
- **path_provider**: File system access
- **uuid**: Unique identifier generation
- **diff_match_patch**: Text diffing for version comparison
- **archive**: Backup/export functionality

## Usage

### Creating Notes
1. Tap the floating action button on the home screen
2. Enter a title and start writing in Markdown
3. Content is automatically saved every 3 seconds

### Version Control
1. In the editor, tap the save icon to create a version
2. Access version history via the history icon
3. Compare versions or restore previous versions

### Search and Organization
1. Use the search bar to find notes by title or content
2. Sort notes using the filter chips
3. Pin important notes for quick access

### Backup and Export
1. Access backup options from the home screen menu
2. Create full backups or export selected notes
3. Import markdown files from other sources

## Limitations and Trade-offs

### Current Limitations
- **No cloud sync** (by design - offline-first)
- **No collaborative editing** (single-user focus)
- **No rich media** (text/markdown only)
- **Platform-specific file paths** (handled gracefully)

### Performance Limits
- **Tested up to 1000+ notes** with good performance
- **Large individual files** (>1MB) may impact editor performance
- **Version history** limited to 50 versions per note

### Future Enhancements
- **Tags system** (alternative to folders)
- **Advanced search** (regex, filters)
- **Themes and customization**
- **Plugin system** for extensions

## Contributing

This is a production-ready implementation focusing on:
- **Reliability over features**
- **Performance over complexity**
- **User data safety over convenience**

The architecture is designed to be maintainable and extensible while keeping the core functionality robust and fast.