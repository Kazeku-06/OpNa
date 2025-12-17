import 'package:flutter_test/flutter_test.dart';
import 'package:ntah/features/notes/domain/entities/note.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Note Entity Tests', () {
    test('should create a note with required fields', () {
      final note = Note(
        id: const Uuid().v4(),
        title: 'Test Note',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(note.title, 'Test Note');
      expect(note.isPinned, false);
      expect(note.currentVersion, 1);
      expect(note.nextVersionNumber, 2);
    });

    test('should create a copy with updated fields', () {
      final originalNote = Note(
        id: const Uuid().v4(),
        title: 'Original Title',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedNote = originalNote.copyWith(
        title: 'Updated Title',
        isPinned: true,
      );

      expect(updatedNote.title, 'Updated Title');
      expect(updatedNote.isPinned, true);
      expect(updatedNote.id, originalNote.id); // Should remain the same
      expect(updatedNote.createdAt, originalNote.createdAt); // Should remain the same
    });

    test('should handle version numbers correctly', () {
      final note = Note(
        id: const Uuid().v4(),
        title: 'Version Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        currentVersion: 5,
        nextVersionNumber: 6,
      );

      expect(note.currentVersion, 5);
      expect(note.nextVersionNumber, 6);

      final updatedNote = note.copyWith(
        currentVersion: note.nextVersionNumber,
        nextVersionNumber: note.nextVersionNumber + 1,
      );

      expect(updatedNote.currentVersion, 6);
      expect(updatedNote.nextVersionNumber, 7);
    });

    test('should handle equality correctly', () {
      final id = const Uuid().v4();
      final note1 = Note(
        id: id,
        title: 'Test Note 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final note2 = Note(
        id: id,
        title: 'Test Note 2', // Different title
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final note3 = Note(
        id: const Uuid().v4(), // Different ID
        title: 'Test Note 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(note1, equals(note2)); // Same ID, should be equal
      expect(note1, isNot(equals(note3))); // Different ID, should not be equal
    });

    test('should handle folder assignment', () {
      final note = Note(
        id: const Uuid().v4(),
        title: 'Folder Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        folder: 'Work',
      );

      expect(note.folder, 'Work');

      final updatedNote = note.copyWith(folder: 'Personal');
      expect(updatedNote.folder, 'Personal');
    });
  });

  group('Note Version Tests', () {
    test('should create note version with all fields', () {
      final version = NoteVersion(
        noteId: const Uuid().v4(),
        version: 1,
        createdAt: DateTime.now(),
        content: '# Test Content\n\nThis is a test.',
      );

      expect(version.version, 1);
      expect(version.content, '# Test Content\n\nThis is a test.');
    });

    test('should handle version equality correctly', () {
      final noteId = const Uuid().v4();
      final version1 = NoteVersion(
        noteId: noteId,
        version: 1,
        createdAt: DateTime.now(),
        content: 'Content 1',
      );

      final version2 = NoteVersion(
        noteId: noteId,
        version: 1,
        createdAt: DateTime.now(),
        content: 'Content 2', // Different content
      );

      final version3 = NoteVersion(
        noteId: noteId,
        version: 2, // Different version
        createdAt: DateTime.now(),
        content: 'Content 1',
      );

      expect(version1, equals(version2)); // Same noteId and version
      expect(version1, isNot(equals(version3))); // Different version number
    });
  });
}