class AppConstants {
  // Storage
  static const String notesBoxName = 'notes_box';
  static const String settingsBoxName = 'settings_box';
  static const String notesDirectoryName = 'notes';
  static const String versionsDirectoryName = 'versions';
  static const String backupsDirectoryName = 'backups';
  
  // Autosave
  static const Duration autosaveInterval = Duration(seconds: 3);
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);
  
  // File extensions
  static const String markdownExtension = '.md';
  static const String backupExtension = '.zip';
  
  // Limits
  static const int maxVersionsPerNote = 50;
  static const int searchResultsLimit = 100;
}