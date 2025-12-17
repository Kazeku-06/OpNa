import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

class FileManager {
  static FileManager? _instance;
  static FileManager get instance => _instance ??= FileManager._();
  FileManager._();

  Directory? _appDirectory;
  Directory? _notesDirectory;
  Directory? _versionsDirectory;
  Directory? _backupsDirectory;

  Future<void> initialize() async {
    _appDirectory = await getApplicationDocumentsDirectory();
    
    _notesDirectory = Directory(path.join(_appDirectory!.path, AppConstants.notesDirectoryName));
    _versionsDirectory = Directory(path.join(_appDirectory!.path, AppConstants.versionsDirectoryName));
    _backupsDirectory = Directory(path.join(_appDirectory!.path, AppConstants.backupsDirectoryName));

    await _ensureDirectoryExists(_notesDirectory!);
    await _ensureDirectoryExists(_versionsDirectory!);
    await _ensureDirectoryExists(_backupsDirectory!);
  }

  Future<void> _ensureDirectoryExists(Directory directory) async {
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  // Note file operations
  Future<File> getNoteFile(String noteId) async {
    final fileName = '$noteId${AppConstants.markdownExtension}';
    return File(path.join(_notesDirectory!.path, fileName));
  }

  Future<String> readNoteContent(String noteId) async {
    try {
      final file = await getNoteFile(noteId);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return '';
    } catch (e) {
      throw FileSystemException('Failed to read note content: $e');
    }
  }

  Future<void> writeNoteContent(String noteId, String content) async {
    try {
      final file = await getNoteFile(noteId);
      await file.writeAsString(content);
    } catch (e) {
      throw FileSystemException('Failed to write note content: $e');
    }
  }

  Future<void> deleteNoteFile(String noteId) async {
    try {
      final file = await getNoteFile(noteId);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw FileSystemException('Failed to delete note file: $e');
    }
  }

  // Version file operations
  Future<Directory> getNoteVersionsDirectory(String noteId) async {
    final versionDir = Directory(path.join(_versionsDirectory!.path, noteId));
    await _ensureDirectoryExists(versionDir);
    return versionDir;
  }

  Future<File> getVersionFile(String noteId, int version) async {
    final versionDir = await getNoteVersionsDirectory(noteId);
    final fileName = 'v$version${AppConstants.markdownExtension}';
    return File(path.join(versionDir.path, fileName));
  }

  Future<void> saveVersion(String noteId, int version, String content) async {
    try {
      final file = await getVersionFile(noteId, version);
      await file.writeAsString(content);
    } catch (e) {
      throw FileSystemException('Failed to save version: $e');
    }
  }

  Future<String> readVersion(String noteId, int version) async {
    try {
      final file = await getVersionFile(noteId, version);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return '';
    } catch (e) {
      throw FileSystemException('Failed to read version: $e');
    }
  }

  Future<List<int>> getVersionNumbers(String noteId) async {
    try {
      final versionDir = await getNoteVersionsDirectory(noteId);
      if (!await versionDir.exists()) return [];

      final files = await versionDir.list().toList();
      final versions = <int>[];

      for (final file in files) {
        if (file is File && file.path.endsWith(AppConstants.markdownExtension)) {
          final fileName = path.basenameWithoutExtension(file.path);
          if (fileName.startsWith('v')) {
            final versionStr = fileName.substring(1);
            final version = int.tryParse(versionStr);
            if (version != null) {
              versions.add(version);
            }
          }
        }
      }

      versions.sort((a, b) => b.compareTo(a)); // Descending order
      return versions;
    } catch (e) {
      throw FileSystemException('Failed to get version numbers: $e');
    }
  }

  Future<void> deleteVersion(String noteId, int version) async {
    try {
      final file = await getVersionFile(noteId, version);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw FileSystemException('Failed to delete version: $e');
    }
  }

  // Backup operations
  Future<File> getBackupFile(String backupName) async {
    final fileName = '$backupName${AppConstants.backupExtension}';
    return File(path.join(_backupsDirectory!.path, fileName));
  }

  // Search operations
  Future<List<String>> searchInFiles(String query) async {
    final results = <String>[];
    
    try {
      if (!await _notesDirectory!.exists()) return results;

      final files = await _notesDirectory!.list().toList();
      
      for (final file in files) {
        if (file is File && file.path.endsWith(AppConstants.markdownExtension)) {
          final content = await file.readAsString();
          if (content.toLowerCase().contains(query.toLowerCase())) {
            final noteId = path.basenameWithoutExtension(file.path);
            results.add(noteId);
          }
        }
      }
    } catch (e) {
      throw FileSystemException('Failed to search in files: $e');
    }

    return results;
  }

  // Utility methods
  Directory get appDirectory => _appDirectory!;
  Directory get notesDirectory => _notesDirectory!;
  Directory get versionsDirectory => _versionsDirectory!;
  Directory get backupsDirectory => _backupsDirectory!;
}