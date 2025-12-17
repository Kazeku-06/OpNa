import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notes_provider.dart';
import '../widgets/notes_list.dart';
import '../widgets/search_bar.dart';
import '../widgets/sort_options.dart';
import 'note_editor_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.backup),
            onPressed: _showBackupOptions,
          ),
          IconButton(
            icon: const Icon(Icons.import_export),
            onPressed: _showImportExportOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                NotesSearchBar(controller: _searchController),
                const SizedBox(height: 8),
                const SortOptionsWidget(),
              ],
            ),
          ),
          Expanded(
            child: searchResults.when(
              data: (notes) => NotesList(notes: notes),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    ElevatedButton(
                      onPressed: () => ref.refresh(notesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createNewNote() async {
    try {
      final notesNotifier = ref.read(notesProvider.notifier);
      final note = await notesNotifier.createNote();
      
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NoteEditorScreen(noteId: note.id),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create note: $error')),
        );
      }
    }
  }

  void _showBackupOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Create Backup'),
              onTap: () {
                Navigator.pop(context);
                _createBackup();
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Restore Backup'),
              onTap: () {
                Navigator.pop(context);
                _restoreBackup();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showImportExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Import Notes'),
              onTap: () {
                Navigator.pop(context);
                _importNotes();
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('Export All Notes'),
              onTap: () {
                Navigator.pop(context);
                _exportAllNotes();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    try {
      final repository = ref.read(notesRepositoryProvider);
      final backupName = 'backup_${DateTime.now().millisecondsSinceEpoch}';
      await repository.createBackup(backupName);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup created successfully')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create backup: $error')),
        );
      }
    }
  }

  Future<void> _restoreBackup() async {
    // TODO: Implement file picker for backup restoration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restore backup feature coming soon')),
    );
  }

  Future<void> _importNotes() async {
    // TODO: Implement file picker for importing notes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import notes feature coming soon')),
    );
  }

  Future<void> _exportAllNotes() async {
    try {
      final notesAsync = ref.read(notesProvider);
      final notes = notesAsync.value ?? [];
      
      if (notes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No notes to export')),
        );
        return;
      }

      final repository = ref.read(notesRepositoryProvider);
      final noteIds = notes.map((note) => note.id).toList();
      
      // For web, this will trigger downloads. For desktop, save to Downloads folder
      await repository.exportNotes(noteIds, '/storage/emulated/0/Download');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notes exported successfully')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export notes: $error')),
        );
      }
    }
  }
}