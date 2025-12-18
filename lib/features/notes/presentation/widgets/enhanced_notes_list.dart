import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/note.dart';
import '../providers/notes_provider.dart';
import '../screens/simple_note_editor_screen.dart';

enum NoteFilter { all, pinned, archived, deleted }

class EnhancedNotesList extends ConsumerStatefulWidget {
  final List<Note> notes;
  final NoteFilter currentFilter;
  final ValueChanged<NoteFilter> onFilterChanged;

  const EnhancedNotesList({
    super.key,
    required this.notes,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  ConsumerState<EnhancedNotesList> createState() => _EnhancedNotesListState();
}

class _EnhancedNotesListState extends ConsumerState<EnhancedNotesList> {
  @override
  Widget build(BuildContext context) {
    final filteredNotes = _filterNotes(widget.notes);

    if (filteredNotes.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildFilterTabs(),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: filteredNotes.length,
            onReorder: _onReorder,
            itemBuilder: (context, index) {
              final note = filteredNotes[index];
              return _buildNoteItem(note, index);
            },
          ),
        ),
      ],
    );
  }

  List<Note> _filterNotes(List<Note> notes) {
    List<Note> filtered;

    switch (widget.currentFilter) {
      case NoteFilter.all:
        filtered = notes.where((n) => !n.isArchived && !n.isDeleted).toList();
        break;
      case NoteFilter.pinned:
        filtered = notes
            .where((n) => n.isPinned && !n.isArchived && !n.isDeleted)
            .toList();
        break;
      case NoteFilter.archived:
        filtered = notes.where((n) => n.isArchived && !n.isDeleted).toList();
        break;
      case NoteFilter.deleted:
        filtered = notes.where((n) => n.isDeleted).toList();
        break;
    }

    // Sort: pinned first, then by sort order, then by update date
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;

      final sortOrderComparison = a.sortOrder.compareTo(b.sortOrder);
      if (sortOrderComparison != 0) return sortOrderComparison;

      return b.updatedAt.compareTo(a.updatedAt);
    });

    return filtered;
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(NoteFilter.all, 'All', Icons.notes),
          const SizedBox(width: 8),
          _buildFilterChip(NoteFilter.pinned, 'Pinned', Icons.push_pin),
          const SizedBox(width: 8),
          _buildFilterChip(NoteFilter.archived, 'Archived', Icons.archive),
          const SizedBox(width: 8),
          _buildFilterChip(NoteFilter.deleted, 'Trash', Icons.delete),
        ],
      ),
    );
  }

  Widget _buildFilterChip(NoteFilter filter, String label, IconData icon) {
    final isSelected = widget.currentFilter == filter;
    final count = _getFilterCount(filter);

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
      onSelected: (selected) {
        if (selected) widget.onFilterChanged(filter);
      },
    );
  }

  int _getFilterCount(NoteFilter filter) {
    switch (filter) {
      case NoteFilter.all:
        return widget.notes.where((n) => !n.isArchived && !n.isDeleted).length;
      case NoteFilter.pinned:
        return widget.notes
            .where((n) => n.isPinned && !n.isArchived && !n.isDeleted)
            .length;
      case NoteFilter.archived:
        return widget.notes.where((n) => n.isArchived && !n.isDeleted).length;
      case NoteFilter.deleted:
        return widget.notes.where((n) => n.isDeleted).length;
    }
  }

  Widget _buildNoteItem(Note note, int index) {
    return Dismissible(
      key: ValueKey(note.id),
      background: _buildSwipeBackground(true),
      secondaryBackground: _buildSwipeBackground(false),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          _togglePin(note);
        } else {
          _showActionSheet(note);
        }
      },
      child: Card(
        key: ValueKey(note.id),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          title: Row(
            children: [
              if (note.isPinned && !note.isArchived)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.push_pin, size: 16, color: Colors.orange),
                ),
              Expanded(
                child: Text(
                  note.title,
                  style: TextStyle(
                    fontWeight: note.isPinned
                        ? FontWeight.w600
                        : FontWeight.w500,
                    decoration: note.isDeleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.folder != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.folder, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        note.folder!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _formatDate(note.updatedAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
          trailing: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
          onTap: () => _openNote(note),
          onLongPress: () => _showActionSheet(note),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(bool isLeftSwipe) {
    return Container(
      color: isLeftSwipe ? Colors.orange : Colors.red,
      alignment: isLeftSwipe ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        isLeftSwipe ? Icons.push_pin : Icons.more_horiz,
        color: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    String title, subtitle;
    IconData icon;

    switch (widget.currentFilter) {
      case NoteFilter.all:
        icon = Icons.note_add;
        title = 'No notes yet';
        subtitle = 'Tap the + button to create your first note';
        break;
      case NoteFilter.pinned:
        icon = Icons.push_pin;
        title = 'No pinned notes';
        subtitle = 'Pin important notes for quick access';
        break;
      case NoteFilter.archived:
        icon = Icons.archive;
        title = 'No archived notes';
        subtitle = 'Archive notes you want to keep but don\'t need often';
        break;
      case NoteFilter.deleted:
        icon = Icons.delete;
        title = 'Trash is empty';
        subtitle = 'Deleted notes will appear here';
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE HH:mm').format(date);
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    // Handle reordering logic
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final filteredNotes = _filterNotes(widget.notes);
    final note = filteredNotes[oldIndex];

    // Update sort order
    ref.read(notesProvider.notifier).updateNoteSortOrder(note.id, newIndex);
  }

  void _openNote(Note note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SimpleNoteEditorScreen(noteId: note.id),
      ),
    );
  }

  void _togglePin(Note note) {
    ref.read(notesProvider.notifier).togglePin(note.id);
  }

  void _showActionSheet(Note note) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildActionSheet(note),
    );
  }

  Widget _buildActionSheet(Note note) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              note.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
            ),
            title: Text(note.isPinned ? 'Unpin' : 'Pin'),
            onTap: () {
              Navigator.pop(context);
              _togglePin(note);
            },
          ),
          if (!note.isDeleted) ...[
            ListTile(
              leading: Icon(note.isArchived ? Icons.unarchive : Icons.archive),
              title: Text(note.isArchived ? 'Unarchive' : 'Archive'),
              onTap: () {
                Navigator.pop(context);
                ref.read(notesProvider.notifier).toggleArchive(note.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                ref.read(notesProvider.notifier).duplicateNote(note.id);
              },
            ),
          ],
          ListTile(
            leading: Icon(
              note.isDeleted ? Icons.restore : Icons.delete,
              color: note.isDeleted ? Colors.green : Colors.red,
            ),
            title: Text(
              note.isDeleted ? 'Restore' : 'Delete',
              style: TextStyle(
                color: note.isDeleted ? Colors.green : Colors.red,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              if (note.isDeleted) {
                ref.read(notesProvider.notifier).restoreNote(note.id);
              } else {
                _confirmDelete(note);
              }
            },
          ),
          if (note.isDeleted)
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Delete Forever',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmPermanentDelete(note);
              },
            ),
        ],
      ),
    );
  }

  void _confirmDelete(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Move "${note.title}" to trash?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(notesProvider.notifier).deleteNote(note.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmPermanentDelete(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Forever'),
        content: Text(
          'Permanently delete "${note.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(notesProvider.notifier).permanentlyDeleteNote(note.id);
            },
            child: const Text(
              'Delete Forever',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
