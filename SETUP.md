# Setup Instructions

## Quick Start

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate Hive Adapters** (if needed)
   ```bash
   flutter pub run build_runner build
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

## Testing the App

### Basic Functionality Test
1. **Create a Note**
   - Tap the + button
   - Enter a title like "My First Note"
   - Add some markdown content:
     ```markdown
     # Welcome to My Notes
     
     This is a **bold** text and this is *italic*.
     
     ## Features
     - Offline storage
     - Markdown support
     - Version control
     
     ```

2. **Test Autosave**
   - Type some content and wait 3 seconds
   - You should see "Auto-saving..." indicator
   - Navigate back and return - content should be preserved

3. **Test Version Control**
   - Make some changes to your note
   - Tap the save icon (disk icon) to create a version
   - Tap the history icon to view versions
   - Try restoring a previous version

4. **Test Search**
   - Create a few more notes with different content
   - Use the search bar to find notes by title or content
   - Test the debounced search (results appear after you stop typing)

5. **Test Sorting**
   - Create notes at different times
   - Try different sort options: Date Created, Date Updated, Title, Pinned First
   - Pin a note and see it appear first with "Pinned First" sort

### Advanced Features Test
1. **Version Comparison**
   - Create a note with some content
   - Save a version
   - Modify the content significantly
   - Save another version
   - Go to version history and compare versions

2. **Import/Export**
   - Create several notes
   - Try exporting all notes (creates a ZIP file)
   - Test importing markdown files

3. **Backup/Restore**
   - Create some notes
   - Create a backup
   - Test restore functionality

## File Structure After Running

After running the app and creating some notes, you'll see this structure in your app's documents directory:

```
/app_documents/
├── notes/
│   ├── [uuid1].md          # Your note content
│   ├── [uuid2].md
│   └── ...
├── versions/
│   ├── [uuid1]/
│   │   ├── v1.md           # Version 1 of note
│   │   ├── v2.md           # Version 2 of note
│   │   └── ...
│   └── ...
├── backups/
│   └── backup_[timestamp].zip
└── hive_boxes/             # Hive database files
    ├── notes_box.hive
    └── notes_box.lock
```

## Troubleshooting

### Common Issues

1. **Build Errors**
   - Run `flutter clean` then `flutter pub get`
   - Ensure Flutter SDK is up to date

2. **Hive Adapter Issues**
   - Run `flutter pub run build_runner build --delete-conflicting-outputs`

3. **File Permission Issues**
   - Check app permissions for storage access
   - On Android, ensure storage permissions are granted

4. **Performance Issues**
   - Test with fewer notes first
   - Check device storage space
   - Monitor memory usage with large notes

### Platform-Specific Notes

#### Android
- Requires storage permissions for backup/export
- Files stored in app-specific directory
- Backup files accessible via file manager

#### iOS
- Files stored in app sandbox
- Backup via iTunes/Finder file sharing
- No additional permissions required

#### Desktop (Windows/macOS/Linux)
- Files stored in user documents directory
- Full file system access for import/export
- Better performance with large note collections

## Performance Benchmarks

### Expected Performance
- **Note Creation**: < 100ms
- **Search (1000 notes)**: < 100ms
- **Version Save**: < 200ms
- **App Startup**: < 2 seconds
- **Memory Usage**: < 50MB with 100 notes

### Stress Testing
To test with many notes:
1. Create 100+ notes programmatically
2. Test search performance
3. Test scrolling performance
4. Test backup/restore with large datasets

## Development Tips

### Adding New Features
1. Follow the clean architecture pattern
2. Add new providers in the presentation layer
3. Extend repositories for new data operations
4. Update file manager for new file operations

### Debugging
1. Use Flutter Inspector for UI debugging
2. Check Hive boxes with Hive Inspector
3. Monitor file operations with logging
4. Use Riverpod Inspector for state debugging

### Testing
1. Unit tests for business logic
2. Widget tests for UI components
3. Integration tests for full workflows
4. Performance tests for large datasets