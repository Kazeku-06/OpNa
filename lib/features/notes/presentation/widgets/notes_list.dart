import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/note.dart';
import '../providers/notes_provider.dart';
import '../screens/note_editor_screen.dart';
import 'note_list_item.dart';

class NotesList extends ConsumerWidget {
  final List<Note> notes;

  const NotesList({
    super.key,
    required this.notes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (notes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_add, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No notes yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to create your first note',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteListItem(
          note: note,
          onTap: () => _openNote(context, note.id),
          onDelete: () => _deleteNote(context, ref, note.id),
          onDuplicate: () => _duplicateNote(context, ref, note.id),
          onTogglePin: () => _togglePin(ref, note.id),
        );
      },
    );
  }

  void _openNote(BuildContext context, String noteId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(noteId: noteId),
      ),
    );
  }

  Future<void> _deleteNote(BuildContext context, WidgetRef ref, String noteId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(notesProvider.notifier).deleteNote(noteId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note deleted')),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete note: $error')),
          );
        }
      }
    }
  }

  Future<void> _duplicateNote(BuildContext context, WidgetRef ref, String noteId) async {
    try {
      await ref.read(notesProvider.notifier).duplicateNote(noteId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note duplicated')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to duplicate note: $error')),
        );
      }
    }
  }

  Future<void> _togglePin(WidgetRef ref, String noteId) async {
    try {
      await ref.read(notesProvider.notifier).togglePin(noteId);
    } catch (error) {
      // Handle error silently or show a subtle indicator
    }
  }
}