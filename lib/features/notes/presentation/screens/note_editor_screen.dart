import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notes_provider.dart';
import '../widgets/markdown_editor.dart';
import '../widgets/markdown_preview.dart';
import 'version_history_screen.dart';

enum EditorMode { edit, preview, split }

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String noteId;

  const NoteEditorScreen({
    super.key,
    required this.noteId,
  });

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  EditorMode _currentMode = EditorMode.edit;
  bool _hasUnsavedChanges = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    
    _titleController.addListener(_onTitleChanged);
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });
    
    // Auto-save title changes after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _hasUnsavedChanges) {
        _saveNote();
      }
    });
  }

  void _onContentChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });
    
    // Update content provider for autosave
    ref.read(noteContentProvider(widget.noteId).notifier)
        .updateContent(_contentController.text);
  }

  @override
  Widget build(BuildContext context) {
    final noteAsync = ref.watch(notesProvider);
    final contentAsync = ref.watch(noteContentProvider(widget.noteId));

    return noteAsync.when(
      data: (notes) {
        final note = notes.firstWhere(
          (n) => n.id == widget.noteId,
          orElse: () => throw Exception('Note not found'),
        );

        return contentAsync.when(
          data: (content) {
            // Initialize controllers only once
            if (!_isInitialized) {
              _titleController.text = note.title;
              _contentController.text = content;
              _isInitialized = true;
            }

            return PopScope(
              canPop: !_hasUnsavedChanges,
              onPopInvoked: (didPop) async {
                if (!didPop && _hasUnsavedChanges) {
                  final shouldPop = await _showUnsavedChangesDialog();
                  if (shouldPop && mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Edit Note'),
                  actions: [
                    IconButton(
                      icon: Icon(_getModeIcon()),
                      onPressed: _toggleMode,
                      tooltip: 'Switch view mode',
                    ),
                    IconButton(
                      icon: const Icon(Icons.history),
                      onPressed: () => _openVersionHistory(context),
                      tooltip: 'Version history',
                    ),
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: _saveVersion,
                      tooltip: 'Save version',
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Title input
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Note title...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _saveNote(),
                      ),
                    ),
                    const Divider(height: 1),
                    // Content area
                    Expanded(
                      child: _buildContentArea(),
                    ),
                  ],
                ),
                bottomNavigationBar: _hasUnsavedChanges
                    ? Container(
                        padding: const EdgeInsets.all(8),
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16),
                            const SizedBox(width: 8),
                            const Text('Auto-saving...'),
                            const Spacer(),
                            TextButton(
                              onPressed: _saveNote,
                              child: const Text('Save Now'),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            );
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  ElevatedButton(
                    onPressed: () => ref.refresh(noteContentProvider(widget.noteId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64),
              const SizedBox(height: 16),
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentArea() {
    switch (_currentMode) {
      case EditorMode.edit:
        return MarkdownEditor(
          controller: _contentController,
          onChanged: (text) => _onContentChanged(),
        );
      case EditorMode.preview:
        return MarkdownPreview(content: _contentController.text);
      case EditorMode.split:
        return Row(
          children: [
            Expanded(
              child: MarkdownEditor(
                controller: _contentController,
                onChanged: (text) => _onContentChanged(),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: MarkdownPreview(content: _contentController.text),
            ),
          ],
        );
    }
  }

  IconData _getModeIcon() {
    switch (_currentMode) {
      case EditorMode.edit:
        return Icons.edit;
      case EditorMode.preview:
        return Icons.preview;
      case EditorMode.split:
        return Icons.view_column;
    }
  }

  void _toggleMode() {
    setState(() {
      switch (_currentMode) {
        case EditorMode.edit:
          _currentMode = EditorMode.preview;
          break;
        case EditorMode.preview:
          _currentMode = EditorMode.split;
          break;
        case EditorMode.split:
          _currentMode = EditorMode.edit;
          break;
      }
    });
  }

  Future<void> _saveNote() async {
    try {
      final notesAsync = ref.read(notesProvider);
      final notes = notesAsync.value ?? [];
      final note = notes.firstWhere((n) => n.id == widget.noteId);

      final updatedNote = note.copyWith(
        title: _titleController.text.trim().isEmpty 
            ? 'Untitled Note' 
            : _titleController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await ref.read(notesProvider.notifier).updateNote(updatedNote);
      await ref.read(noteContentProvider(widget.noteId).notifier).saveManually();

      setState(() {
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: $error')),
        );
      }
    }
  }

  Future<void> _saveVersion() async {
    try {
      await _saveNote(); // Save current changes first
      await ref.read(noteContentProvider(widget.noteId).notifier).saveVersion();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Version saved')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save version: $error')),
        );
      }
    }
  }

  void _openVersionHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VersionHistoryScreen(noteId: widget.noteId),
      ),
    );
  }

  Future<bool> _showUnsavedChangesDialog() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Do you want to save before leaving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
              await _saveNote();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }
}