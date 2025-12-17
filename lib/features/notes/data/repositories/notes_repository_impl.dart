import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/file_manager/file_manager.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_version.dart';
import '../../domain/repositories/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  final FileManager _fileManager = FileManager.instance;
  final Uuid _uuid = const Uuid();
  
  Box<Note>? _notesBox;

  Future<Box<Note>> get notesBox async {
    _notesBox ??= await Hive.openBox<Note>(AppConstants.notesBoxName);
    return _notesBox!;
  }

  @override
  Future<List<Note>> getAllNotes() async {
    try {
      final box = await notesBox;
      return box.values.toList();
    } catch (e) {
      throw Exception('Failed to get all notes: $e');
    }
  }

  @override
  Future<Note?> getNoteById(String id) async {
    try {
      final box = await notesBox;
      return box.get(id);
    } catch (e) {
      throw Exception('Failed to get note by id: $e');
    }
  }

  @override
  Future<void> saveNote(Note note) async {
    try {
      final box = await notesBox;
      await box.put(note.id, note);
    } catch (e) {
      throw Exception('Failed to save note: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      final box = await notesBox;
      await box.delete(id);
      await _fileManager.deleteNoteFile(id);
      
      // Delete all versions
      final versions = await _fileManager.getVersionNumbers(id);
      for (final version in versions) {
        await _fileManager.deleteVersion(id, version);
      }
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  @override
  Future<String> getNoteContent(String noteId) async {
    try {
      return await _fileManager.readNoteContent(noteId);
    } catch (e) {
      throw Exception('Failed to get note content: $e');
    }
  }

  @override
  Future<void> saveNoteContent(String noteId, String content) async {
    try {
      await _fileManager.writeNoteContent(noteId, content);
    } catch (e) {
      throw Exception('Failed to save note content: $e');
    }
  }

  @override
  Future<void> saveVersion(String noteId, int version, String content) async {
    try {
      await _fileManager.saveVersion(noteId, version, content);
      
      // Clean up old versions if exceeding limit
      final versions = await _fileManager.getVersionNumbers(noteId);
      if (versions.length > AppConstants.maxVersionsPerNote) {
        final versionsToDelete = versions.skip(AppConstants.maxVersionsPerNote);
        for (final versionToDelete in versionsToDelete) {
          await _fileManager.deleteVersion(noteId, versionToDelete);
        }
      }
    } catch (e) {
      throw Exception('Failed to save version: $e');
    }
  }

  @override
  Future<List<NoteVersion>> getNoteVersions(String noteId) async {
    try {
      final versions = await _fileManager.getVersionNumbers(noteId);
      final noteVersions = <NoteVersion>[];
      
      for (final version in versions) {
        final content = await _fileManager.readVersion(noteId, version);
        noteVersions.add(NoteVersion(
          noteId: noteId,
          version: version,
          createdAt: DateTime.now(), // We don't store creation time for versions
          content: content,
        ));
      }
      
      return noteVersions;
    } catch (e) {
      throw Exception('Failed to get note versions: $e');
    }
  }

  @override
  Future<String> getVersionContent(String noteId, int version) async {
    try {
      return await _fileManager.readVersion(noteId, version);
    } catch (e) {
      throw Exception('Failed to get version content: $e');
    }
  }

  @override
  Future<void> deleteVersion(String noteId, int version) async {
    try {
      await _fileManager.deleteVersion(noteId, version);
    } catch (e) {
      throw Exception('Failed to delete version: $e');
    }
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    try {
      final box = await notesBox;
      final allNotes = box.values.toList();
      final results = <Note>[];
      
      // Search in titles
      for (final note in allNotes) {
        if (note.title.toLowerCase().contains(query.toLowerCase())) {
          results.add(note);
        }
      }
      
      // Search in content
      final contentMatches = await _fileManager.searchInFiles(query);
      for (final noteId in contentMatches) {
        final note = box.get(noteId);
        if (note != null && !results.contains(note)) {
          results.add(note);
        }
      }
      
      return results.take(AppConstants.searchResultsLimit).toList();
    } catch (e) {
      throw Exception('Failed to search notes: $e');
    }
  }

  @override
  Future<void> createBackup(String backupName) async {
    try {
      if (kIsWeb) {
        // For web, we'll just log the backup for now
        print('Creating backup: $backupName');
        return;
      }
      
      final encoder = ZipFileEncoder();
      final backupFile = await _fileManager.getBackupFile(backupName);
      
      encoder.create(backupFile.path);
      
      // Add notes directory
      encoder.addDirectory(_fileManager.notesDirectory);
      
      // Add versions directory
      encoder.addDirectory(_fileManager.versionsDirectory);
      
      // Add Hive box data
      final box = await notesBox;
      final notesData = <String, dynamic>{};
      for (final note in box.values) {
        notesData[note.id] = {
          'id': note.id,
          'title': note.title,
          'createdAt': note.createdAt.toIso8601String(),
          'updatedAt': note.updatedAt.toIso8601String(),
          'isPinned': note.isPinned,
          'folder': note.folder,
          'currentVersion': note.currentVersion,
          'nextVersionNumber': note.nextVersionNumber,
        };
      }
      
      // Create a temporary metadata file
      final metadataFile = File(path.join(_fileManager.appDirectory.path, 'metadata.json'));
      await metadataFile.writeAsString(notesData.toString());
      encoder.addFile(metadataFile);
      await metadataFile.delete();
      
      encoder.close();
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  @override
  Future<void> restoreBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found');
      }
      
      // Extract backup
      final bytes = await backupFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      // Clear existing data
      final box = await notesBox;
      await box.clear();
      
      // Extract files to app directory
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final extractedFile = File(path.join(_fileManager.appDirectory.path, filename));
          await extractedFile.create(recursive: true);
          await extractedFile.writeAsBytes(data);
        }
      }
      
      // TODO: Parse and restore metadata.json to Hive box
      // This would require proper JSON parsing and Note reconstruction
      
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }

  @override
  Future<void> exportNote(String noteId, String exportPath) async {
    try {
      final note = await getNoteById(noteId);
      if (note == null) throw Exception('Note not found');
      
      final content = await getNoteContent(noteId);
      
      if (kIsWeb) {
        // For web, we'll just show the content in a dialog for now
        // In a real app, you'd implement proper file download
        print('Export note: ${note.title}\nContent: $content');
      } else {
        final exportFile = File(path.join(exportPath, '${note.title}.md'));
        await exportFile.writeAsString(content);
      }
    } catch (e) {
      throw Exception('Failed to export note: $e');
    }
  }

  @override
  Future<void> exportNotes(List<String> noteIds, String exportPath) async {
    try {
      final encoder = ZipFileEncoder();
      final exportFile = File(path.join(exportPath, 'notes_export.zip'));
      
      encoder.create(exportFile.path);
      
      for (final noteId in noteIds) {
        final note = await getNoteById(noteId);
        if (note != null) {
          final content = await getNoteContent(noteId);
          final tempFile = File(path.join(_fileManager.appDirectory.path, '${note.title}.md'));
          await tempFile.writeAsString(content);
          encoder.addFile(tempFile);
          await tempFile.delete();
        }
      }
      
      encoder.close();
    } catch (e) {
      throw Exception('Failed to export notes: $e');
    }
  }

  @override
  Future<List<Note>> importNotes(List<String> filePaths) async {
    try {
      final importedNotes = <Note>[];
      
      for (final filePath in filePaths) {
        final file = File(filePath);
        if (await file.exists() && filePath.endsWith('.md')) {
          final content = await file.readAsString();
          final fileName = path.basenameWithoutExtension(filePath);
          
          final note = Note(
            id: _uuid.v4(),
            title: fileName,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          await saveNote(note);
          await saveNoteContent(note.id, content);
          importedNotes.add(note);
        }
      }
      
      return importedNotes;
    } catch (e) {
      throw Exception('Failed to import notes: $e');
    }
  }
}