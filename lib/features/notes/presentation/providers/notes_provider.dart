import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/notes_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_version.dart';
import '../../domain/repositories/notes_repository.dart';

// Repository provider
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepositoryImpl();
});

// Notes list provider
final notesProvider = StateNotifierProvider<NotesNotifier, AsyncValue<List<Note>>>((ref) {
  return NotesNotifier(ref.read(notesRepositoryProvider));
});

// Current note provider
final currentNoteProvider = StateProvider<Note?>((ref) => null);

// Note content provider
final noteContentProvider = StateNotifierProvider.family<NoteContentNotifier, AsyncValue<String>, String>((ref, noteId) {
  return NoteContentNotifier(ref.read(notesRepositoryProvider), noteId);
});

// Search provider
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Note>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) {
    final notesAsync = ref.watch(notesProvider);
    return notesAsync.when(
      data: (notes) => notes,
      loading: () => <Note>[],
      error: (_, __) => <Note>[],
    );
  }
  
  final repository = ref.read(notesRepositoryProvider);
  return await repository.searchNotes(query);
});

// Sort options
enum SortOption { dateCreated, dateUpdated, title, pinned }

final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.dateUpdated);

final sortedNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final notesAsync = ref.watch(notesProvider);
  final sortOption = ref.watch(sortOptionProvider);
  
  return notesAsync.when(
    data: (notes) {
      final sortedNotes = List<Note>.from(notes);
      
      switch (sortOption) {
        case SortOption.dateCreated:
          sortedNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case SortOption.dateUpdated:
          sortedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          break;
        case SortOption.title:
          sortedNotes.sort((a, b) => a.title.compareTo(b.title));
          break;
        case SortOption.pinned:
          sortedNotes.sort((a, b) {
            if (a.isPinned && !b.isPinned) return -1;
            if (!a.isPinned && b.isPinned) return 1;
            return b.updatedAt.compareTo(a.updatedAt);
          });
          break;
      }
      
      return AsyncValue.data(sortedNotes);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Version history provider
final noteVersionsProvider = FutureProvider.family<List<NoteVersion>, String>((ref, noteId) async {
  final repository = ref.read(notesRepositoryProvider);
  return await repository.getNoteVersions(noteId);
});

class NotesNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final NotesRepository _repository;
  final Uuid _uuid = const Uuid();

  NotesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    try {
      state = const AsyncValue.loading();
      final notes = await _repository.getAllNotes();
      state = AsyncValue.data(notes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Note> createNote({String? title, String? folder}) async {
    try {
      final note = Note(
        id: _uuid.v4(),
        title: title ?? 'Untitled Note',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        folder: folder,
      );

      await _repository.saveNote(note);
      await _repository.saveNoteContent(note.id, '');
      
      await loadNotes();
      return note;
    } catch (error) {
      throw Exception('Failed to create note: $error');
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      await _repository.saveNote(updatedNote);
      await loadNotes();
    } catch (error) {
      throw Exception('Failed to update note: $error');
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _repository.deleteNote(noteId);
      await loadNotes();
    } catch (error) {
      throw Exception('Failed to delete note: $error');
    }
  }

  Future<Note> duplicateNote(String noteId) async {
    try {
      final originalNote = await _repository.getNoteById(noteId);
      if (originalNote == null) throw Exception('Note not found');

      final content = await _repository.getNoteContent(noteId);
      
      final duplicatedNote = Note(
        id: _uuid.v4(),
        title: '${originalNote.title} (Copy)',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        folder: originalNote.folder,
      );

      await _repository.saveNote(duplicatedNote);
      await _repository.saveNoteContent(duplicatedNote.id, content);
      
      await loadNotes();
      return duplicatedNote;
    } catch (error) {
      throw Exception('Failed to duplicate note: $error');
    }
  }

  Future<void> togglePin(String noteId) async {
    try {
      final note = await _repository.getNoteById(noteId);
      if (note == null) throw Exception('Note not found');

      final updatedNote = note.copyWith(
        isPinned: !note.isPinned,
        updatedAt: DateTime.now(),
      );

      await _repository.saveNote(updatedNote);
      await loadNotes();
    } catch (error) {
      throw Exception('Failed to toggle pin: $error');
    }
  }
}

class NoteContentNotifier extends StateNotifier<AsyncValue<String>> {
  final NotesRepository _repository;
  final String _noteId;
  Timer? _autosaveTimer;
  String _lastSavedContent = '';

  NoteContentNotifier(this._repository, this._noteId) : super(const AsyncValue.loading()) {
    loadContent();
  }

  Future<void> loadContent() async {
    try {
      state = const AsyncValue.loading();
      final content = await _repository.getNoteContent(_noteId);
      _lastSavedContent = content;
      state = AsyncValue.data(content);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void updateContent(String content) {
    state = AsyncValue.data(content);
    _scheduleAutosave(content);
  }

  void _scheduleAutosave(String content) {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(seconds: 3), () {
      _saveContent(content);
    });
  }

  Future<void> _saveContent(String content) async {
    if (content == _lastSavedContent) return;
    
    try {
      await _repository.saveNoteContent(_noteId, content);
      _lastSavedContent = content;
    } catch (error) {
      // Handle autosave error silently or show a subtle indicator
    }
  }

  Future<void> saveManually() async {
    final content = state.value ?? '';
    await _saveContent(content);
  }

  Future<void> saveVersion() async {
    try {
      final note = await _repository.getNoteById(_noteId);
      if (note == null) throw Exception('Note not found');

      final content = state.value ?? '';
      await _repository.saveVersion(_noteId, note.nextVersionNumber, content);
      
      // Update note with new version numbers
      final updatedNote = note.copyWith(
        currentVersion: note.nextVersionNumber,
        nextVersionNumber: note.nextVersionNumber + 1,
        updatedAt: DateTime.now(),
      );
      await _repository.saveNote(updatedNote);
    } catch (error) {
      throw Exception('Failed to save version: $error');
    }
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    super.dispose();
  }
}