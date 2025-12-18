import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/note.dart';
import '../providers/notes_provider.dart';
import '../screens/simple_note_editor_screen.dart';
import 'note_filter.dart';

class BeautifulNotesList extends ConsumerStatefulWidget {
  final List<Note> notes;
  final NoteFilter currentFilter;
  final ValueChanged<NoteFilter> onFilterChanged;

  const BeautifulNotesList({
    super.key,
    required this.notes,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  ConsumerState<BeautifulNotesList> createState() => _BeautifulNotesListState();
}

class _BeautifulNotesListState extends ConsumerState<BeautifulNotesList>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _filterNotes(widget.notes);

    if (filteredNotes.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: filteredNotes.length,
          itemBuilder: (context, index) {
            final note = filteredNotes[index];
            final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _listAnimationController,
                curve: Interval(
                  (index * 0.1).clamp(0.0, 1.0),
                  ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                  curve: Curves.easeOutCubic,
                ),
              ),
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: _buildBeautifulNoteCard(note, index),
              ),
            );
          },
        );
      },
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

  Widget _buildBeautifulNoteCard(Note note, int index) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Dismissible(
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: note.isPinned && !note.isArchived
                ? LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer.withOpacity(0.3),
                      theme.colorScheme.primaryContainer.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: note.isPinned && !note.isArchived
                ? null
                : theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: note.isPinned && !note.isArchived
                  ? theme.colorScheme.primary.withOpacity(0.2)
                  : theme.colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _openNote(note),
              onLongPress: () => _showActionSheet(note),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      children: [
                        if (note.isPinned && !note.isArchived)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.withOpacity(0.2),
                                  Colors.orange.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.push_pin_rounded,
                              size: 18,
                              color: Colors.orange,
                            ),
                          ),
                        if (note.isPinned && !note.isArchived)
                          const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            note.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: note.isPinned
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              decoration: note.isDeleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: note.isDeleted
                                  ? theme.colorScheme.onSurface.withOpacity(0.5)
                                  : theme.colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.more_vert_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Metadata Row
                    Row(
                      children: [
                        if (note.folder != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.secondaryContainer
                                      .withOpacity(0.7),
                                  theme.colorScheme.secondaryContainer
                                      .withOpacity(0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.folder_rounded,
                                  size: 14,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  note.folder!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDate(note.updatedAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (note.isArchived)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.withOpacity(0.2),
                                  Colors.green.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ARCHIVED',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        if (note.isDeleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.withOpacity(0.2),
                                  Colors.red.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'DELETED',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(bool isLeftSwipe) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLeftSwipe
              ? [Colors.orange.withOpacity(0.8), Colors.orange]
              : [Colors.red.withOpacity(0.8), Colors.red],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: isLeftSwipe ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLeftSwipe ? Icons.push_pin_rounded : Icons.more_horiz_rounded,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            isLeftSwipe ? 'Pin' : 'More',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    String title, subtitle;
    IconData icon;

    switch (widget.currentFilter) {
      case NoteFilter.all:
        icon = Icons.note_add_rounded;
        title = 'No notes yet';
        subtitle = 'Tap the + button to create your first note';
        break;
      case NoteFilter.pinned:
        icon = Icons.push_pin_rounded;
        title = 'No pinned notes';
        subtitle = 'Pin important notes for quick access';
        break;
      case NoteFilter.archived:
        icon = Icons.archive_rounded;
        title = 'No archived notes';
        subtitle = 'Archive notes you want to keep but don\'t need often';
        break;
      case NoteFilter.deleted:
        icon = Icons.delete_rounded;
        title = 'Trash is empty';
        subtitle = 'Deleted notes will appear here';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer.withOpacity(0.3),
                    theme.colorScheme.primaryContainer.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(icon, size: 64, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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

  void _openNote(Note note) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SimpleNoteEditorScreen(noteId: note.id),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _togglePin(Note note) {
    ref.read(notesProvider.notifier).togglePin(note.id);
  }

  void _showActionSheet(Note note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildActionSheet(note),
    );
  }

  Widget _buildActionSheet(Note note) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                note.isPinned
                    ? Icons.push_pin_outlined
                    : Icons.push_pin_rounded,
              ),
              title: Text(note.isPinned ? 'Unpin' : 'Pin'),
              onTap: () {
                Navigator.pop(context);
                _togglePin(note);
              },
            ),
            if (!note.isDeleted) ...[
              ListTile(
                leading: Icon(
                  note.isArchived
                      ? Icons.unarchive_rounded
                      : Icons.archive_rounded,
                ),
                title: Text(note.isArchived ? 'Unarchive' : 'Archive'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(notesProvider.notifier).toggleArchive(note.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('Duplicate'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(notesProvider.notifier).duplicateNote(note.id);
                },
              ),
            ],
            ListTile(
              leading: Icon(
                note.isDeleted ? Icons.restore_rounded : Icons.delete_rounded,
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
                leading: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red,
                ),
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
