import '../entities/note.dart';
import '../entities/note_version.dart';

abstract class NotesRepository {
  // Note CRUD operations
  Future<List<Note>> getAllNotes();
  Future<Note?> getNoteById(String id);
  Future<void> saveNote(Note note);
  Future<void> deleteNote(String id);
  
  // Note content operations
  Future<String> getNoteContent(String noteId);
  Future<void> saveNoteContent(String noteId, String content);
  
  // Version operations
  Future<void> saveVersion(String noteId, int version, String content);
  Future<List<NoteVersion>> getNoteVersions(String noteId);
  Future<String> getVersionContent(String noteId, int version);
  Future<void> deleteVersion(String noteId, int version);
  
  // Search operations
  Future<List<Note>> searchNotes(String query);
  
  // Backup operations
  Future<void> createBackup(String backupName);
  Future<void> restoreBackup(String backupPath);
  
  // Import/Export operations
  Future<void> exportNote(String noteId, String exportPath);
  Future<void> exportNotes(List<String> noteIds, String exportPath);
  Future<List<Note>> importNotes(List<String> filePaths);
}